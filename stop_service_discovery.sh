#!/bin/bash

container_whitelist="(consulserver|registrator)"

docker ps | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker kill {}
docker ps -a | grep -E "${container_whitelist}" | awk '{print $1}' | xargs -I {} docker rm --force {}
