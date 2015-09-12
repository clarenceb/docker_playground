Introduction to Prometheus for monitoring container-based applications and services
===================================================================================

Presentation material for [Infracoders September Meetup](http://www.meetup.com/Infrastructure-Coders/events/224551202/).

*Note*: Source code for shop-app, catalogue, review services not provided yet.

This demo uses a Docker-based app and services.  The app + services use a combination of [Registrator](http://gliderlabs.com/registrator/latest/) and [Consul](https://www.consul.io/) for Service Discovery.

[Prometheus](http://prometheus.io/) is used to monitor the containers via health metrics exported from [consul_exporter](https://github.com/prometheus/consul_exporter).

Steps to get app and services running in a Docker Swarm cluster:
----------------------------------------------------------------

Spin up the 2 VMs (`promserver` and `server02`)

    $ vagrant up --provision

Configure a Docker Swarm cluster using the 2 VMs

    $ ./configure_cluster.sh

Open a SSH terminal to `promserver` and source Docker environment:

    $ vagrant ssh promserver
    vagrant@promserver$ cd /vagrant
    vagrant@promserver$ source swarm_scripts/common_env.sh

Check both VMs appear in the swarm and that no app/services are running yet

    vagrant@promserver$ swarm_scripts/list_swarm_nodes.sh
    vagrant@promserver$ swarm_scripts/docker_swarm_ps.sh

Run the `shop-app` plus 4 x `review` and 4 x `catalogue` services (on random ephemeral ports)

    vagrant@promserver$ ./run_app_swarm.sh 4
    vagrant@promserver$ swarm_scripts/docker_swarm_ps.sh

Verify the shop-app works (open http://localhost:8080/ in a browser on your host)

Verify Consul is showing the services correctly (open http://192.168.33.10:8500/ui/#/dc1/services in a browser on your host)

All should be green - i.e. healthy.

Start Monitoring
----------------

Back in your `promserver` terminal, start monitoring via the provided script:

    vagrant@promserver$ ./start_monitoring.sh
    vagrant@promserver$ swarm_scripts/docker_swarm_ps.sh

View Prometheus server in your browser (open http://localhost:9090/ in a browser on your host)

In Prometheus server, click the **Alerts** tab to see current alert statuses.

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

If you want to see alarms fire try stopping services, e.g.:

    vagrant@promserver$ docker -H ${DOCKER_SWARM_HOST} stop review-1
    vagrant@promserver$ docker -H ${DOCKER_SWARM_HOST} stop review-2

    # Wait about 30s, then review health warning alarm should fire.

If you stop all the review service instances then you should see an alarm firing that indicates that the shop application is unhealthy.

Note: If you want Slack notifications to appear you will need to create a Slack account (its free) and then set up an [incoming webhook](https://api.slack.com/incoming-webhooks).

Once you have the webhook url, update the the following line in file `conf/alertmanager.conf`:

    webhook_url: "INSERT_YOUR_INCOMING_WEB_HOOK_URL"

Restart the `alertmanager` for the change to take effect:

    vagrant@promserver$ docker -H ${DOCKER_SWARM_HOST} restart alertmanager

**Tip**: *Do not commit your webhook url to your git repository.*

**Alarm behaviour**

**Review** Service:
  * If you stop `review` service instances such that there are 2 or less left then the `review` service will report as unhealthy.
  * If you stop all `review` instances then the `review` service will report as down.

**Catalogue** Service:
  * If you stop `catalogue` instances such that there are 2 or less left then the `catalogue` service will report as unhealthy.
  * If you stop all `catalogue` instances then the `catalogue` service will report as down.

**Shop** Application:
  * If you stop all instances of either `review` and/or `catalogue` service then the `shop-app` will report that it is unhealthy (since its healthcheck incorporates finding a healthy review and catalogue service instance)
  * If you stop the `shop-app` instance then it will report as down.

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
