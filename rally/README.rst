=====
Rally
=====

This chart provides a benchmarking tool for OpenStack services that
allows us to test our cloud at scale. This chart leverages the Kolla
image for Rally and includes a templated configuration file that
allows configuration overrides similar to other charts in OpenStack-Helm.
You can choose which services to benchmark by changing the services
listed in the ``values.yaml`` file under the ``enabled_tests`` key.

Installation
------------

This chart can be deployed by running the following command:

::
    helm install --name=rally ./rally --namespace=openstack


This will install Rally into your cluster appropriately. When you run
this install command, the chart will bring up a few jobs that will
complete the benchmarking of the OpenStack services that you have
specified.
