#!/bin/bash

# Logging...
log() {
   local level=$1
   local message=$2
   echo "$(date +%Y-%m-%dT%H:%M) [${level}] ${message}"
}

clean_up_mount() {
   mount_point=$1

   log "INFO" "Unmounting ${mount_point}"
   umount ${mount_point}

   if ! [ $? -eq 0 ]; then
      log "ERROR" "Unmount of ${mount_point} failed. You may need to manually unmount it."
   fi
}

# Clean up function... 
clean_up() {
   ## Clean up overlay mounts

   if ! [ -d "${MOUNT_POINT}" ]; then
      log "WARN" "Mount point ${MOUNT_POINT} doesn't exist"
   else
      # removing bind mounts
      for mp in /dev/pts /dev; do
         clean_up_mount "${MOUNT_POINT}${mp}"
      done

      # removing overlay mount
      clean_up_mount "$MOUNT_POINT"

      # delete to overlay dir
      log "INFO" "Deleting ${MOUNT_POINT}"
      rm -rf ${MOUNT_POINT}
   fi

   # Clean up RW layer
   if ! [ -d "${CONTAINER_DIR}" ]; then
      log "WARN" "Container directory ${CONTAINER_DIR} doesn't exist"
   else
      log "INFO" "Deleting ${CONTAINER_DIR}"
      rm -rf ${CONTAINER_DIR}
   fi

   ## Clean up cgroups

   # move the PID of this script out of the cgroup
   echo $$ > /sys/fs/cgroup/cgroup.procs
   # kill the chrooted PID and any children
   echo 1 > /sys/fs/cgroup/${CONTAINER_ID}/cgroup.kill
   # remove the cgroup
   rmdir /sys/fs/cgroup/${CONTAINER_ID}

   if [ $? -eq 0 ]; then
      log "INFO" "Removed cgroup ${CONTAINER_ID}"
   else
      log "WARN" "Could not remove cgroup ${CONTAINER_ID}"
   fi

   exit 0
}

mount_storage() {
   upper_dir="${CONTAINER_DIR}/upper"
   work_dir="${CONTAINER_DIR}/work"
   lower_dirs=$(cat /var/lib/oci/${APP_ID}/lower_layers.dat)

   mkdir -p "${MOUNT_POINT}"
   mkdir -p "${upper_dir}"
   mkdir -p "${work_dir}"

   # Mount the OverlayFS
   log "INFO" "Mounting image: ${APP_ID} to ${MOUNT_POINT}"
   mount -t overlay overlay -o lowerdir="${lower_dirs}",upperdir="${upper_dir}",workdir="${work_dir}" "$MOUNT_POINT"

   # Check if the mount was successful
   if [ $? -eq 0 ]; then
       log "INFO" "Image $APP_ID mounted successfully at $MOUNT_POINT"
   else
       log "ERROR" "Mounting image $APP_ID failed"
   fi
   log "INFO" "Mounting RW layer to ${upper_dir}"

   # setup mounts for system dirs...
   for mp in /dev /dev/pts; do
      mount --bind ${mp} "${MOUNT_POINT}${mp}/"
   done
}

export_environment() {
   log "INFO" "Exporting environment variables"
   env_str=$(cat /var/lib/oci/${APP_ID}/environment.json)

   env_str=${env_str#"["}
   env_str=${env_str%"]"}

   env_array=($env_str)

   # export env vars...
   for element in "${env_array[@]}"
   do
      log "INFO" "   ${element}"
      eval "export ${element}"
   done
}

get_entrypoint() {
   entrypoint=$(cat /var/lib/oci/${APP_ID}/entrypoint.json)
   entrypoint=${entrypoint#"["}
   entrypoint=${entrypoint%"]"}

   echo "${entrypoint}"
}

limit_memory() {
   memory_limit_mb=$1

   mkdir -p /sys/fs/cgroup/${CONTAINER_ID}
   echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
   echo "${memory_limit_mb}M" > /sys/fs/cgroup/${CONTAINER_ID}/memory.max
   echo $$ > /sys/fs/cgroup/${CONTAINER_ID}/cgroup.procs
   log "INFO" "Limiting max memory to ${memory_limit_mb}MB"
}

limit_cpu() {
   max_cpu=$1

   cpu_percent=$(echo | awk -v max_cpu=${max_cpu} '{ print max_cpu * 100 }')
   log "INFO" "Limiting max CPU to ${cpu_percent}% of a core"

   period=100000
   max_cpu=$(echo | awk -v max_cpu=${max_cpu} -v period=${period} '{ print max_cpu * period }')

   echo "+cpu" > /sys/fs/cgroup/cgroup.subtree_control
   echo "${max_cpu} ${period}" > /sys/fs/cgroup/${CONTAINER_ID}/cpu.max
}

usage() {
   echo ""
   echo "Usage: $0 <IMAGE> <MAX-MEMORY> <MAX-CPU>"
   echo "Description:    This script creates and starts a new container from an"
   echo "                image."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  IMAGE:        Name of the image to create and start a running container"
   echo "                from."
   echo "  MAX-MEMORY:   The maximum amount of memory (in MBs) the applications running"
   echo "                inside the container will be allowed to consume.  If they exceed"
   echo "                this value they will be OMM killed."
   echo "  MAX-CPU:      The amount of a single CPU the applications running inside"
   echo "                this container will be allowed to consume.  Value must be"
   echo "                between 0.1 - 1.0 where 0.1 whould be 10% of a CPU and 1.0"
   echo "                would be 100% of a CPU."
   echo ""
}

############################ main ################################
# Correct number of command line aregs supplied?
if [ "$#" -lt 3 ]
then
   echo "Error: Not enough args!"
   usage
   exit 1
fi

# Must be root
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR" "This script requires root privileges. Please run with sudo."
    exit 1
fi

trap clean_up EXIT

image_name=$1
max_memory=$2
max_cpu=$3

CONTAINER_ID=$(uuidgen)
MOUNT_POINT="/mnt/${CONTAINER_ID}"
CONTAINER_DIR="/var/lib/oci/containers/${CONTAINER_ID}"

APP_ID=${image_name}
APP_ID="${APP_ID//:/-}"

# The mount_storage function utilizes overlayFS to merge all of the layers of the 
# image into a single unified directory by placing each layer on top of each other. 
mount_storage

# The export_environment and get_entrypoint functions just read data droppings left
# by the docker-pull.sh command.  Nothing special is going on here.
export_environment
entrypoint=$(get_entrypoint)

# The limit_memory and limit_cpu functions utilize cgroups to limit both the memory and
# CPU resources that can be consumed by the processes running inside of the container.
limit_memory ${max_memory} 
limit_cpu ${max_cpu}

# There's quite a bit of 'MAGIC' on this single line.  The unshare command creates a
# couple of new namespaces (PID and mount) and runs the chroot command in them.  The
# chroot command changes the root directory to the same directory we just mounted our
# images file system to and then runs /bin/bash.  /bin/bash mounts /proc and then
# then executes the entrypoint of our container (starts the container).
#unshare --pid --fork --kill-child --mount-proc chroot ${MOUNT_POINT} /bin/bash -c "mount -t proc proc /proc; ${entrypoint}"
unshare --pid --fork --kill-child --mount chroot ${MOUNT_POINT} /bin/bash -c "mount -t proc proc /proc; /bin/bash"
