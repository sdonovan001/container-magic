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

trap clean_up EXIT

mount_storage() {
   mkdir -p "${MOUNT_POINT}"
   mkdir -p "${UPPER_DIR}"
   mkdir -p "${WORK_DIR}"

   # Mount the OverlayFS
   log "INFO" "Mounting image: ${APP_ID} to ${MOUNT_POINT}"
   mount -t overlay overlay -o lowerdir="${LOWER_DIRS}",upperdir="${UPPER_DIR}",workdir="${WORK_DIR}" "$MOUNT_POINT"

   # Check if the mount was successful
   if [ $? -eq 0 ]; then
       log "INFO" "Image $APP_ID mounted successfully at $MOUNT_POINT"
   else
       log "ERROR" "Mounting image $APP_ID failed"
   fi
   log "INFO" "Mounting RW layer to ${UPPER_DIR}"

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
}

limit_cpu() {
   max=$1
   period=$2

   echo "+cpu" > /sys/fs/cgroup/cgroup.subtree_control
   echo "${max} ${period}" > /sys/fs/cgroup/${CONTAINER_ID}/cpu.max
}

############################ main ################################
image_name=$1

# Must be root
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR" "This script requires root privileges. Please run with sudo."
    exit 1
fi

# Check if image ID is provided
if [ -z "$image_name" ]; then
    log "ERROR" "Must provide <image_id> to run!"
    log "ERROR" "Usage: $0 <image_id>"
    exit 1
fi

CONTAINER_ID=$(uuidgen)
MOUNT_POINT="/mnt/${CONTAINER_ID}"
CONTAINER_DIR="/var/lib/oci/containers/${CONTAINER_ID}"
UPPER_DIR="${CONTAINER_DIR}/upper"
WORK_DIR="${CONTAINER_DIR}/work"

APP_ID=$1
APP_ID="${APP_ID//:/-}"
LOWER_DIRS=$(cat /var/lib/oci/${APP_ID}/lower_layers.dat)

mount_storage
export_environment
entrypoint=$(get_entrypoint)

limit_memory 800 
limit_cpu 50000 100000

unshare --pid --fork --kill-child --mount-proc chroot ${MOUNT_POINT} /bin/bash -c "mount -t proc proc /proc; ${entrypoint}"
