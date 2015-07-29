#!/bin/bash
#
# Stops the monitoring infrastructure.

container_whitelist="(prometheus_server|prometheus_dash|container_exporter|consul_exporter|alertmanager)"

docker ps | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker kill {}
docker ps -a | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker rm --force {}

# Cleanup Prometheus Dashboard sqlite3 DB
sudo rm -rf /tmp/prom
