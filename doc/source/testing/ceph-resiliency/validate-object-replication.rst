===========================================
Ceph - Test object replication across hosts
===========================================

This document captures steps  to  validate object replcation is happening across
hosts or  not .


Setup:
======
- Follow OSH single node or  multinode guide to bring up OSH envronment.



Step 1:  Setup the OSH environment and check ceph  cluster health
=================================================================

.. note::
  Make sure we have healthy ceph cluster running

``Ceph status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph -s
    cluster:
      id:     54d9af7e-da6d-4980-9075-96bb145db65c
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum mnode1,mnode2,mnode3
      mgr: mnode2(active), standbys: mnode3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-6f66956547-c25cx=up:active}, 1 up:standby
      osd: 3 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 101 pgs
      objects: 354 objects, 260 MB
      usage:   77807 MB used, 70106 MB / 144 GB avail
      pgs:     101 active+clean

    io:
      client:   48769 B/s wr, 0 op/s rd, 12 op/s wr


- Ceph cluster is in HEALTH_OK state with 3 MONs and 3 OSDs.


Step 2: Run validation script
=============================

.. note::
  Exec into ceph mon pod and execute the  validation script  by giving pool name as
  first argument, as shown below rbd is the pool name .

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ /tmp/checkObjectReplication.py rbd
  Test object got replicated on these osds: [1, 0, 2]
  Test object got replicated on these hosts: [u'mnode1', u'mnode2', u'mnode3']
  Hosts hosting multiple copies of a placement groups are:[]

- If  there  are any objects replicated  on same host then we will see them in the last
  line of the script output
