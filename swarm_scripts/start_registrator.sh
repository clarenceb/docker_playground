#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

docker kill registrator
docker rm registrator

# Start Registrator (https://github.com/progrium/registrator)
docker run -d \
  --name registrator \
  -h registrator \
  -e DOCKER_HOST="${DOCKER_HOST}" \
  progrium/registrator "${CONSUL_URL}"

run_status=$?

[[ ${run_status} != 0 ]] && echo "Error: Failed to start registrator" && exit ${run_status}
[[ ${run_status} == 0 ]] && echo "Registrator started against Consul at ${CONSUL_URL}."
