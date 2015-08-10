#!/bin/bash
#
# Starts the monitoring infrastructure.

basedir=$(readlink -f $(dirname $0))
source ${basedir}/swarm_scripts/common_env.sh

prometheus_server_port=9090
prometheus_config_path="${basedir}/conf"
prometheus_config_file="prometheus.yml"
prometheus_rules_path="${basedir}/conf"
prometheus_rules_file="demo_services.rules"
alertmanager_config_file="/alertmanager/alertmanager.conf"
alertmanager_silences_file="/alertmanager/silences.json"
container_exporter_port=9104
consul_exporter_port=9107
alertmanager_port=9093
prometheus_dash_port=3000

${basedir}/stop_monitoring.sh

# Start the Prometheus Alert Manager for view/silencing alerts.
# Restart the container in case it crashes (retry for 10 times),
# as alertmanger is still experimental and not a stable production version yet.
# Usage of /bin/alertmanager:
#   -alerts.min-refresh-period=5m0s: Minimum required alert refresh period before an alert is purged.
#   -config.file="alertmanager.conf": Alert Manager configuration file name.
#   -log.level=info: Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal, panic].
#   -notification.buffer-size=1000: Size of buffer for pending notifications.
#   -notification.flowdock.url="https://api.flowdock.com/v1/messages/team_inbox": Flowdock API V1 URL.
#   -notification.hipchat.url="https://api.hipchat.com/v2": HipChat API V2 URL.
#   -notification.pagerduty.url="https://events.pagerduty.com/generic/2010-04-15/create_event.json": PagerDuty API URL.
#   -notification.pushover.retry-expiry-interval=7200: Timeout after which unacknowledged Pushover messages will not be retried further.
#   -notification.pushover.retry-interval=60: Interval in seconds at which Pushover should retry pushing a message to receiving users.
#   -notification.slack.timeout=10: HTTP timeout to talk to Slack (in seconds).
#   -notification.smtp.sender="alertmanager@example.org": Sender email address to use in email notifications.
#   -notification.smtp.smarthost="": Address of the smarthost to send all email notifications to.
#   -silences.file="silences.json": Silence storage file name.
#   -web.external-url="": The URL under which Alertmanager is externally reachable (for example, if Alertmanager is served via a reverse proxy). Used for generating relative and absolute links back to Alertmanager itself. If omitted, relevant URL components will be derived automatically.
#   -web.hostname="": Hostname on which the Alertmanager is available to the outside world.
#   -web.listen-address=":9093": Address to listen on for the web interface and API.
#   -web.path-prefix="/": Prefix for all web paths.
#   -web.use-local-assets=false: Serve assets and templates from local files instead of from the binary.
docker -H ${DOCKER_SWARM_HOST} run -d \
  --name alertmanager \
  -p ${alertmanager_port}:${alertmanager_port} \
  --restart=on-failure:10 \
  -v ${prometheus_config_path}:/alertmanager \
  -e "constraint:node==promserver" \
  prom/alertmanager \
  -config.file=${alertmanager_config_file} \
  -silences.file=${alertmanager_silences_file}

# Start Prometheus server
docker -H ${DOCKER_SWARM_HOST} run -d \
  --name prometheus_server \
  -h localhost \
  -p ${prometheus_server_port}:${prometheus_server_port} \
  -v ${prometheus_config_path}/${prometheus_config_file}:/${prometheus_config_file} \
  -v ${prometheus_rules_path}/${prometheus_rules_file}:/${prometheus_rules_file} \
  -e "constraint:node==promserver" \
  prom/prometheus \
  -config.file=/${prometheus_config_file} \
  -alertmanager.url=http://${PUBLIC_IP}:${alertmanager_port}

# Start the Docker container metrics exporter (for Prometheus server to scrape) - promserver
# Note: Due to the way this exporter works, you need one per Docker hosts to be running.
docker -H ${DOCKER_SWARM_HOST} run -d \
  --name container_exporter_1 \
  -p ${container_exporter_port}:${container_exporter_port} \
  -v /sys/fs/cgroup:/cgroup \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e "constraint:node==promserver" \
  prom/container-exporter

# Start the Docker container metrics exporter (for Prometheus server to scrape) - server02
# Note: Due to the way this exporter works, you need one per Docker hosts to be running.
docker -H ${DOCKER_SWARM_HOST} run -d \
  --name container_exporter_2 \
  -p ${container_exporter_port}:${container_exporter_port} \
  -v /sys/fs/cgroup:/cgroup \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e "constraint:node==server02" \
  prom/container-exporter

# Start the Consul Exporter (for Prometheus server to scrape)
# Note: Since Consul is running in a cluster only one Consul exporter needs to be running.
docker -H ${DOCKER_SWARM_HOST} run -d \
   --name consul_exporter \
   -p ${consul_exporter_port}:${consul_exporter_port} \
   -e "constraint:node==promserver" \
   clarenceb/consul_exporter:0.2.0 \
   --consul.server="${PUBLIC_IP}:${CONSUL_API_PORT}"

# Create Prometheus Dashboard database (using a file-based sqlite3 DB)
docker -H ${DOCKER_SWARM_HOST} run --rm \
  -p ${prometheus_dash_port}:${prometheus_dash_port} \
  -v /tmp/prom:/tmp/prom \
  -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
  -e "constraint:node==promserver" \
  prom/promdash \
  ./bin/rake db:migrate

# Start Proemtheus Dashboard
docker -H ${DOCKER_SWARM_HOST} run -d \
  --name prometheus_dash \
  -p ${prometheus_dash_port}:${prometheus_dash_port} \
  -v /tmp/prom:/tmp/prom \
  -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
  -e "constraint:node==promserver" \
  prom/promdash

echo ">>>> Public IP address of this machine: ${PUBLIC_IP}"
echo ">>>> Prometheus Server is accessible at: ${PUBLIC_IP}:${prometheus_server_port}"
echo ">>>> Prometheus Alert Manager is accessible at: ${PUBLIC_IP}:${alertmanager_port}"
echo ">>>> Prometheus Dashboard is accessible at: ${PUBLIC_IP}:${prometheus_dash_port}"
