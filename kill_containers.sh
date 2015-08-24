#!/bin/bash
#
# Kill and remove all containers on current host.

basedir=$(readlink -f $(dirname $0))
source ${basedir}/swarm_scripts/common_env.sh

docker ps -a -q | xargs -I {} docker kill {}
docker ps -a -q | xargs -I {} docker rm -f {}
