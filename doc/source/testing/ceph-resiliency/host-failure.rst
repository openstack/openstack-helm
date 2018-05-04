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
