======================
Development Deployment
======================

Deploy Local Docker Registry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/010-deploy-docker-registry.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/010-deploy-docker-registry.sh

Deploy Cluster and Namespace Ingress Controllers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/020-ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/020-ingress.sh

  Deploy Ceph
  ^^^^^^^^^^^

  .. literalinclude:: ../../../../tools/deployment/developer/ceph/030-ceph.sh
      :language: shell
      :lines: 1,17-

  Alternatively, this step can be performed by running the script directly:

  .. code-block:: shell

    ./tools/deployment/developer/ceph/030-ceph.sh

  Activate the OSH-Infra namespace to be able to use Ceph
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  .. literalinclude:: ../../../../tools/deployment/developer/ceph/035-ceph-ns-activate.sh
      :language: shell
      :lines: 1,17-

  Alternatively, this step can be performed by running the script directly:

  .. code-block:: shell

    ./tools/deployment/developer/ceph/035-ceph-ns-activate.sh

Deploy LDAP
^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/040-ldap.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/040-ldap.sh

Deploy MariaDB
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/045-mariadb.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/045-mariadb.sh

Deploy Prometheus
^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/050-prometheus.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/050-prometheus.sh

Deploy Alertmanager
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/060-alertmanager.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/060-alertmanager.sh

Deploy Kube-State-Metrics
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/070-kube-state-metrics.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/070-kube-state-metrics.sh

Deploy Node Exporter
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/080-node-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/080-node-exporter.sh

Deploy Process Exporter
^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/090-process-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/090-process-exporter.sh

Deploy Grafana
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/100-grafana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/100-grafana.sh

Deploy Nagios
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/110-nagios.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/110-nagios.sh

Deploy Elasticsearch
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/120-elasticsearch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/120-elasticsearch.sh

Deploy Fluent-Logging
^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/130-fluent-logging.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/130-fluent-logging.sh

Deploy Kibana
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/140-kibana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/140-kibana.sh
