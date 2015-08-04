#!/bin/bash
#
# Start services and app.

set -e

./stop_app.sh

docker run -d \
  -p 8082:8082 \
  -p 8083:8083 \
  --name review \
  --hostname review \
  -e "SERVICE_8082_NAME=review-service" \
  -e "SERVICE_8083_NAME=review-service-admin" \
  -e "SERVICE_8083_CHECK_HTTP=/healthcheck" \
  -e "SERVICE_8083_CHECK_INTERVAL=5s" \
  review:latest

docker run -d \
  -p 8084:8084 \
  -p 8085:8085 \
  --name catalogue \
  --hostname catalogue \
  -e "SERVICE_8084_NAME=catalogue-service" \
  -e "SERVICE_8085_NAME=catalogue-service-admin" \
  -e "SERVICE_8085_CHECK_HTTP=/healthcheck" \
  -e "SERVICE_8085_CHECK_INTERVAL=5s" \
  catalogue:latest

docker run -d \
  -p 8080:8080 \
  -p 8081:8081 \
  --name shop-app \
  --hostname shop-app \
  -e "SERVICE_8080_NAME=shop-application" \
  -e "SERVICE_8081_NAME=shop-application-admin" \
  -e "SERVICE_8081_CHECK_HTTP=/healthcheck" \
  -e "SERVICE_8081_CHECK_INTERVAL=5s" \
  shop-app:latest
