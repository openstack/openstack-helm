=======================
Cleaning the Deployment
=======================

Removing Helm Charts
====================

To delete an installed helm chart, use the following command:

.. code-block:: shell

  helm delete ${RELEASE_NAME} --purge

This will delete all Kubernetes resources generated when the chart was
instantiated. However for OpenStack charts, by default, this will not delete
the database and database users that were created when the chart was installed.
All OpenStack projects can be configured such that upon deletion, their database
will also be removed. To delete the database when the chart is deleted the
database drop job must be enabled before installing the chart. There are two
ways to enable the job, set the job_db_drop value to true in the chart's
values.yaml file, or override the value using the helm install command as
follows:

.. code-block:: shell

  helm install ${RELEASE_NAME} --set manifests.job_db_drop=true


Environment tear-down
=====================

To tear-down, the development environment charts should be removed firstly from
the 'openstack' namespace and then the 'ceph' namespace using the commands from
the `Removing Helm Charts`_ section. Once this has been done the namespaces
themselves can be cleaned by running:

.. code-block:: shell

  kubectl delete namespace <namespace_name>

Final cleanup of the development environment is then performed by removing the
``/var/lib/openstack-helm`` directory from the host. This will restore the
environment back to a clean Kubernetes deployment, that can either be manually
removed or over-written by restarting the deployment process.
