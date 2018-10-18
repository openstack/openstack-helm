===========
OSD Failure
===========

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes version: 1.9.3
- Ceph version: 12.2.3
- OpenStack-Helm commit: 28734352741bae228a4ea4f40bcacc33764221eb

Case: OSD processes are killed
==============================

This is to test a scenario when some of the OSDs are down.

To bring down 6 OSDs (out of 24), we identify the OSD processes and
kill them from a storage host (not a pod).

.. code-block:: console

  $ ps -ef|grep /usr/bin/ceph-osd
  ceph     44587 43680  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb5 -f -i 4 --setuser ceph --setgroup disk
  ceph     44627 43744  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb2 -f -i 6 --setuser ceph --setgroup disk
  ceph     44720 43927  2 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb6 -f -i 3 --setuser ceph --setgroup disk
  ceph     44735 43868  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb1 -f -i 9 --setuser ceph --setgroup disk
  ceph     44806 43855  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb4 -f -i 0 --setuser ceph --setgroup disk
  ceph     44896 44011  2 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb3 -f -i 1 --setuser ceph --setgroup disk
  root     46144 45998  0 18:13 pts/10   00:00:00 grep --color=auto /usr/bin/ceph-osd

  $ sudo kill -9 44587 44627 44720 44735 44806 44896

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              Reduced data availability: 8 pgs inactive, 58 pgs peering
              Degraded data redundancy: 141/1002 objects degraded (14.072%), 133 pgs degraded
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 18 up, 24 in

In the mean time, we monitor the status of Ceph and noted that it takes about 30 seconds for the 6 OSDs to recover from ``down`` to ``up``.
The reason is that Kubernetes automatically restarts OSD pods whenever they are killed.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

Case: A OSD pod is deleted
==========================

This is to test a scenario when an OSD pod is deleted by ``kubectl delete $OSD_POD_NAME``.
Meanwhile, we monitor the status of Ceph and note that it takes about 90 seconds for the OSD running in deleted pod to recover from ``down`` to ``up``.

.. code-block:: console

  root@voyager3:/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              1 osds down
              Degraded data redundancy: 43/945 objects degraded (4.550%), 35 pgs degraded, 109 pgs undersized
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 23 up, 24 in

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

We also monitored the pod status through ``kubectl get pods -n ceph``
during this process. The deleted OSD pod status changed as follows:
``Terminating`` -> ``Init:1/3`` -> ``Init:2/3`` -> ``Init:3/3`` ->
``Running``, and this process takes about 90 seconds. The reason is
that Kubernetes automatically restarts OSD pods whenever they are
deleted.
