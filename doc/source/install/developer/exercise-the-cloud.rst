==================
Exercise the Cloud
==================

Once OpenStack-Helm has been deployed, the cloud can be exercised either with
the OpenStack client, or the same heat templates that are used in the validation
gates.

.. literalinclude:: ../../../../tools/deployment/developer/common/900-use-it.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/common/900-use-it.sh

To run further commands from the CLI manually, execute the following to
set up authentication credentials::

  export OS_CLOUD=openstack_helm

Note that this command will only enable you to auth successfully using the
``python-openstackclient`` CLI. To use legacy clients like the
``python-novaclient`` from the CLI, reference the auth values in
``/etc/openstack/clouds.yaml`` and run::

  export OS_USERNAME='admin'
  export OS_PASSWORD='password'
  export OS_PROJECT_NAME='admin'
  export OS_PROJECT_DOMAIN_NAME='default'
  export OS_USER_DOMAIN_NAME='default'
  export OS_AUTH_URL='http://keystone.openstack.svc.cluster.local/v3'

The example above uses the default values used by ``openstack-helm-infra``.
