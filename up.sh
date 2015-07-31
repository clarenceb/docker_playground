#!/bin/bash

# Clean up previous topics.
./down.sh

echo "UP - Start..."

# shop-app uses service discovery
./start_service_discovery.sh

# Package the app
./package.sh

# Run the app and services
./run-app.sh

# Set up cron job to clean up dead containers
./install_cron_job.sh

echo "UP - Done."

