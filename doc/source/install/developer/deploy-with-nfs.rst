======================
Development Deployment
======================

Deploy Local Docker Registry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/010-deploy-docker-registry.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/010-deploy-docker-registry.sh

Deploy Cluster and Namespace Ingress Controllers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/020-ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/020-ingress.sh

Deploy NFS Provisioner
^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/030-nfs-provisioner.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/030-nfs-provisioner.sh

Deploy LDAP
^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/040-ldap.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/040-ldap.sh

Deploy MariaDB
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/045-mariadb.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/045-mariadb.sh

Deploy Prometheus
^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/050-prometheus.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/050-prometheus.sh

Deploy Alertmanager
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/060-alertmanager.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/060-alertmanager.sh

Deploy Kube-State-Metrics
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/070-kube-state-metrics.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/070-kube-state-metrics.sh

Deploy Node Exporter
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/080-node-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/080-node-exporter.sh

Deploy Process Exporter
^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/090-process-exporter.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/090-process-exporter.sh

Deploy Grafana
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/100-grafana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/100-grafana.sh

Deploy Nagios
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/110-nagios.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/110-nagios.sh

Deploy Elasticsearch
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/120-elasticsearch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/120-elasticsearch.sh

Deploy Fluent-Logging
^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/130-fluent-logging.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/130-fluent-logging.sh

Deploy Kibana
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/nfs/140-kibana.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/nfs/140-kibana.sh
