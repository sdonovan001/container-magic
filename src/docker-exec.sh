#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0 <CONTAINER_ID> <CMD>"
   echo "Description:    This script allows you to execute commands inside "
   echo "                a running container."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  CONTAINER_ID: Unique identifier of the running container.  Can"
   echo "                be found by running ./docker-ps.sh."
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

ns_pid=$(ps -aef|grep $1|grep unshare|awk '{ print $2 }')
child_pid=$(ps --ppid ${ns_pid}|grep -v PID|awk '{ print $1 }')

nsenter -a -t ${child_pid} -w -r /bin/bash -c "mount -t proc proc /proc; $2"
