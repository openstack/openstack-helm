===============================
3.  Namespace deletion recovery
===============================

This document captures steps to bring Ceph back up after deleting it's associated namespace.

3.1  Setup
==========

.. note::
   Follow OSH single node or multinode guide to bring up OSH envronment.

3.2  Setup the OSH environment and check ceph  cluster health
=============================================================

.. note::
   Ensure a healthy ceph cluster is running.

.. code-block:: console

   kubectl exec -n ceph ceph-mon-dtw6m -- ceph -s
     cluster:
       id:     fbaf9ce8-5408-4fce-9bfe-bf7fb938474c
       health: HEALTH_OK

     services:
       mon: 5 daemons, quorum osh-1,osh-2,osh-5,osh-4,osh-3
       mgr: osh-3(active), standbys: osh-4
       mds: cephfs-1/1/1 up  {0=mds-ceph-mds-77dc68f476-jb5th=up:active}, 1 up:standby
       osd: 15 osds: 15 up, 15 in

     data:
       pools:   18 pools, 182 pgs
       objects: 21 objects, 2246 bytes
       usage:   3025 MB used, 1496 GB / 1499 GB avail
       pgs:     182 active+clean

- Ceph cluster is in HEALTH_OK state with 5 MONs and 15 OSDs.

3.3  Delete Ceph namespace
==========================

.. note::
   Removing the namespace will delete all pods and secrets associated to Ceph.
   !! DO NOT PROCEED WITH DELETING THE CEPH NAMESPACES ON A PRODUCTION ENVIRONMENT !!

.. code-block:: console

   CEPH_NAMESPACE="ceph"
   MON_POD=$(kubectl get pods --namespace=${CEPH_NAMESPACE} \
   --selector="application=ceph" --selector="component=mon" \
   --no-headers | awk '{ print $1; exit }')

   kubectl exec --namespace=${CEPH_NAMESPACE} ${MON_POD} -- ceph status \
   | awk '/id:/{print $2}' | tee /tmp/ceph-fs-uuid.txt

.. code-block:: console

   kubectl delete namespace ${CEPH_NAMESPACE}

.. code-block:: console

   kubectl get pods --namespace ${CEPH_NAMESPACE} -o wide
   No resources found.

   kubectl get secrets --namespace ${CEPH_NAMESPACE}
   No resources found.

- Ceph namespace is currently deleted and all associated resources will be not found.

3.4  Reinstall Ceph charts
==========================

.. note::
   Instructions are specific to a multinode environment.
   For AIO environments follow the development guide for reinstalling Ceph.

.. code-block:: console

   helm delete --purge ceph-openstack-config

   for chart in $(helm list --namespace ${CEPH_NAMESPACE} | awk '/ceph-/{print $1}'); do
     helm delete ${chart} --purge;
   done

.. note::
   It will be normal not to see all PODs come back online during a reinstall.
   Only the ceph-mon helm chart is required.

.. code-block:: console

   cd /opt/openstack-helm-infra/
   ./tools/deployment/multinode/030-ceph.sh

3.5  Disable CephX authentication
=================================

.. note::
   Wait until MON pods are running before proceeding here.

.. code-block:: console

   mkdir -p /tmp/ceph/ceph-templates /tmp/ceph/extracted-keys

   kubectl get -n ${CEPH_NAMESPACE} configmaps ceph-mon-etc -o=jsonpath='{.data.ceph\.conf}' > /tmp/ceph/ceph-mon.conf
   sed '/\[global\]/a auth_client_required = none' /tmp/ceph/ceph-mon.conf | \
   sed '/\[global\]/a auth_service_required = none' | \
   sed '/\[global\]/a auth_cluster_required = none' > /tmp/ceph/ceph-mon-noauth.conf

   kubectl --namespace ${CEPH_NAMESPACE} delete configmap ceph-mon-etc
   kubectl --namespace ${CEPH_NAMESPACE} create configmap ceph-mon-etc --from-file=ceph.conf=/tmp/ceph/ceph-mon-noauth.conf

   kubectl delete pod --namespace ${CEPH_NAMESPACE} -l application=ceph,component=mon

.. note::
   Wait until the MON pods are running before proceeding here.

.. code-block:: console

   MON_POD=$(kubectl get pods --namespace=${CEPH_NAMESPACE} \
   --selector="application=ceph" --selector="component=mon" \
   --no-headers | awk '{ print $1; exit }')

   kubectl exec --namespace=${CEPH_NAMESPACE} ${MON_POD} -- ceph status

