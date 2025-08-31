#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0 <container_id> <cmd>"
   echo "Description:    This script allows you to execute commands inside a"
   echo "                running container."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  CONTAINER_ID: Unique identifier of the running container.  Can be"
   echo "                found by running ./docker-ps.sh."
   echo "  CMD:          Command to execute inside the running container."
   echo ""
}

################ main ################
if [ "$1" == "-h" ]
then
   usage
   exit 0
fi

if [ "$#" -lt 2 ]
then
   echo "Error: Not enough args!"
   usage
   exit 1
fi

# PID of unshare command
ns_pid=$(ps -aef|grep $1|grep unshare|awk '{ print $2 }')
# PID of container entrypoint
child_pid=$(ps --ppid ${ns_pid}|grep -v PID|awk '{ print $1 }')

# We want to enter the same namespace as the entrypoint
nsenter -a -t ${child_pid} -w -r /bin/bash -c "mount -t proc proc /proc; $2"
