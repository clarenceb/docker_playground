#!/bin/bash

public_ip=`ip addr show eth1 | grep inet | awk '{print $2}' | cut -d "/" -f 1 | head -n 1`
consul_api_port=8500
consul_dns_port=53
consul_url="consul://${public_ip}:${consul_api_port}"

./stop_service_discovery.sh

# Start a Consul server (/var/run/docker.sock is needed for ./bin/check-http healthcheck script)
docker run -d --name consulserver -h consulserver \
    -p ${consul_api_port}:${consul_api_port} \
    -p ${consul_dns_port}:${consul_dns_port}/udp \
    -e "SERVICE_${consul_api_port}_NAME=consul-api" \
    -e "SERVICE_${consul_dns_port}_NAME=consul-dns" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    progrium/consul -server -advertise "${public_ip}" -bootstrap -ui-dir /ui > /dev/null

echo "Consul started: http://${public_ip}:${consul_api_port}/ui"
sleep 2

# Start Registrator (https://github.com/progrium/registrator)
docker run -d --name registrator -h registrator \
    -v /var/run/docker.sock:/tmp/docker.sock \
    progrium/registrator "consul://${public_ip}:${consul_api_port}" > /dev/null

echo "Registrator started against Consul at ${consul_url}."
