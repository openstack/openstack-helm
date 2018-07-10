===============
Monitor Failure
===============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes version: 1.9.3
- Ceph version: 12.2.3
- OpenStack-Helm commit: 28734352741bae228a4ea4f40bcacc33764221eb

We have 3 Monitors in this Ceph cluster, one on each of the 3 Monitor
hosts.

Case: 1 out of 3 Monitor Processes is Down
==========================================

This is to test a scenario when 1 out of 3 Monitor processes is down.

To bring down 1 Monitor process (out of 3), we identify a Monitor
process and kill it from the monitor host (not a pod).

.. code-block:: console

  $ ps -ef | grep ceph-mon
  ceph     16112 16095  1 14:58 ?        00:00:03 /usr/bin/ceph-mon --cluster ceph --setuser ceph --setgroup ceph -d -i voyager2 --mon-data /var/lib/ceph/mon/ceph-voyager2 --public-addr 135.207.240.42:6789
  $ sudo kill -9 16112

In the mean time, we monitored the status of Ceph and noted that it
takes about 24 seconds for the killed Monitor process to recover from
``down`` to ``up``. The reason is that Kubernetes automatically
restarts pods whenever they are killed.

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager3

    services:
      mon: 3 daemons, quorum voyager1,voyager3, out of quorum: voyager2
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

.. code-block:: console

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2

    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

We also monitored the status of the Monitor pod through ``kubectl get
pods -n ceph``, and the status of the pod (where a Monitor process is
killed) changed as follows: ``Running`` -> ``Error`` -> ``Running``
and this recovery process takes about 24 seconds.

Case: 2 out of 3 Monitor Processes are Down
===========================================

This is to test a scenario when 2 out of 3 Monitor processes are down.
To bring down 2 Monitor processes (out of 3), we identify two Monitor
processes and kill them from the 2 monitor hosts (not a pod).

We monitored the status of Ceph when the Monitor processes are killed
and noted that the symptoms are similar to when 1 Monitor process is
killed:

- It takes longer (about 1 minute) for the killed Monitor processes to
  recover from ``down`` to ``up``.

- The status of the pods (where the two Monitor processes are killed)
  changed as follows: ``Running`` -> ``Error`` -> ``CrashLoopBackOff``
  -> ``Running`` and this recovery process takes about 1 minute.


Case: 3 out of 3 Monitor Processes are Down
===========================================

This is to test a scenario when 3 out of 3 Monitor processes are down.
To bring down 3 Monitor processes (out of 3), we identify all 3
Monitor processes and kill them from the 3 monitor hosts (not pods).

We monitored the status of Ceph Monitor pods and noted that the
symptoms are similar to when 1 or 2 Monitor processes are killed:

.. code-block:: console

  $ kubectl get pods -n ceph -o wide | grep ceph-mon
  NAME                                       READY     STATUS    RESTARTS   AGE
  ceph-mon-8tml7                             0/1       Error     4          10d
  ceph-mon-kstf8                             0/1       Error     4          10d
  ceph-mon-z4sl9                             0/1       Error     7          10d

.. code-block:: console

  $ kubectl get pods -n ceph -o wide | grep ceph-mon
  NAME                                       READY     STATUS               RESTARTS   AGE
  ceph-mon-8tml7                             0/1       CrashLoopBackOff     4          10d
  ceph-mon-kstf8                             0/1       Error                4          10d
  ceph-mon-z4sl9                             0/1       CrashLoopBackOff     7          10d


.. code-block:: console

  $ kubectl get pods -n ceph -o wide | grep ceph-mon
  NAME                                       READY     STATUS    RESTARTS   AGE
  ceph-mon-8tml7                             1/1       Running   5          10d
  ceph-mon-kstf8                             1/1       Running   5          10d
  ceph-mon-z4sl9                             1/1       Running   8          10d

The status of the pods (where the three Monitor processes are killed)
changed as follows: ``Running`` -> ``Error`` -> ``CrashLoopBackOff``
-> ``Running`` and this recovery process takes about 1 minute.
