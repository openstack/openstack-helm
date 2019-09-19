Kibana
======

The Kibana chart in OpenStack-Helm Infra provides visualization for logs indexed
into Elasticsearch.  These visualizations provide the means to view logs captured
from services deployed in cluster and targeted for collection by Fluentbit.

Authentication
--------------

The Kibana deployment includes a sidecar container that runs an Apache reverse
proxy to add authentication capabilities for Kibana.  The username and password
are configured under the Kibana entry in the endpoints section of the chart's
values.yaml.

The configuration for Apache can be found under the conf.httpd key, and uses a
helm-toolkit function that allows for including gotpl entries in the template
directly.  This allows the use of other templates, like the endpoint lookup
function templates, directly in the configuration for Apache.

Configuration
-------------

Kibana's configuration is driven by the chart's values.yaml file.  The configuration
options are found under the following keys:

::

    conf:
      elasticsearch:
        pingTimeout: 1500
        preserveHost: true
        requestTimeout: 30000
        shardTimeout: 0
        startupTimeout: 5000
      i18n:
        defaultLocale: en
      kibana:
        defaultAppId: discover
        index: .kibana
      logging:
        quiet: false
        silent: false
        verbose: false
      ops:
        interval: 5000
      server:
        host: localhost
        maxPayloadBytes: 1048576
        port: 5601
        ssl:
          enabled: false

The case of the sub-keys is important as these values are injected into
Kibana's configuration configmap with the toYaml function.  More information on
the configuration options and available settings can be found in the official
Kibana documentation_.

.. _documentation: https://www.elastic.co/guide/en/kibana/current/settings.html

Installation
------------

.. code_block: bash

helm install --namespace=<namespace> local/kibana --name=kibana

Setting Time Field
------------------

For Kibana to successfully read the logs from Elasticsearch's indexes, the time
field will need to be manually set after Kibana has successfully deployed.  Upon
visiting the Kibana dashboard for the first time, a prompt will appear to choose the
time field with a drop down menu.  The default time field for Elasticsearch indexes
is '@timestamp'.  Once this field is selected, the default view for querying log entries
can be found by selecting the "Discover"
