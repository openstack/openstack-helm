================================================================
Ceph - upgrade monolithic ceph-osd chart to multiple ceph charts
================================================================

This document captures the steps  to  move from installed monolithic ceph-osd chart
to mutlitple ceph osd charts.

this work will bring flexibility on site update as we will have more control on osds.


Install single ceph-osd chart:
==============================

step 1: Setup:
==============

- Follow OSH single node or  multinode guide to bring up OSH environment.

.. note::
  we will have single ceph osd chart and here are the override values for ceph disks
    osd:
      - data:
          type: block-logical
          location: /dev/vdb
        journal:
          type: block-logical
          location:  /dev/vda1
      - data:
          type: block-logical
          location: /dev/vdc
        journal:
          type: block-logical
          location:  /dev/vda2


Step 2:  Setup the OSH environment and check ceph  cluster health
=================================================================

.. note::
  Make sure we have healthy ceph cluster running

``Ceph status:``

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph -s
      cluster:
        id:     61a4e07f-8b4a-4c47-8fc7-a0e7345ac0b0
        health: HEALTH_OK

      services:
         mon: 3 daemons, quorum k8smaster,k8sslave1,k8sslave2
         mgr: k8sslave2(active), standbys: k8sslave1
         mds: cephfs-1/1/1 up  {0=mds-ceph-mds-5bf9fdfc6b-8nq4p=up:active}, 1 up:standby
         osd: 6 osds: 6 up, 6 in
      data:
         pools:   18 pools, 186 pgs
         objects: 377  objects, 1.2 GiB
         usage:   4.2 GiB used, 116 GiB / 120 GiB avail
         pgs:     186 active+clean

- Ceph cluster is in HEALTH_OK state with 3 MONs and 6 OSDs.

.. note::
  Make sure we have single ceph osd chart only

``Helm status:``

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$  helm list | grep -i osd
  ceph-osd            1     Tue Mar 26 03:21:07 2019        DEPLOYED        ceph-osd-vdb-0.1.0

- single osd chart deployed sucessfully.


Upgrade to multiple ceph osd charts:
====================================

step 1: setup
=============

- create multiple ceph osd charts as per requirement

.. note::
  copy ceph-osd folder to multiple ceph osd charts  in openstack-helm-infra folder

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm-infra$  cp -r ceph-osd ceph-osd-vdb
  ubuntu@k8smaster:/opt/openstack-helm-infra$  cp -r ceph-osd ceph-osd-vdc

.. note::
  make sure  to correct chart name in each osd chart folder created above, need to
  update it in  Charts.yaml .

- create script to install multiple  ceph osd charts

.. note::
  create new installation scripts to reflect new ceph osd charts.

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$  cp ./tools/deployment/multinode/030-ceph.sh
  ./tools/deployment/multinode/030-ceph-osd-vdb.sh

  ubuntu@k8smaster:/opt/openstack-helm$  cp ./tools/deployment/multinode/030-ceph.sh
  ./tools/deployment/multinode/030-ceph-osd-vdc.sh

.. note::
  make sure to delete all other ceph charts from above scripts and have only new ceph osd chart.
  and also have correct overrides as shown below.

  example1: for CHART in ceph-osd-vdb; do
  helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
  --namespace=ceph \
  --values=/tmp/ceph.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}

  osd:
    - data:
        type: block-logical
        location: /dev/vdb
      journal:
        type: block-logical
        location:  /dev/vda1

  example2: for CHART in ceph-osd-vdc; do
  helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
  --namespace=ceph \
  --values=/tmp/ceph.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}

  osd:
    - data:
        type: block-logical
        location: /dev/vdc
      journal:
        type: block-logical
        location:  /dev/vda2

step 2: Scale down  applications using ceph pvc
===============================================

.. note::
  Scale down all the applications who are using pvcs so that we will not
  have any writes on  ceph rbds .

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$  sudo kubectl scale statefulsets -n openstack
  mariadb-server --replicas=0

  ubuntu@k8smaster:/opt/openstack-helm$  sudo kubectl scale statefulsets -n openstack
  rabbitmq-rabbitmq --replicas=0

- just gave one example but we need to do it for all the applications using pvcs


step 3: Setup ceph cluster flags to prevent rebalance
=====================================================

.. note::
  setup few flags on ceph cluster to prevent rebalance during this process.

.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd set
  noout

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd set
  nobackfill

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd set
  norecover

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd set
  pause

step 4: Delete single ceph-osd chart
====================================

.. note::
  Delete the single ceph-osd chart.


.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$ helm delete --purge ceph-osd


step 5: install new ceph-osd charts
===================================

.. note::
  Now we can install multiple ceph osd releases.


.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$ ./tools/deployment/multinode/030-ceph-osd-vdb.sh
  ubuntu@k8smaster:/opt/openstack-helm$ ./tools/deployment/multinode/030-ceph-osd-vdc.sh
  ubuntu@k8smaster:/opt/openstack-helm# helm list | grep -i osd
  ceph-osd-vdb            1            Tue Mar 26 03:21:07 2019        DEPLOYED  ceph-osd-vdb-0.1.0
  ceph-osd-vdc            1            Tue Mar 26 03:22:13 2019        DEPLOYED  ceph-osd-vdc-0.1.0

- wait and check for healthy ceph cluster , if there are any issues need to sort out until we see
  healthy ceph cluster.

step 6: Unset ceph cluster flags
================================

.. note::
  unset the flags we set on the ceph cluster in above steps.


.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd unset
  noout

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd unset
  nobackfill

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd unset
  norecover

  ubuntu@k8smaster:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph osd unset
  pause

step 7: Scale up the applications using pvc
===========================================

.. note::
  Since ceph cluster is back to healthy status, now scale up the applications.


.. code-block:: console

  ubuntu@k8smaster:/opt/openstack-helm$  sudo kubectl scale statefulsets -n openstack
  mariadb-server --replicas=3

  ubuntu@k8smaster:/opt/openstack-helm$  sudo kubectl scale statefulsets -n openstack
  rabbitmq-rabbitmq --replicas=3
