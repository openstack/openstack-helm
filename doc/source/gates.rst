====================
OpenStack-Helm Gates
====================

To facilitate ease of testing and debugging, information regarding gates and
their functionality can be found here.

OpenStack-Helm's single node and multinode gates leverage the kubeadm-aio
environment created and maintained for use as a development environment.  All
information regarding the kubeadm-aio environment can be found here_.

.. _here: https://docs.openstack.org/openstack-helm/latest/install/developer/index.html

Gate Checks
-----------

OpenStack-Helm currently checks the following scenarios:

- Testing any documentation changes and impacts.
- Running Make on each chart, which lints and packages the charts.  This gate
  does not stand up a Kubernetes cluster.
- Provisioning a single node cluster and deploying the OpenStack services.  This
  check is provided for: Ubuntu-1604, CentOS-7, and Fedora-25.
- Provisioning a multi-node Ubuntu-1604 cluster and deploying the OpenStack
  services. This check is provided for both a two node cluster and a three
  node cluster.


Gate Functions
--------------

To provide reusable components for gate functionality, functions have been
provided in the gates/funcs directory. These functions include:

- Functions for common host preparation operations, found in common.sh
- Functions for Helm specific operations, found in helm.sh.  These functions
  include: installing Helm, serving a Helm repository locally, linting and
  building all Helm charts, running Helm tests on a release, installing the
  helm template plugin, and running the helm template plugin against a chart.
- Functions for Kubernetes specific operations, found in kube.sh.  These
  functions include: waiting for pods in a specific namespace to register as
  ready, waiting for all nodes to register as ready, install the requirements
  for the kubeadm-aio container used in the gates, building the kubeadm-aio
  container, launching the kubeadm-aio container, and replacing the
  kube-controller-manager with a specific image necessary for ceph functionality.
- Functions for network specific operations, found in network.sh.  These
  functions include: creating a backup of the host's resolv.conf file before
  deploying the kubeadm environments, restoring the original resolv.conf
  settings, creating a backup of the host's /etc/hosts file before adding the
  hosts interface and address, and restoring the original /etc/hosts file.
- Functions for OpenStack specific operations, found in openstack.sh.  These
  functions include: waiting for a successful ping, and waiting for a booted
  virtual machine's status to return as ACTIVE.

Any additional functions required for testing new charts or improving the gate
workflow should be placed in the appropriate location.


Gate Output
-----------

To provide meaningful output from the gates, all information pertaining to the
components of the cluster and workflow are output to the logs directory inside
each gate.  The contents of the log directory are as follows:

- The dry-runs directory contains the rendered output of Helm dry-run installs
  on each of the OpenStack service charts.  This gives visibility into the
  manifests created by the templates with the supplied values.  When the dry-run
  gate fails, the reason should be apparent in the dry-runs output.  The logs
  found here are helpful in identifying issues resulting from using helm-toolkit
  functions incorrectly or other rendering issues with gotpl.
- The K8s directory contains the logs and output of the Kubernetes objects.  It
  includes: pods, nodes, secrets, services, namespaces, configmaps, deployments,
  daemonsets, and statefulsets.  Descriptions for the state of all resources
  during execution are found here, and this information can prove valuable when
  debugging issues raised during a check.  When a single node or multi-node
  check fails, this is the first place to look.  The logs found here are helpful
  when the templates render correctly, but the services are not functioning
  correctly, whether due to service configuration issues or issues with the
  pods themselves.
- The nodes directory contains information about the node the gate tests are
  running on in openstack-infra.  This includes: the network interfaces, the
  contents of iptables, the host's resolv.conf, and the kernel IP routing table.
  These logs can be helpful when trying to identify issues with host networking
  or other issues at the node level.


Adding Services
---------------

As charts for additional services are added to OpenStack-Helm, they should be
included in the gates.  Adding new services to the gates allows a chart
developer and the review team to identify any potential issues associated with
a new service. All services are currently launched in the gate via
a series of launch scripts of the format ``NNN-service-name.sh`` where ``NNN``
dictates the order these scripts are launched. The script should contain
an installation command like:

::

    helm install --namespace=openstack ${WORK_DIR}/mistral --name=mistral

Some services in the gate require specific overrides to the default values in
the chart's values.yaml file.  If a service requires multiple overrides to
function in the gate, the service should include a separate values.yaml file
placed in the tools/overrides/mvp directory.  The <service>.yaml MVP files
provide a configuration file to use for overriding default configuration values
in the chart's values.yaml as an alternative to overriding individual values
during installation.  A chart that requires a MVP overrides file
requires the following format:

::

    helm install --namespace=openstack ${WORK_DIR}/cinder --name=cinder \
    --values=${WORK_DIR}/tools/overrides/mvp/cinder.yaml


Adding Tests
------------

As new charts are developed and the services are added to the gate, an
associated Helm test should be introduced to the gates.  The appropriate place
for executing these tests is in the respective service's launch script, and
must be placed after the entry for installing the service and any associated
overrides.  Any tests that use the Rally testing framework should leverage the
helm_test_deployment function in the aforementioned funcs/helm.sh file. For
example, a Helm test for Mistral might look like:

::

    helm_test_deployment mistral 600

This results in the gate running the following:

::

    helm test --timeout 600 mistral
    mkdir -p logs/rally
    kubectl logs -n openstack mistral-rally-test > logs/rally/mistral
    kubectl delete -n openstack pod mistral-rally-test

Any tests that do not use the Rally testing framework would need to be handled
in the appropriate manner in launch script. This would ideally result in new
functions that could be reused, or expansion of the gate scripts to include
scenarios beyond basic service launches.
