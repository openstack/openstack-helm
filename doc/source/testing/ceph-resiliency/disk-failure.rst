============
Disk Failure
============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes version: 1.10.5
- Ceph version: 12.2.3
- OpenStack-Helm commit: 25e50a34c66d5db7604746f4d2e12acbdd6c1459

Case: A disk fails
==================

Symptom:
--------

This is to test a scenario when a disk failure happens.
We monitor the ceph status and notice one OSD (osd.2) on voyager4
which has ``/dev/sdh`` as a backend is down.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (23 < min 30)
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 23 up, 23 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2548 MB used, 42814 GB / 42816 GB avail
      pgs:     182 active+clean

.. code-block:: console

  (mon-pod):/# ceph osd tree
  ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF
  -1       43.67981 root default
  -9       10.91995     host voyager1
   5   hdd  1.81999         osd.5         up  1.00000 1.00000
   6   hdd  1.81999         osd.6         up  1.00000 1.00000
  10   hdd  1.81999         osd.10        up  1.00000 1.00000
  17   hdd  1.81999         osd.17        up  1.00000 1.00000
  19   hdd  1.81999         osd.19        up  1.00000 1.00000
  21   hdd  1.81999         osd.21        up  1.00000 1.00000
  -3       10.91995     host voyager2
   1   hdd  1.81999         osd.1         up  1.00000 1.00000
   4   hdd  1.81999         osd.4         up  1.00000 1.00000
  11   hdd  1.81999         osd.11        up  1.00000 1.00000
  13   hdd  1.81999         osd.13        up  1.00000 1.00000
  16   hdd  1.81999         osd.16        up  1.00000 1.00000
  18   hdd  1.81999         osd.18        up  1.00000 1.00000
  -2       10.91995     host voyager3
   0   hdd  1.81999         osd.0         up  1.00000 1.00000
   3   hdd  1.81999         osd.3         up  1.00000 1.00000
  12   hdd  1.81999         osd.12        up  1.00000 1.00000
  20   hdd  1.81999         osd.20        up  1.00000 1.00000
  22   hdd  1.81999         osd.22        up  1.00000 1.00000
  23   hdd  1.81999         osd.23        up  1.00000 1.00000
  -4       10.91995     host voyager4
   2   hdd  1.81999         osd.2       down        0 1.00000
   7   hdd  1.81999         osd.7         up  1.00000 1.00000
   8   hdd  1.81999         osd.8         up  1.00000 1.00000
   9   hdd  1.81999         osd.9         up  1.00000 1.00000
  14   hdd  1.81999         osd.14        up  1.00000 1.00000
  15   hdd  1.81999         osd.15        up  1.00000 1.00000


Solution:
---------

To replace the failed OSD, execute the following procedure:

1. From the Kubernetes cluster, remove the failed OSD pod, which is running on ``voyager4``:

.. code-block:: console

  $ kubectl label nodes --all ceph_maintenance_window=inactive
  $ kubectl label nodes voyager4 --overwrite ceph_maintenance_window=active
  $ kubectl patch -n ceph ds ceph-osd-default-64779b8c -p='{"spec":{"template":{"spec":{"nodeSelector":{"ceph-osd":"enabled","ceph_maintenance_window":"inactive"}}}}}'

Note: To find the daemonset associated with a failed OSD, check out the followings:

.. code-block:: console

  (voyager4)$ ps -ef|grep /usr/bin/ceph-osd
  (voyager1)$ kubectl get ds -n ceph
  (voyager1)$ kubectl get ds <daemonset-name> -n ceph -o yaml


2. Remove the failed OSD (OSD ID = 2 in this example) from the Ceph cluster:

.. code-block:: console

  (mon-pod):/# ceph osd lost 2
  (mon-pod):/# ceph osd crush remove osd.2
  (mon-pod):/# ceph auth del osd.2
  (mon-pod):/# ceph osd rm 2

3. Find that Ceph is healthy with a lost OSD (i.e., a total of 23 OSDs):

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (23 < min 30)
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 23 osds: 23 up, 23 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2551 MB used, 42814 GB / 42816 GB avail
      pgs:     182 active+clean

4. Replace the failed disk with a new one. If you repair (not replace) the failed disk,
you may need to run the following:

.. code-block:: console

  (voyager4)$ parted /dev/sdh mklabel msdos

5. Start a new OSD pod on ``voyager4``:

.. code-block:: console

  $ kubectl label nodes voyager4 --overwrite ceph_maintenance_window=inactive

6. Validate the Ceph status (i.e., one OSD is added, so the total number of OSDs becomes 24):

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
      objects: 240 objects, 3359 bytes
      usage:   2665 MB used, 44675 GB / 44678 GB avail
      pgs:     182 active+clean
