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

--------------------------------
Subsequent Runs & Post Clean-up
--------------------------------

Execution of the **900-use-it.sh** script results in the creation of 4 heat stacks and a unique
keypair enabling access to a newly created VM.  Subsequent runs of the **900-use-it.sh** script
requires deletion of the stacks, a keypair, and key files, generated during the initial script
execution.

The following steps serve as a guide to clean-up the client environment by deleting stacks and
respective artifacts created during the **900-use-it.sh** script:

1. List the stacks created during script execution which will need to be deleted::

    sudo openstack --os-cloud openstack_helm stack list
    # Sample results returned for *Stack Name* include:
    #    - heat-vm-volume-attach
    #    - heat-basic-vm-deployment
    #    - heat-subnet-pool-deployment
    #    - heat-public-net-deployment

2. Delete the stacks returned from the *openstack helm stack list* command above::

    sudo openstack --os-cloud openstack_helm stack delete heat-vm-volume-attach
    sudo openstack --os-cloud openstack_helm stack delete heat-basic-vm-deployment
    sudo openstack --os-cloud openstack_helm stack delete heat-subnet-pool-deployment
    sudo openstack --os-cloud openstack_helm stack delete heat-public-net-deployment

3. List the keypair(s) generated during the script execution::

    sudo openstack --os-cloud openstack_helm keypair list
    # Sample Results returned for “Name” include:
    #    - heat-vm-key

4. Delete the keypair(s) returned from the list command above::

    sudo openstack --os-cloud openstack_helm keypair delete heat-vm-key

5. Manually remove the keypair directories created from the script in the ~/.ssh directory::

    cd ~/.ssh
    rm osh_key
    rm known_hosts

6.  As a final validation step, re-run the **openstack helm stack list** and
    **openstack helm keypair list** commands and confirm the returned results are shown as empty.::

        sudo openstack --os-cloud openstack_helm stack list
        sudo openstack --os-cloud openstack_helm keypair list

Alternatively, these steps can be performed by running the script directly::

./tools/deployment/developer/common/910-clean-it.sh