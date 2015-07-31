#!/bin/bash
#
# Stop services and app.

container_whitelist="(shop|review|catalogue)"

docker ps | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker kill {}
docker ps -a | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker rm --force {}
