#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

node_id=$1
container_name="swarm-node-${node_id}"

if [[ -z "${node_id}" ]]; then
  echo "Missing node_id"
  exit 1
fi

docker kill ${container_name}
docker rm ${container_name}

docker run -d \
  --name ${container_name} \
  swarm:0.3.0 join --addr=${PUBLIC_IP}:${DOCKER_TCP_PORT} consul://${SWARM_MANAGER_IP}:${CONSUL_API_PORT}/swarm
