#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

docker kill swarm-manager
docker rm swarm-manager

docker run -d \
  --name swarm-manager \
  -p ${SWARM_MANAGER_PORT}:${DOCKER_TCP_PORT} \
  swarm:0.3.0 manage consul://${PUBLIC_IP}:${CONSUL_API_PORT}/swarm
