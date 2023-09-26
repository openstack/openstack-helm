Deploy ingress controller
=========================

Deploying an ingress controller when deploying OpenStack on Kubernetes
is essential to ensure proper external access and SSL termination
for your OpenStack services.

In the OpenStack-Helm project, we utilize multiple ingress controllers
to optimize traffic routing. Specifically, we deploy three independent
instances of the Nginx ingress controller for distinct purposes:

External Traffic Routing
~~~~~~~~~~~~~~~~~~~~~~~~

* ``Namespace``: kube-system
* ``Functionality``: This instance monitors ingress objects across all
  namespaces, primarily focusing on routing external traffic into the
  OpenStack environment.

Internal Traffic Routing within OpenStack
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``Namespace``: openstack
* ``Functionality``: Designed to handle traffic exclusively within the
  OpenStack namespace, this instance plays a crucial role in SSL
  termination for enhanced security among OpenStack services.

Traffic Routing to Ceph Rados Gateway Service
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``Namespace``: ceph
* ``Functionality``: Dedicated to routing traffic specifically to the
  Ceph Rados Gateway service, ensuring efficient communication with
  Ceph storage resources.

By deploying these three distinct ingress controller instances in their
respective namespaces, we optimize traffic management and security within
the OpenStack-Helm environment.

To deploy these three ingress controller instances use the script `ingress.sh`_

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/common/ingress.sh

.. note::
    These script uses Helm chart from the `openstack-helm-infra`_ repository. We assume
    this repo is cloned to the `~/osh` directory. See this :doc:`section </install/before_deployment>`.

.. _ingress.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/common/ingress.sh
.. _openstack-helm-infra: https://opendev.org/openstack/openstack-helm-infra.git
