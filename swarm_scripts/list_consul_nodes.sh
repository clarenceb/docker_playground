#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

curl ${PUBLIC_IP}:${CONSUL_API_PORT}/v1/catalog/nodes | json_pp
