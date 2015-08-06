#!/bin/bash
#
# Stops the monitoring infrastructure.

basedir=$(readlink -f $(dirname $0))
source ${basedir}/swarm_scripts/common_env.sh

docker_cmd="docker -H ${DOCKER_SWARM_HOST}"
container_whitelist="(prometheus_server|prometheus_dash|container_exporter|consul_exporter|alertmanager)"

${docker_cmd} ps | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} ${docker_cmd} kill {}
${docker_cmd} ps -a | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} ${docker_cmd} rm --force {}

# Cleanup Prometheus Dashboard sqlite3 DB
sudo rm -rf /tmp/prom
