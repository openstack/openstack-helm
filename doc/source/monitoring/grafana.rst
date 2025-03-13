Grafana
=======

The Grafana chart in OpenStack-Helm Infra provides default dashboards for the
metrics gathered with Prometheus.  The default dashboards include visualizations
for metrics on: Ceph, Kubernetes, nodes, containers, MySQL, RabbitMQ, and
OpenStack.

Configuration
-------------

Grafana
~~~~~~~

Grafana's configuration is driven with the chart's values.YAML file, and the
relevant configuration entries are under the following key:

::

    conf:
      grafana:
        paths:
        server:
        database:
        session:
        security:
        users:
        log:
        log.console:
        dashboards.json:
        grafana_net:

These keys correspond to sections in the grafana.ini configuration file, and the
to_ini helm-toolkit function will render these values into the appropriate
format in grafana.ini.  The list of options for these keys can be found in the
official Grafana configuration_ documentation.

.. _configuration: https://grafana.com/docs/installation/configuration/

Prometheus Data Source
~~~~~~~~~~~~~~~~~~~~~~

Grafana requires configured data sources for gathering metrics for display in
its dashboards.  The configuration options for datasources are found under the
following key in Grafana's values.YAML file:

::

    conf:
      provisioning:
        datasources;
          monitoring:
            name: prometheus
            type: prometheus
            access: proxy
            orgId: 1
            editable: true
            basicAuth: true

The Grafana chart will use the keys under each entry beneath
.conf.provisioning.datasources as inputs to a helper template that will render
the appropriate configuration for the data source.  The key for each data source
(monitoring in the above example) should map to an entry in the endpoints
section in the chart's values.yaml, as the data source's URL and authentication
credentials will be populated by the values defined in the defined endpoint.

.. _sources: https://grafana.com/docs/features/datasources/

Dashboards
~~~~~~~~~~

Grafana adds dashboards during installation with dashboards defined in YAML under
the following key:

::

    conf:
      dashboards:


These YAML definitions are transformed to JSON are added to Grafana's
configuration configmap and mounted to the Grafana pods dynamically, allowing for
flexibility in defining and adding custom dashboards to Grafana.  Dashboards can
be added by inserting a new key along with a YAML dashboard definition as the
value.  Additional dashboards can be found by searching on Grafana's dashboards_
page or you can define your own. A json-to-YAML tool, such as json2yaml_ , will
help transform any custom or new dashboards from JSON to YAML.

.. _json2yaml: https://www.json2yaml.com/
