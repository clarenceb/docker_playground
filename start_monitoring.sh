#!/bin/bash
#
# Starts the monitoring infrastructure.

cwd=`pwd`
public_ip=`ip addr show eth1 | grep inet | awk '{print $2}' | cut -d "/" -f 1 | head -n 1`

prometheus_server_port=9090
prometheus_config_path=${cwd}
prometheus_config_file="prometheus.yml"
prometheus_rules_path="${cwd}"
prometheus_rules_file="demo_services.rules"
alertmanager_config_file="/alertmanager/alertmanager.conf"
alertmanager_silences_file="/alertmanager/silences.json"
container_exporter_port=9104
consul_server_port=8500
consul_exporter_port=9107
alertmanager_port=9093
prometheus_dash_port=3000

./stop_monitoring.sh

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
docker run -d \
  --name alertmanager \
  -p ${alertmanager_port}:${alertmanager_port} \
  --restart=on-failure:10 \
  -v ${prometheus_config_path}:/alertmanager \
  prom/alertmanager \
  -config.file=${alertmanager_config_file} \
  -silences.file=${alertmanager_silences_file}

# Start Prometheus server
docker run -d \
  --name prometheus_server \
  -h localhost \
  -p ${prometheus_server_port}:${prometheus_server_port} \
  -v ${prometheus_config_path}/${prometheus_config_file}:/${prometheus_config_file} \
  -v ${prometheus_rules_path}/${prometheus_rules_file}:/${prometheus_rules_file} \
  prom/prometheus \
  -config.file=/${prometheus_config_file} \
  -alertmanager.url=http://${public_ip}:${alertmanager_port}

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
   --consul.server="${public_ip}:${consul_server_port}"

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
