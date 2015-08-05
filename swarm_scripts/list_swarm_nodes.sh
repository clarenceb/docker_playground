#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

echo "Swarm nodes --->"
docker run --rm \
  swarm:0.3.0 list consul://${SWARM_MANAGER_IP}:${CONSUL_API_PORT}/swarm
echo "---------------"

echo "Swarm cluster info --->"
docker -H ${DOCKER_SWARM_HOST} info
echo "---------------"
