#!/bin/bash

basedir=$(readlink -f $(dirname $0))
source ${basedir}/common_env.sh

consul_type=$1
if [[ -z "${consul_type}" ]]; then
  echo "Missing consult_type: (server|agent)"
  exit 1
fi

consul_api_port=8500
consul_dns_port=53
docker_bridge_ip=172.17.42.1
consul_url="consul://${PUBLIC_IP}:${consul_api_port}"
consul_nodes=2

if [[ "${consul_type}" == "server" ]]; then

  docker kill consul-server
  docker rm consul-server

  echo "Starting a Consul server..."
  docker run -d --name consul-server -h consul-server \
      -p "${PUBLIC_IP}":8300:8300 \
      -p "${PUBLIC_IP}":8301:8301 \
      -p "${PUBLIC_IP}":8301:8301/udp \
      -p "${PUBLIC_IP}":8302:8302 \
      -p "${PUBLIC_IP}":8302:8302/udp \
      -p "${PUBLIC_IP}":8400:8400 \
      -p "${PUBLIC_IP}":${consul_api_port}:${consul_api_port} \
      -p ${docker_bridge_ip}:${consul_dns_port}:${consul_dns_port}/udp \
      -e "SERVICE_${consul_api_port}_NAME=consul-api" \
      -e "SERVICE_${consul_dns_port}_NAME=consul-dns" \
      -e "DOCKER_HOST=${DOCKER_HOST}" \
      progrium/consul -server -advertise "${PUBLIC_IP}" -bootstrap-expect ${consul_nodes}
else
  consul_server_ip=192.168.33.10

  docker kill consul-agent
  docker rm consul-agent

  echo "Starting a Consul agent..."
  docker run -d --name consul-agent -h consul-agent \
      -p "${PUBLIC_IP}":8300:8300 \
      -p "${PUBLIC_IP}":8301:8301 \
      -p "${PUBLIC_IP}":8301:8301/udp \
      -p "${PUBLIC_IP}":8302:8302 \
      -p "${PUBLIC_IP}":8302:8302/udp \
      -p "${PUBLIC_IP}":8400:8400 \
      -p "${PUBLIC_IP}":${consul_api_port}:${consul_api_port} \
      -p ${docker_bridge_ip}:${consul_dns_port}:${consul_dns_port}/udp \
      -e "SERVICE_${consul_api_port}_NAME=consul-api" \
      -e "SERVICE_${consul_dns_port}_NAME=consul-dns" \
      -e "DOCKER_HOST=${DOCKER_HOST}" \
      progrium/consul -server -advertise ${PUBLIC_IP} -join ${consul_server_ip}
fi

run_status=$?

[[ ${run_status} != 0 ]] && echo "Error: Failed to start consul" && exit ${run_status}
[[ ${run_status} == 0 ]] && echo "Consul started @ http://${PUBLIC_IP}:${consul_api_port}/ui"
