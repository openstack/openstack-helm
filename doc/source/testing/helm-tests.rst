==========
Helm Tests
==========

Every OpenStack-Helm chart should include any required Helm tests necessary to
provide a sanity check for the OpenStack service.  Information on using the Helm
testing framework can be found in the Helm repository_.  Currently, the Rally
testing framework is used to provide these checks for the core services.  The
Keystone Helm test template can be used as a reference, and can be found here_.

.. _repository: https://github.com/kubernetes/helm/blob/master/docs/chart_tests.md

.. _here: https://github.com/openstack/openstack-helm/blob/master/keystone/templates/pod-rally-test.yaml


Testing Expectations
--------------------

Any templates for Helm tests submitted should follow the philosophies applied in
the other templates.  These include: use of overrides where appropriate, use of
endpoint lookups and other common functionality in helm-toolkit, and mounting
any required scripting templates via the configmap-bin template for the service
chart.  If Rally tests are not appropriate or adequate for a service chart, any
additional tests should be documented appropriately and adhere to the same
expectations.

Running Tests
-------------

Any Helm tests associated with a chart can be run by executing:

::

    helm test <helm-release-name>

The output of the Helm tests can be seen by looking at the logs of the pod
created by the Helm tests.  These logs can be viewed with:

::

    kubectl logs <test-pod-name> -n <namespace>

Additional information on Helm tests for OpenStack-Helm and how to execute
these tests locally via the scripts used in the gate can be found in the
gates_ directory.

.. _gates: https://github.com/openstack/openstack-helm/blob/master/tools/gate/


Adding Tests
------------

All tests should be added to the gates during development, and are required for
any new service charts prior to merging.  All Helm tests should be included as
part of the deployment script.  An example of this can be seen in
this script_.

.. _script: https://github.com/openstack/openstack-helm/blob/9d4f9862ca07f08005f9bdb4e6d58ad770fa4178/tools/deployment/multinode/080-keystone.sh#L32
