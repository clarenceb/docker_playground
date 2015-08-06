Introduction to Prometheus for monitoring container-based applications and services
===================================================================================

Presentation material for [Infracoders August Meetup](http://www.meetup.com/Infrastructure-Coders/events/224196792/).

Source code for shop-app, catalogue, review services not provided yet.

Steps to get app and services running in a Docker Swarm cluster:
----------------------------------------------------------------

Spin up the 2 VMs (promserver and server02)

    vagrant up

Configure a Docker Swarm cluster using the 2 VMs

    ./configure_cluster.sh

Open a SSH terminal to `promserver` and source Docker environment

    vagrant ssh promserver
    cd /vagrant
    source swarm_scripts/common_env.sh

Check both VMs appear in the swarm and that no app/services are running yet

    swarm_scripts/list_swarm_nodes.sh
    swarm_scripts/docker_swarm_ps.sh

Build the Docker images (on promserver)

    ./package.sh
    exit

Open a SSH terminal to `server02` and source Docker environment

    vagrant ssh server02
    cd /vagrant
    source swarm_scripts/common_env.sh

Build the Docker images (on promserver)

    ./package.sh
    exit

Open a SSH terminal to `promserver` and source Docker environment

    vagrant ssh promserver
    cd /vagrant
    source swarm_scripts/common_env.sh

Run the app plus 4 x review and 4 x catalogue services (on random ephemeral ports)

    ./run_app_swarm.sh 4
    swarm_scripts/docker_swarm_ps.sh
    exit

Verify the shop-app works (open http://localhost:8080/ in a browser on your host)

    open http://localhost:8080/

Verify Consul is showing the services correctly (open http://192.168.33.10:8500/ui/#/dc1/services in a browser on your host)

    open http://192.168.33.10:8500/ui/#/dc1/services

All should be green - healthy.

Start Monitoring
----------------

TODO

Resources:
----------
* [Monitoring Docker services with Prometheus](https://labs.ctl.io/monitoring-docker-services-with-prometheus/)
