#!/bin/bash
#
# Installs Docker Compose.

docker_compose_version="1.3.3"

id vagrant 2>&1 > /dev/null
if [ $? != 0 ]; then
    echo "Run this script from within a Vagrant box"
    exit 1
fi

if [[ `whoami` != 'vagrant' ]]; then
  su -l vagrant
fi

echo "Running as: `whoami`"

if [ ! -f /usr/local/bin/docker-compose ]; then
  curl -L https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi
