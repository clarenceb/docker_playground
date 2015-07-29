#!/bin/bash
#
# Starts the monitoring infrastructure.

cwd=`pwd`
public_ip=`ip addr show eth1 | grep inet | awk '{print $2}' | cut -d "/" -f 1 | head -n 1`

prometheus_server_port=9090
prometheus_config_path=${cwd}
prometheus_config_file="prometheus.conf"
prometheus_rules_path="${cwd}"
prometheus_rules_file="workshop_services.rules"
container_exporter_port=9104
consul_server_port=8500
consul_exporter_port=9107
alertmanager_port=9093
prometheus_dash_port=3000

./stop_monitoring.sh

# Start the Prometheus Alert Manager for view/silencing alerts.
# Restart the container in case it crashes (retry for 10 times),
# as alertmanger is still experimental and not a stable production version yet.
docker run -d \
  --name alertmanager \
  -p ${alertmanager_port}:${alertmanager_port} \
  --restart=on-failure:10 \
  -v ${prometheus_config_path}:/alertmanager \
  prom/alertmanager \
  -logtostderr \
  -config.file=/alertmanager/alertmanager.conf

# Start Prometheus server
docker run -d \
  --name prometheus_server \
  -h localhost \
  -p ${prometheus_server_port}:${prometheus_server_port} \
  -v ${prometheus_config_path}/${prometheus_config_file}:/${prometheus_config_file} \
  -v ${prometheus_rules_path}/${prometheus_rules_file}:/${prometheus_rules_file} \
  prom/prometheus \
  -config.file=/${prometheus_config_file} \
  -alertmanager.url=http://${PUBLIC_IP}:9093

# Start the Docker container metrics exporter (for Prometheus server to scrape)
docker run -d \
  --name container_exporter \
  -p ${container_exporter_port}:${container_exporter_port} \
  -v /sys/fs/cgroup:/cgroup \
  -v /var/run/docker.sock:/var/run/docker.sock \
  prom/container-exporter

# Start the Consul Exporter (for Prometheus server to scrape)
docker run -d \
   --name consul_exporter \
   -p ${consul_exporter_port}:${consul_exporter_port} \
   prom/consul-exporter \
   --consul.server="${PUBLIC_IP}:${consul_server_port}"

# Create Prometheus Dashboard database (using a file-based sqlite3 DB)
docker run --rm \
  -p ${prometheus_dash_port}:${prometheus_dash_port} \
  -v /tmp/prom:/tmp/prom \
  -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
  prom/promdash \
  ./bin/rake db:migrate

# Start Proemtheus Dashboard
docker run -d \
  --name prometheus_dash \
  -p ${prometheus_dash_port}:${prometheus_dash_port} \
  -v /tmp/prom:/tmp/prom \
  -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
  prom/promdash

echo ">>>> Public IP address of this machine: ${public_ip}"
echo ">>>> Prometheus Server is accessible at: ${public_ip}:${prometheus_server_port}"
echo ">>>> Prometheus Alert Manager is accessible at: ${public_ip}:${alertmanager_port}"
echo ">>>> Prometheus Dashboard is accessible at: ${public_ip}:${prometheus_dash_port}"
