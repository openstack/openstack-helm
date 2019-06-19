============
Host Failure
============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes version: 1.10.5
- Ceph version: 12.2.3
- OpenStack-Helm commit: 25e50a34c66d5db7604746f4d2e12acbdd6c1459

Case: One host machine where ceph-mon is running is rebooted
============================================================

Symptom:
--------

After reboot (node voyager3), the node status changes to ``NotReady``.

.. code-block:: console

  $ kubectl get nodes
  NAME       STATUS     ROLES     AGE       VERSION
  voyager1   Ready      master    6d        v1.10.5
  voyager2   Ready      <none>    6d        v1.10.5
  voyager3   NotReady   <none>    6d        v1.10.5
  voyager4   Ready      <none>    6d        v1.10.5

Ceph status shows that ceph-mon running on ``voyager3`` becomes out of quorum.
Also, six osds running on ``voyager3`` are down; i.e., 18 osds are up out of 24 osds.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              Degraded data redundancy: 195/624 objects degraded (31.250%), 8 pgs degraded
              too few PGs per OSD (17 < min 30)
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2

    services:
      mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 18 up, 24 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 208 objects, 3359 bytes
      usage:   2630 MB used, 44675 GB / 44678 GB avail
      pgs:     195/624 objects degraded (31.250%)
               126 active+undersized
               48  active+clean
               8   active+undersized+degraded

Recovery:
---------
The node status of ``voyager3`` changes to ``Ready`` after the node is up again.
Also, Ceph pods are restarted automatically.
Ceph status shows that the monitor running on ``voyager3`` is now in quorum.

.. code-block:: console

  $ kubectl get nodes
  NAME       STATUS    ROLES     AGE       VERSION
  voyager1   Ready     master    6d        v1.10.5
  voyager2   Ready     <none>    6d        v1.10.5
  voyager3   Ready     <none>    6d        v1.10.5
  voyager4   Ready     <none>    6d        v1.10.5

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (22 < min 30)
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 24 up, 24 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 208 objects, 3359 bytes
      usage:   2635 MB used, 44675 GB / 44678 GB avail
      pgs:     182 active+clean

Case: A host machine where ceph-mon is running is down
======================================================

This is for the case when a host machine (where ceph-mon is running) is down.

Symptom:
--------

After the host is down (node voyager3), the node status changes to ``NotReady``.

.. code-block:: console

  $ kubectl get nodes
  NAME       STATUS     ROLES     AGE       VERSION
  voyager1   Ready      master    14d       v1.10.5
  voyager2   Ready      <none>    14d       v1.10.5
  voyager3   NotReady   <none>    14d       v1.10.5
  voyager4   Ready      <none>    14d       v1.10.5

Ceph status shows that ceph-mon running on ``voyager3`` becomes out of quorum.
Also, 6 osds running on ``voyager3`` are down (i.e., 18 out of 24 osds are up).
Some placement groups become degraded and undersized.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
        id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
        health: HEALTH_WARN
                6 osds down
                1 host (6 osds) down
                Degraded data redundancy: 227/720 objects degraded (31.528%), 8 pgs
    degraded
                too few PGs per OSD (17 < min 30)
                mon voyager1 is low on available space
                1/3 mons down, quorum voyager1,voyager2

      services:
        mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
        mgr: voyager1(active), standbys: voyager3
        mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:stan
    dby
        osd: 24 osds: 18 up, 24 in
        rgw: 2 daemons active

      data:
        pools:   18 pools, 182 pgs
        objects: 240 objects, 3359 bytes
        usage:   2695 MB used, 44675 GB / 44678 GB avail
        pgs:     227/720 objects degraded (31.528%)
                 126 active+undersized
                 48  active+clean
                 8   active+undersized+degraded

The pod status of ceph-mon and ceph-osd shows as ``NodeLost``.

.. code-block:: console

  $ kubectl get pods -n ceph -o wide|grep voyager3
  ceph-mgr-55f68d44b8-hncrq                  1/1       Unknown     6          8d        135.207.240.43   voyager3
  ceph-mon-6bbs6                             1/1       NodeLost    8          8d        135.207.240.43   voyager3
  ceph-osd-default-64779b8c-lbkcd            1/1       NodeLost    1          6d        135.207.240.43   voyager3
  ceph-osd-default-6ea9de2c-gp7zm            1/1       NodeLost    2          8d        135.207.240.43   voyager3
  ceph-osd-default-7544b6da-7mfdc            1/1       NodeLost    2          8d        135.207.240.43   voyager3
  ceph-osd-default-7cfc44c1-hhk8v            1/1       NodeLost    2          8d        135.207.240.43   voyager3
  ceph-osd-default-83945928-b95qs            1/1       NodeLost    2          8d        135.207.240.43   voyager3
  ceph-osd-default-f9249fa9-n7p4v            1/1       NodeLost    3          8d        135.207.240.43   voyager3

After 10+ miniutes, Ceph starts rebalancing with one node lost (i.e., 6 osds down)
and the status stablizes with 18 osds.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2

    services:
      mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
      mgr: voyager1(active), standbys: voyager2
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 18 up, 18 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2025 MB used, 33506 GB / 33508 GB avail
      pgs:     182 active+clean


Recovery:
---------

The node status of ``voyager3`` changes to ``Ready`` after the node is up again.
Also, Ceph pods are restarted automatically.
The Ceph status shows that the monitor running on ``voyager3`` is now in quorum
and 6 osds gets back up (i.e., a total of 24 osds are up).

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (22 < min 30)
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager2
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 24 up, 24 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2699 MB used, 44675 GB / 44678 GB avail
      pgs:     182 active+clean

Also, the pod status of ceph-mon and ceph-osd changes from ``NodeLost`` back to ``Running``.

.. code-block:: console

  $ kubectl get pods -n ceph -o wide|grep voyager3
  ceph-mon-6bbs6                             1/1       Running     9          8d        135.207.240.43   voyager3
  ceph-osd-default-64779b8c-lbkcd            1/1       Running     2          7d        135.207.240.43   voyager3
  ceph-osd-default-6ea9de2c-gp7zm            1/1       Running     3          8d        135.207.240.43   voyager3
  ceph-osd-default-7544b6da-7mfdc            1/1       Running     3          8d        135.207.240.43   voyager3
  ceph-osd-default-7cfc44c1-hhk8v            1/1       Running     3          8d        135.207.240.43   voyager3
  ceph-osd-default-83945928-b95qs            1/1       Running     3          8d        135.207.240.43   voyager3
  ceph-osd-default-f9249fa9-n7p4v            1/1       Running     4          8d        135.207.240.43   voyager3
