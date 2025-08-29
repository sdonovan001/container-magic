#!/bin/bash

usage() {
   echo ""
   echo "Usage: $0 <repo>/<image>:<label>"
   echo "Description:    This script downloads container images from a "
   echo "                container registry to your local machine."
   echo ""
   echo "Options:"
   echo "  -h            Display this usage message and exit."
   echo ""
   echo "Arguments:"
   echo "  repo:         Name of the docker repo to pull from."
   echo "  image:        Name of the image to pull from the remote repo."
   echo "  label:        Label attached to the image."
   echo ""
}

gcrane_pull() {
   # Punt on having to script all the authentication, JSON parsing, layer inspection and
   # downloads by just piggybacking on gcrane.
   echo ""
   echo "Pulling image ${image_uri}"
   gcrane pull ${image_uri} "${containers_root}/${image_name}" --format oci
   if [ "$?" != "0" ]
   then
      # no need to clutter up gcrane's error messages with our own
      exit 1
   fi
}

get_manifest() {
   manifest=$(cat "${containers_root}/${image_name}/index.json" | jq '.manifests | .[0].digest')
   manifest="${manifest##*:}"
   manifest="${manifest%?}"
   echo "${manifest}"
}

process_configs() {
   # find the digest for the images config info
   config_digest=$(cat "${containers_root}/${image_name}/blobs/sha256/${manifest}" | jq '.config.digest')
   config_digest="${config_digest##*:}"
   config_digest="${config_digest%?}"

   # process these a bit for later use (like when it's time to run the image)
   environment=$(cat "${containers_root}/${image_name}/blobs/sha256/${config_digest}" | jq '.config.Env')
   entrypoint=$(cat "${containers_root}/${image_name}/blobs/sha256/${config_digest}" | jq '.config.Entrypoint')
   echo ${environment} > "${containers_root}/${image_name}/environment.json"
   echo ${entrypoint} > "${containers_root}/${image_name}/entrypoint.json"
}

extract_layers() {
   # go extract the layers
   digests=$(cat "${containers_root}/${image_name}/blobs/sha256/${manifest}" | jq '.layers | .[].digest')
   mapfile -t digest_array <<< ${digests}

   mount_dirs="${containers_root}/${image_name}/mount_dirs"
   rm -rf ${mount_dirs}
   mkdir -p ${mount_dirs}

   layers=""
   for item in "${digest_array[@]}"; do
      digest="${item##*:}"
      digest="${digest%?}"
      layers="${layers}:${mount_dirs}/${digest}"
      echo "   Processing layer: ${digest}"
      mkdir -p "${mount_dirs}/${digest}"

      gunzip -c "${containers_root}/${image_name}/blobs/sha256/${digest}" |  tar -xf - -C "${mount_dirs}/${digest}" 
   done

   # this will be useful when running containers
   layers="${layers:1}"
   echo ${layers} > "${containers_root}/${image_name}/lower_layers.dat"
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

image_uri=$1
containers_root="/var/lib/oci"
rm -rf ${containers_root}
mkdir -p ${containers_root}

image_name="${image_uri##*/}"
image_name="${image_name/:/-}"

gcrane_pull
manifest=$(get_manifest)
process_configs
extract_layers

echo "Done!"
echo ""
