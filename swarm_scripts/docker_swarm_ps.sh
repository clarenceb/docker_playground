#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

echo "=== Docker Swarm ==="
docker -H ${DOCKER_SWARM_HOST} ps | perl -ne '@cols = split /\s{2,}/, $_; printf "%0s %25s %20s %30s\n", $cols[0], $cols[1], $cols[4], $cols[6]'
