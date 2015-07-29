#!/bin/bash
#
# Reads Docker image list to fetch and uses cache versions if available.

id vagrant 2>&1 > /dev/null
if [ $? != 0 ]; then
    echo "Run this script from within a Vagrant box"
    exit 1
fi

if [[ `whoami` != 'vagrant' ]]; then
  su -l vagrant
fi

echo "Running as: `whoami`"

base_dir="/vagrant" 
docker_cache_dir="${base_dir}/cache/docker"

mkdir -p ${docker_cache_dir}

_RET=""

docker_filename() {
  image_name=$1
  tag_name=$2
  image_name_safe=`echo ${image_name} | sed 's/\//--DOCKERSLASH--/'`

  _RET="${image_name_safe}--TAG--${tag_name}.tar"
}

while IFS=, read image taglist; do
  echo "Processing: $image, $taglist"
  tags=`echo ${taglist} | tr "|" "\n"`
  for tag in $tags; do
    docker images | grep "^${image}\s" | grep "\s${tag}\s" > /dev/null
    if [ $? -ne 0  ]; then
      docker_filename $image $tag
      filename=${_RET}
      filepath="${docker_cache_dir}/${filename}"
      if [ -f ${filepath} ]; then
        echo "Load Docker image: ${image}:${tag} from cached file ${filepath} ..."
        docker load -i ${docker_cache_dir}/${filename}
      else
        echo "Pulling image: ${image}:${tag} from Docker hub"
        docker pull ${image}:${tag}
        docker save ${image}:${tag} > ${filepath}
        echo "Cached image: ${image}:${tag} to ${filepath}"
      fi
    else
      echo "Docker image: ${image}:${tag} is already present ..."
    fi
  done
done < "${base_dir}/docker-images.txt"
