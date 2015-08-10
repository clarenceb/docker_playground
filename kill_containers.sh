#!/bin/sh
#
# Kill and remove all containers on current host.

basedir=$(readlink -f $(dirname $0))
source ${basedir}/swarm_scripts/common_env.sh

docker ps -a -q | xargs docker kill
docker ps -a -q | xargs docker rm -f
