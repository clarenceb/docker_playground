#!/bin/bash

set -e

echo "PACKAGE - Start..."

# Define commonly used JAVA_HOME variable
export JAVA_HOME=/usr/lib/jvm/java-8-oracle

repos="`cat repos.txt`"
workspace_dir="/vagrant"

for repo_name in ${repos}; do
  pushd ${workspace_dir}/${repo_name}

  # Build docker image
  mvn clean package -Dmaven.test.skip=true

  popd
done

echo "PACKAGE - Done."
