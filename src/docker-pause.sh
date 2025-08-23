#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0 <CONTAINER_ID>"
   echo "Description:    This script pauses a running container causing all"
   echo "                all processes inside the container to be suspended."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  CONTAINER_ID: Unique identifier of the running container.  Can"
   echo "                be found by running ./docker-ps.sh."
   echo ""
}

################ main ################
if [ "$1" == "-h" ]
then
   usage
   exit 0
fi

if [ "$#" -lt 1 ]
then
   echo "Error: Not enough args!"
   usage
   exit 1
fi

container_id=$1
cgroup_root="/sys/fs/cgroup"
echo "1" > "${cgroup_root}/${container_id}/cgroup.freeze"
