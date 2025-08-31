#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0 <container_id>"
   echo "Description:    This script kills the running container that maps "
   echo "                to the container_id passed in.  All child processes"
   echo "                running inside the container will also be killed."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  container_id: Unique identifier of the running container.  Can be"
   echo "                found by running ./docker-ps.sh."
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

pid_to_kill=$(ps -aef|grep $1|grep unshare|awk '{ print $2 }')

length=${#pid_to_kill}
if [[ "${length}" != "0" ]]
then
   kill -9 ${pid_to_kill}
   echo "Container ID: $1 killed"
else
   echo "Container $1 not found!"
   exit 1
fi
