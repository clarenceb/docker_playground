#!/bin/bash

base_dir="/vagrant"

echo "Setup Docker engine to listen on TCP port"
vagrant ssh promserver -c "sudo ${base_dir}/swarm_scripts/docker_tcp_config.sh"
vagrant ssh server02 -c "sudo ${base_dir}/swarm_scripts/docker_tcp_config.sh"

echo "Killing and removing all containers"
vagrant ssh promserver -c "${base_dir}/kill_containers.sh"
vagrant ssh server02 -c "${base_dir}/kill_containers.sh"

echo "Starting Consul cluster"
vagrant ssh promserver -c "sudo bash -c '${base_dir}/swarm_scripts/start_consul.sh server'"
vagrant ssh server02 -c "sudo bash -c '${base_dir}/swarm_scripts/start_consul.sh agent'"

echo "Starting Registrator"
vagrant ssh promserver -c "sudo ${base_dir}/swarm_scripts/start_registrator.sh"
vagrant ssh server02 -c "sudo ${base_dir}/swarm_scripts/start_registrator.sh"

echo "Starting Swarm Manager"
vagrant ssh promserver -c "sudo ${base_dir}/swarm_scripts/start_swarm_manager.sh"

echo "Starting Swarm Nodes"
vagrant ssh promserver -c "sudo bash -c '${base_dir}/swarm_scripts/join_swarm_node.sh 1'"
vagrant ssh server02 -c "sudo bash -c '${base_dir}/swarm_scripts/join_swarm_node.sh 2'"

echo "Installing cleanup cron jobs"
vagrant ssh promserver -c "sudo ${base_dir}/install_cron_job.sh"
vagrant ssh server02 -c "sudo ${base_dir}/install_cron_job.sh"

echo "Listing Swarm Nodes"
vagrant ssh promserver -c "${base_dir}/swarm_scripts/list_swarm_nodes.sh"

echo "Done - Ready to deploy containers to cluster."
