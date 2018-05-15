====================
Multinode Deployment
====================

Deploy Local Docker Registry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/010-deploy-docker-registry.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/010-deploy-docker-registry.sh

Deploy NFS Provisioner for LMA Services
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/020-lma-nfs-provisioner.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/020-lma-nfs-provisioner.sh

Deploy LDAP
^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/030-ldap.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/030-ldap.sh

Deploy Prometheus
^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/040-prometheus.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/040-prometheus.sh

Deploy Alertmanager
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/050-alertmanager.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/050-alertmanager.sh

Deploy Kube-State-Metrics
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/060-kube-state-metrics.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/060-kube-state-metrics.sh

Deploy Node Exporter
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/070-node-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/070-node-exporter.sh

Deploy OpenStack Exporter
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/080-openstack-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/080-openstack-exporter.sh

Deploy Grafana
^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/090-grafana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/090-grafana.sh

Deploy Nagios
^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/100-nagios.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/100-nagios.sh

Deploy Elasticsearch
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/110-elasticsearch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/110-elasticsearch.sh

Deploy Fluent-Logging
^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/120-fluent-logging.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/120-fluent-logging.sh

Deploy Kibana
^^^^^^^^^^^^^

.. literalinclude:: ../../../tools/deployment/multinode/130-kibana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/130-kibana.sh
