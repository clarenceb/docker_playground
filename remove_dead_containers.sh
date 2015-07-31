#!/bin/bash

# Workaround for known issue with Consul - https://github.com/progrium/docker-consul/issues/45
# We are configuruing service health check endpoints through Registrator metadata
# Consul starts a new container for performing these health checks,
# and these containers are not cleared properly. As there are some zombie processes,
# the containers are not cleared.

docker ps -a -q -f 'status=dead' | xargs -I {} docker rm {}

