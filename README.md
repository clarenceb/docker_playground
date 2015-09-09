Introduction to Prometheus for monitoring container-based applications and services
===================================================================================

Presentation material for [Infracoders August Meetup](http://www.meetup.com/Infrastructure-Coders/events/224196792/).

Note: Source code for shop-app, catalogue, review services not provided yet.

This demo uses a Docker-based app and services.  The app + services use a combination of Registrator and Consul for Service Discovery.

Prometheus is used to monitor the containers via health metrics exported from [consul_exporter](https://github.com/prometheus/consul_exporter).

Steps to get app and services running in a Docker Swarm cluster:
----------------------------------------------------------------

Spin up the 2 VMs (promserver and server02)

    vagrant up --provision

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

Verify Consul is showing the services correctly (open http://192.168.33.10:8500/ui/#/dc1/services in a browser on your host)

All should be green - healthy.

Start Monitoring
----------------

Open a SSH terminal to `promserver` and source Docker environment

    vagrant ssh promserver
    cd /vagrant
    source swarm_scripts/common_env.sh

Start monitoring script:

    ./start_monitoring.sh
    exit

View Prometheus server in your browser (open http://localhost:9090/ in a browser on your host)

Click the **Alerts** tab to see current alert statuses.

View Prometheus Alertmanager in your browser (open http://localhost:9093/ in a browser on your host)

No alerts should be firing at the moment.

View Prometheus Dashboard in your browser (open http://localhost:3000/ in a browser on your host)

You need to build a custom dashboard - refer to: http://prometheus.io/docs/visualization/promdash/

Misc
----

Look up healthy service instances for a service in Consul:

Via HTTP:

    # On promserver
    curl -s http://192.168.33.10:8500/v1/catalog/service/review-service | json_pp

Via DNS:

    # On promserver
    dig @172.17.42.1 review-service.service.consul. ANY
    dig @172.17.42.1 review-service.service.consul. SRV

View healthcheck for the shop-app:

    # On promserver
    curl http://192.168.33.10:8081/healthcheck?pretty=true

**Alarm behaviour**

Review Service:
  * If you stop review service instances such that there are 2 or less left then the review service will report as unhealthy.
  * If you stop all review instances then the review service will report as down.

Catalogue Service:
  * If you stop catalogue instances such that there are 2 or less left then the catalogue service will report as unhealthy.
  * If you stop all catalogue instances then the catalogue service will report as down.

Shop Application:
  * If you stop all instances of either review and/or catalogue service then the shop-app will report that it is unhealthy (since its healthcheck incorporates finding a healthy review and catalogue service instance)
  * If you stop the shop-app instance then it will report as down.

Further Learning:
-----------------
* [Monitoring Docker services with Prometheus](https://labs.ctl.io/monitoring-docker-services-with-prometheus/)
* [Prometheus Documentation](http://prometheus.io/docs/introduction/overview/)
* [PromDash](http://prometheus.io/docs/visualization/promdash/)
* [Alertmanager](http://prometheus.io/docs/alerting/alertmanager/)
* [Docker Swarm](https://docs.docker.com/swarm/)
* [Registrator](https://github.com/gliderlabs/registrator)
* [Consul](https://www.consul.io/)
* [consul_exporter](https://github.com/prometheus/consul_exporter)
* [Incoming Webhooks: Send data into Slack in real-time](https://api.slack.com/incoming-webhooks)
* [Alertmanager - Alert Inhibiting Rules](https://github.com/prometheus/alertmanager/blob/master/config/config.proto#L164)
