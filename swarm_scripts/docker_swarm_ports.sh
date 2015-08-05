#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

container_id=$1

echo "=== Docker Swarm : Container ID: ${container_id} ==="
docker -H ${DOCKER_SWARM_HOST} ps | grep ${container_id} | perl -ne '@cols = split /\s{2,}/, $_; printf "%s%s\n", "HOST/NAME: " . $cols[6] . "\n", "PORTS:\n" . join("\n", split(", ", $cols[5]))'
