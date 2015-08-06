#!/bin/bash
#
# Start services and app in a Docker Swarm.

set -e

basedir=$(readlink -f $(dirname $0))
service_count=${1:-1}

source ${basedir}/swarm_scripts/common_env.sh

./stop_app_swarm.sh

for i in `seq 1 ${service_count}`;
do
  echo "Start review service: ${i}"
  docker -H ${DOCKER_SWARM_HOST} run -d \
    -p :8082 \
    -p :8083 \
    --name "review-${i}" \
    --hostname review \
    -e "SERVICE_8082_NAME=review-service" \
    -e "SERVICE_8083_NAME=review-service-admin" \
    -e "SERVICE_8083_CHECK_HTTP=/healthcheck" \
    -e "SERVICE_8083_CHECK_INTERVAL=5s" \
    review:latest
done

for i in `seq 1 ${service_count}`;
do
  echo "Start catalogue service: ${i}"
  docker -H ${DOCKER_SWARM_HOST} run -d \
    -p :8084 \
    -p :8085 \
    --name "catalogue-${i}" \
    --hostname catalogue \
    -e "SERVICE_8084_NAME=catalogue-service" \
    -e "SERVICE_8085_NAME=catalogue-service-admin" \
    -e "SERVICE_8085_CHECK_HTTP=/healthcheck" \
    -e "SERVICE_8085_CHECK_INTERVAL=5s" \
    catalogue:latest
done

echo "Start shop-app"
docker -H ${DOCKER_SWARM_HOST} run -d \
  -p 8080:8080 \
  -p 8081:8081 \
  --name shop-app \
  --hostname shop-app \
  -e "SERVICE_8080_NAME=shop-application" \
  -e "SERVICE_8081_NAME=shop-application-admin" \
  -e "SERVICE_8081_CHECK_HTTP=/healthcheck" \
  -e "SERVICE_8081_CHECK_INTERVAL=5s" \
  -e "constraint:node==promserver" \
  shop-app:latest
