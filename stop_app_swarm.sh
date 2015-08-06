#!/bin/bash
#
# Stop services and app in a Docker Swarm.

basedir=$(readlink -f $(dirname $0))
source ${basedir}/swarm_scripts/common_env.sh

docker_cmd="docker -H ${DOCKER_SWARM_HOST}"

${docker_cmd} ps | grep -E "shop-app" | awk '{print $1}' | xargs -I {} ${docker_cmd} kill {}
${docker_cmd} ps -a | grep -E "shop-app" | awk '{print $1}' | xargs -I {} ${docker_cmd} rm --force {}

${docker_cmd} ps | grep -E "review-*" | awk '{print $1}' | xargs -I {} ${docker_cmd} kill {}
${docker_cmd} ps -a | grep -E "review-*" | awk '{print $1}' | xargs -I {} ${docker_cmd} rm --force {}

${docker_cmd} ps | grep -E "catalogue-*" | awk '{print $1}' | xargs -I {} ${docker_cmd} kill {}
${docker_cmd} ps -a | grep -E "catalogue-*" | awk '{print $1}' | xargs -I {} ${docker_cmd} rm --force {}
