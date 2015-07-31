#!/bin/bash

echo "Down - Start..."

image_whitelist="(shop|review|catalogue)"

# Post - Cleanup
docker ps -q | xargs -I {} docker kill {}
docker ps -a -q | xargs -I {} docker rm --force {}
docker images | grep -E "${image_whitelist}" | awk '{print $3}' | uniq | xargs -I {} docker rmi {}

# Remove crontab
crontab -r

