#!/bin/sh

echo "Getting dependencies..."

sudo apt-get update
sudo apt-get install -y git software-properties-common python-software-properties

# install JDK 8
sudo bash -c "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
apt-get install -y oracle-java8-installer"

# Install maven
sudo apt-get install -y --force-yes maven
