#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0"
   echo "Description: This script displays container images that have been "
   echo "             pulled locally."
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

image_root="/var/lib/oci"

echo -e "\nImages"
echo "-----------"

if [ -d  "${image_root}" ]
then
   ls -ltr /var/lib/oci | grep -v "total 0" | grep -v containers | awk '{ print $9 }' | sed "s/\(.*\)-/\1:/"
else
   echo "No local images found!  Try a ./docker-pull.sh"
fi

echo ""
