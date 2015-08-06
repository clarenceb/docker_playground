#!/bin/bash
#
# Workaround for bug in Docker image: progrium/consul
# It leaves behind containers in 'dead' state after running service health checks.
# See: https://github.com/progrium/docker-consul/issues/45

# Remove crontab
crontab -r

# Add new cron task
echo "*/1 * * * * /vagrant/remove_dead_containers.sh >> /home/vagrant/remove_dead_containers.log 2>&1 " >> /tmp/mycron

# Install new cron file
crontab /tmp/mycron
rm /tmp/mycron
