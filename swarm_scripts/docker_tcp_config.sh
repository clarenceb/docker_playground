#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

grep "tcp" /etc/default/docker
if [[ $? != 0 ]]; then
  echo "DOCKER_OPTS=\"-H tcp://${PUBLIC_IP}:${DOCKER_TCP_PORT} \${DOCKER_OPTS}\"" >> /etc/default/docker
fi

netstat -tulnp | grep ${DOCKER_TCP_PORT} | grep docker
if [[ $? != 0 ]]; then
  initctl restart docker
fi