- The Ceph cluster will not be healthy and in a HEALTH_WARN or HEALTH_ERR state.

3.6  Replace key secrets with ones extracted from a Ceph MON
============================================================

.. code-block:: console

   tee /tmp/ceph/ceph-templates/mon <<EOF
   [mon.]
     key = $(kubectl --namespace ${CEPH_NAMESPACE} exec ${MON_POD} -- bash -c "ceph-authtool -l \"/var/lib/ceph/mon/ceph-\$(hostname)/keyring\"" | awk '/key =/ {print $NF}')
     caps mon = "allow *"
   EOF

   for KEY in mds osd rgw; do
     tee /tmp/ceph/ceph-templates/${KEY} <<EOF
       [client.bootstrap-${KEY}]
         key = $(kubectl --namespace ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph auth get-key client.bootstrap-${KEY})
         caps mon = "allow profile bootstrap-${KEY}"
     EOF
   done

   tee /tmp/ceph/ceph-templates/admin <<EOF
   [client.admin]
     key = $(kubectl --namespace ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph auth get-key client.admin)
     auid = 0
     caps mds = "allow"
     caps mon = "allow *"
     caps osd = "allow *"
     caps mgr = "allow *"
   EOF

.. code-block:: console

   tee /tmp/ceph/ceph-key-relationships <<EOF
   mon ceph-mon-keyring ceph.mon.keyring mon.
   mds ceph-bootstrap-mds-keyring ceph.keyring client.bootstrap-mds
   osd ceph-bootstrap-osd-keyring ceph.keyring client.bootstrap-osd
   rgw ceph-bootstrap-rgw-keyring ceph.keyring client.bootstrap-rgw
   admin ceph-client-admin-keyring ceph.client.admin.keyring client.admin
   EOF

.. code-block:: console

   while read CEPH_KEY_RELATIONS; do
     KEY_RELATIONS=($(echo ${CEPH_KEY_RELATIONS}))
     COMPONENT=${KEY_RELATIONS[0]}
     KUBE_SECRET_NAME=${KEY_RELATIONS[1]}
     KUBE_SECRET_DATA_KEY=${KEY_RELATIONS[2]}
     KEYRING_NAME=${KEY_RELATIONS[3]}
     DATA_PATCH=$(cat /tmp/ceph/ceph-templates/${COMPONENT} | envsubst | base64 -w0)
     kubectl --namespace ${CEPH_NAMESPACE} patch secret ${KUBE_SECRET_NAME} -p "{\"data\":{\"${KUBE_SECRET_DATA_KEY}\": \"${DATA_PATCH}\"}}"
   done < /tmp/ceph/ceph-key-relationships

3.7  Re-enable CephX Authentication
===================================

.. code-block:: console

   kubectl --namespace ${CEPH_NAMESPACE} delete configmap ceph-mon-etc
   kubectl --namespace ${CEPH_NAMESPACE} create configmap ceph-mon-etc --from-file=ceph.conf=/tmp/ceph/ceph-mon.conf

3.8  Reinstall Ceph charts
==========================

.. note::
   Instructions are specific to a multinode environment.
   For AIO environments follow the development guide for reinstalling Ceph.

.. code-block:: console

   for chart in $(helm list --namespace ${CEPH_NAMESPACE} | awk '/ceph-/{print $1}'); do
     helm delete ${chart} --purge;
   done

.. code-block:: console

   cd /opt/openstack-helm-infra/
   ./tools/deployment/multinode/030-ceph.sh
   ./tools/deployment/multinode/040-ceph-ns-activate.sh

.. code-block:: console

   MON_POD=$(kubectl get pods --namespace=${CEPH_NAMESPACE} \
   --selector="application=ceph" --selector="component=mon" \
   --no-headers | awk '{ print $1; exit }')

   kubectl exec --namespace=${CEPH_NAMESPACE} ${MON_POD} -- ceph status

.. note::
   AIO environments will need the following command to repair MDS standby failures.

.. code-block:: console

   kubectl exec --namespace=${CEPH_NAMESPACE} ${MON_POD} -- ceph fs set cephfs standby_count_wanted 0

- Ceph pods are now running and cluster is healthy (HEALTH_OK).

