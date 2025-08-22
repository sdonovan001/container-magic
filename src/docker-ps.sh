#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0"
   echo "Description: This script displays running containers."
   echo ""
   echo "Options:"
   echo "  -h         Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  None"
   echo ""
}

################ main ################
if [ "$1" == "-h" ]
then
   usage
   exit 0
fi

pid_of_runcmd=$(ps -aef|grep unshare|grep chroot|awk '{ print $3 }'|sed "s/\/mnt\///")

echo ""
length=${#pid_of_runcmd}
if [[ "${length}" != "0" ]]
then
   container_id=$(ps -aef|grep unshare|grep chroot|awk '{ print $14 }'|sed "s/\/mnt\///")
   image=$(ps -p ${pid_of_runcmd} -o cmd|grep -v CMD|awk '{ print $3 }')
   echo "Image             Container ID"
   echo "------------------------------------------------------"
   echo "${image}     ${container_id}"
else
   echo "No running containers found."
fi
echo ""

