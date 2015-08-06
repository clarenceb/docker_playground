#!/bin/bash

script_dir="/vagrant/swarm_scripts"

echo "Setup Docker engine to listen on TCP port"
vagrant ssh promserver -c "sudo ${script_dir}/docker_tcp_config.sh"
vagrant ssh server02 -c "sudo ${script_dir}/docker_tcp_config.sh"

echo "Starting Consul cluster"
vagrant ssh promserver -c "sudo bash -c '${script_dir}/start_consul.sh server'"
vagrant ssh server02 -c "sudo bash -c '${script_dir}/start_consul.sh agent'"

echo "Starting Registrator"
vagrant ssh promserver -c "sudo ${script_dir}/start_registrator.sh"
vagrant ssh server02 -c "sudo ${script_dir}/start_registrator.sh"

echo "Starting Swarm Manager"
vagrant ssh promserver -c "sudo ${script_dir}/start_swarm_manager.sh"

echo "Starting Swarm Nodes"
vagrant ssh promserver -c "sudo bash -c '${script_dir}/join_swarm_node.sh 1'"
vagrant ssh server02 -c "sudo bash -c '${script_dir}/join_swarm_node.sh 2'"

echo "Installing cleanup cron jobs"
vagrant ssh promserver -c "sudo /vagrant/install_cron_job.sh"
vagrant ssh server02 -c "sudo /vagrant/install_cron_job.sh"

echo "Listing Swarm Nodes"
vagrant ssh promserver -c "${script_dir}/list_swarm_nodes.sh"

echo "Done."
