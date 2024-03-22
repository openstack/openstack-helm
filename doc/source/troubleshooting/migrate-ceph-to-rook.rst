Migrating Ceph to Rook
^^^^^^^^^^^^^^^^^^^^^^

It may be necessary or desired to migrate an existing `Ceph`_ cluster that was
originally deployed using the Ceph charts in `openstack-helm-infra`_ to be
managed by the Rook operator moving forward. This operation is not a supported
`Rook`_ feature, but it is possible to achieve.

The procedure must completely stop and start all of the Ceph pods a few times
during the migration process and is therefore disruptive to Ceph operations,
but the result is a Ceph cluster deployed and managed by the Rook operator that
maintains the same cluster FSID as the original with all OSD data preserved.

The steps involved in migrating a legacy openstack-helm Ceph cluster to Rook
are based on the Rook `Troubleshooting`_ documentation and are outlined below.

#. Retrieve the cluster FSID, the name and IP address of an existing ceph-mon
   host that contains a healthy monitor store, and the numbers of existing
   ceph-mon and ceph-mgr pods from the existing Ceph cluster and save
   this information for later.
#. Rename CephFS pools so that they use the naming convention expected by Rook.
   CephFS pools names are not customizable with Rook, so new metadata and data
   pools will be created for any filesystems deployed by Rook if the existing
   pools are not named as expected. Pools must be named
   "<filesystem name>-metadata" and "<filesystem name>-data" in order for Rook to
   use existing CephFS pools.
#. Delete Ceph resources deployed via the openstack-helm-infra charts,
   uninstall the charts, and remove Ceph node labels.
#. Add the Rook Helm repository and deploy the Rook operator and a minimal Ceph
   cluster using the Rook Helm charts. The cluster will have a new FSID and will
   not include any OSDs because the OSD disks are all initialized in the old Ceph
   cluster and that will be recognized.
#. Save the Ceph monitor keyring, host, and IP address, as well as the IP
   address of the new monitor itself, for later use.
#. Stop the Rook operator by scaling the rook-ceph-operator deployment in the
   Rook operator namespace to zero replicas and destroy the newly-deployed Ceph
   cluster by deleting all deployments in the Rook Ceph cluster namespace except
   for rook-ceph-tools.
#. Copy the store from an old monitor saved in the first step to the new
   monitor and update its keyring with the key saved from the new monitor.
#. Edit the monmap in the copied monitor store using monmaptool to remove all
   of the old monitors from the monmap and add a single new one using the new
   monitor's IP address.
#. Edit the rook-ceph-mon secret in the Rook Ceph cluster namespace and
   overwrite the base64-encoded FSID with the base64 encoding of the FSID from the
   old Ceph cluster. Make sure the encoding includes the FSID only, no whitespace
   or newline characters.
#. Edit the rook-config-override configmap in the Rook Ceph cluster namespace
   and set auth_supported, auth_client_required, auth_service_required, and
   auth_cluster_required all to none in the global config section to disable
   authentication in the Ceph cluster.
#. Scale the rook-ceph-operator deployment back to one replica to deploy the
   Ceph cluster again. This time, the cluster will have the old cluster's FSID
   and the OSD pods will come up in the new cluster with their data intact.
#. Using 'ceph auth import' from the rook-ceph-tools pod, import the
   [client.admin] portion of the key saved from the new monitor from its initial
   Rook deployment.
#. Edit the rook-config-override configmap again and remove the settings
   previously added to disable authentication. This will re-enable authentication
   when Ceph daemons are restarted.
#. Scale the rook-ceph-operator deployment to zero replicas and delete the Ceph
   cluster deployments again to destroy the Ceph cluster one more time.
#. When everything has terminated, immediately scale the rook-ceph-operator
   deployment back to one to deploy the Ceph cluster one final time.
#. After the Ceph cluster has been deployed again and all of the daemons are
   running (with authentication enabled now), edit the deployed cephcluster
   resource in the Rook Ceph cluster namespace to set the mon and mgr counts to
   their original values saved in the first step.
#. Now you have a Ceph cluster, deployed and managed by Rook, with the original
   FSID and all of its data intact, with the same number of monitors and managers
   that existed in the previous deployment.

There is a rudimentary `script`_ provided that automates this process. It
isn't meant to be a complete solution and isn't supported as such. It is simply
an example that is known to work for some test implementations.

The script makes use of environment variables to tell it which Rook release and
Ceph release to deploy, in which Kubernetes namespaces to deploy the Rook
operator and Ceph cluster, and paths to YAML files that contain the necessary
definitions for the Rook operator and Rook Ceph cluster. All of these have
default values and are not required to be set, but it will likely be necessary
at least to define paths to the YAML files required to deploy the Rook operator
and Ceph cluster. Please refer to the comments near the top of the script for
more information about utilizing these environment variables.

The Ceph cluster definition provided to Rook should match the existing Ceph
cluster as closely as possible. Otherwise, the migration may not migrate Ceph
cluster resources as expected. The migration of deployed Ceph resources is
unique to each deployment, so sample definitions are not provided here.

Migrations using this procedure and/or script are very delicate and will
require a lot of testing prior to being implemented in production. This is a
risky operation even with testing and should be performed very carefully.

.. _Ceph: https://ceph.io
.. _openstack-helm-infra: https://opendev.org/openstack/openstack-helm-infra
.. _Rook: https://rook.io
.. _Troubleshooting: https://rook.io/docs/rook/latest-release/Troubleshooting/disaster-recovery/#adopt-an-existing-rook-ceph-cluster-into-a-new-kubernetes-cluster
.. _script: https://opendev.org/openstack/openstack-helm-infra/src/tools/deployment/ceph/migrate-to-rook-ceph.sh
