==================================================
Ceph - Node Reduction, Expansion and Ceph Recovery
==================================================

This document captures steps and result from node reduction and expansion as
well as ceph recovery.

Test Scenarios:
===============
1) Node reduction: Shutdown 1 of 3 nodes to simulate node failure. Capture effect
of node failure on Ceph as well as other OpenStack services that are using Ceph.

2) Node expansion: Apply Ceph and OpenStack related labels to another unused k8
node. Node expansion should provide more resources for k8 to schedule PODs for
Ceph and OpenStack services.

3) Fix Ceph Cluster: After node expansion, perform maintenance on Ceph cluster
to ensure quorum is reached and Ceph is HEALTH_OK.

Setup:
======
- 6 Nodes (VM based) env
- Only 3 nodes will have Ceph and OpenStack related labels. Each of these 3
  nodes will have one MON and one OSD running on them.
- Followed OSH multinode guide steps to setup nodes and install K8s cluster
- Followed OSH multinode guide steps to install Ceph and OpenStack charts up to
  Cinder.

Steps:
======
1) Initial Ceph and OpenStack deployment:
Install Ceph and OpenStack charts on 3 nodes (mnode1, mnode2 and mnode3).
Capture Ceph cluster status as well as K8s PODs status.

2) Node reduction (failure):
Shutdown 1 of 3 nodes (mnode3) to test node failure. This should cause
Ceph cluster to go in HEALTH_WARN state as it has lost 1 MON and 1 OSD.
Capture Ceph cluster status as well as K8s PODs status.

3) Node expansion:
Add Ceph and OpenStack related labels to 4th node (mnode4) for expansion.
Ceph cluster would show new MON and OSD being added to cluster. However Ceph
cluster would continue to show HEALTH_WARN because 1 MON and 1 OSD are still
missing.

4) Ceph cluster recovery:
Perform Ceph maintenance to make Ceph cluster HEALTH_OK. Remove lost MON and
OSD from Ceph cluster.


Step 1: Initial Ceph and OpenStack deployment
=============================================

.. note::
  Make sure only 3 nodes (mnode1, mnode2, mnode3) have Ceph and OpenStack
  related labels. K8s would only schedule PODs on these 3 nodes.

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

``Ceph MON Status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph mon_status -f json-pretty

.. code-block:: json

  {
      "name": "mnode2",
      "rank": 1,
      "state": "peon",
      "election_epoch": 92,
      "quorum": [
          0,
          1,
          2
      ],
      "features": {
          "required_con": "153140804152475648",
          "required_mon": [
              "kraken",
              "luminous"
          ],
          "quorum_con": "2305244844532236283",
          "quorum_mon": [
              "kraken",
              "luminous"
          ]
      },
      "outside_quorum": [],
      "extra_probe_peers": [],
      "sync_provider": [],
      "monmap": {
          "epoch": 1,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 21:02:24.330403",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              }
          ]
      },
      "feature_map": {
          "mon": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "mds": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "osd": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "client": {
              "group": {
                  "features": "0x7010fb86aa42ada",
                  "release": "jewel",
                  "num": 1
              },
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          }
      }
  }


``Ceph quorum status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-5qn68 -- ceph quorum_status -f json-pretty

.. code-block:: json

  {
      "election_epoch": 92,
      "quorum": [
          0,
          1,
          2
      ],
      "quorum_names": [
          "mnode1",
          "mnode2",
          "mnode3"
      ],
      "quorum_leader_name": "mnode1",
      "monmap": {
          "epoch": 1,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 21:02:24.330403",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              }
          ]
      }
  }


``Ceph PODs:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get pods -n ceph --show-all=false -o wide
  NAME                                       READY     STATUS    RESTARTS   AGE       IP               NODE
  ceph-cephfs-provisioner-784c6f9d59-ndsgn   1/1       Running   0          1h        192.168.4.15     mnode2
  ceph-cephfs-provisioner-784c6f9d59-vgzzx   1/1       Running   0          1h        192.168.3.17     mnode3
  ceph-mds-6f66956547-5x4ng                  1/1       Running   0          1h        192.168.4.14     mnode2
  ceph-mds-6f66956547-c25cx                  1/1       Running   0          1h        192.168.3.14     mnode3
  ceph-mgr-5746dd89db-9dbmv                  1/1       Running   0          1h        192.168.10.248   mnode3
  ceph-mgr-5746dd89db-qq4nl                  1/1       Running   0          1h        192.168.10.247   mnode2
  ceph-mon-5qn68                             1/1       Running   0          1h        192.168.10.248   mnode3
  ceph-mon-check-d85994946-4g5xc             1/1       Running   0          1h        192.168.4.8      mnode2
  ceph-mon-mwkj9                             1/1       Running   0          1h        192.168.10.247   mnode2
  ceph-mon-ql9zp                             1/1       Running   0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-c7gdd            1/1       Running   0          1h        192.168.10.248   mnode3
  ceph-osd-default-83945928-s6gs6            1/1       Running   0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-vsc5b            1/1       Running   0          1h        192.168.10.247   mnode2
  ceph-rbd-provisioner-5bfb577ffd-j6hlx      1/1       Running   0          1h        192.168.4.16     mnode2
  ceph-rbd-provisioner-5bfb577ffd-zdx2d      1/1       Running   0          1h        192.168.3.16     mnode3
  ceph-rgw-6c64b444d7-7bgqs                  1/1       Running   0          1h        192.168.3.12     mnode3
  ceph-rgw-6c64b444d7-hv6vn                  1/1       Running   0          1h        192.168.4.13     mnode2
  ingress-796d8cf8d6-4txkq                   1/1       Running   0          1h        192.168.2.6      mnode5
  ingress-796d8cf8d6-9t7m8                   1/1       Running   0          1h        192.168.5.4      mnode4
  ingress-error-pages-54454dc79b-hhb4f       1/1       Running   0          1h        192.168.2.5      mnode5
  ingress-error-pages-54454dc79b-twpgc       1/1       Running   0          1h        192.168.4.4      mnode2


``OpenStack PODs:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get pods -n openstack --show-all=false -o wide
  NAME                                           READY     STATUS    RESTARTS   AGE       IP              NODE
  cinder-api-66f4f9678-2lgwk                     1/1       Running   0          12m       192.168.3.41    mnode3
  cinder-api-66f4f9678-flvr5                     1/1       Running   0          12m       192.168.0.202   mnode1
  cinder-backup-659b68b474-582kr                 1/1       Running   0          12m       192.168.4.39    mnode2
  cinder-scheduler-6778f6f88c-mm9mt              1/1       Running   0          12m       192.168.0.201   mnode1
  cinder-volume-79b9bd8bb9-qsxdk                 1/1       Running   0          12m       192.168.4.40    mnode2
  glance-api-676fd49d4d-j4bdb                    1/1       Running   0          16m       192.168.3.37    mnode3
  glance-api-676fd49d4d-wtxqt                    1/1       Running   0          16m       192.168.4.31    mnode2
  ingress-7b4bc84cdd-9fs78                       1/1       Running   0          1h        192.168.5.3     mnode4
  ingress-7b4bc84cdd-wztz7                       1/1       Running   0          1h        192.168.1.4     mnode6
  ingress-error-pages-586c7f86d6-2jl5q           1/1       Running   0          1h        192.168.2.4     mnode5
  ingress-error-pages-586c7f86d6-455j5           1/1       Running   0          1h        192.168.3.3     mnode3
  keystone-api-5bcc7cb698-dzm8q                  1/1       Running   0          25m       192.168.4.24    mnode2
  keystone-api-5bcc7cb698-vvwwr                  1/1       Running   0          25m       192.168.3.25    mnode3
  mariadb-ingress-84894687fd-dfnkm               1/1       Running   2          1h        192.168.3.20    mnode3
  mariadb-ingress-error-pages-78fb865f84-p8lpg   1/1       Running   0          1h        192.168.4.17    mnode2
  mariadb-server-0                               1/1       Running   0          1h        192.168.4.18    mnode2
  memcached-memcached-5db74ddfd5-wfr9q           1/1       Running   0          29m       192.168.3.23    mnode3
  rabbitmq-rabbitmq-0                            1/1       Running   0          1h        192.168.3.21    mnode3
  rabbitmq-rabbitmq-1                            1/1       Running   0          1h        192.168.4.19    mnode2
  rabbitmq-rabbitmq-2                            1/1       Running   0          1h        192.168.0.195   mnode1

``Result/Observation:``

- Ceph cluster is in HEALTH_OK state with 3 MONs and 3 OSDs.
- All PODs are in running state.


Step 2: Node reduction (failure):
=================================

Shutdown 1 of 3 nodes (mnode1, mnode2, mnode3) to simulate node failure/lost.

In this test env, let's shutdown ``mnode3`` node.

``Following are PODs scheduled on mnode3 before shutdown:``

.. code-block:: console

  ceph                       ceph-cephfs-provisioner-784c6f9d59-vgzzx    0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-mds-6f66956547-c25cx                   0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-mgr-5746dd89db-9dbmv                   0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-mon-5qn68                              0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-osd-default-83945928-c7gdd             0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-rbd-provisioner-5bfb577ffd-zdx2d       0 (0%)        0 (0%)      0 (0%)           0 (0%)
  ceph                       ceph-rgw-6c64b444d7-7bgqs                   0 (0%)        0 (0%)      0 (0%)           0 (0%)
  kube-system                ingress-ggckm                               0 (0%)        0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-flannel-ds-hs29q                       0 (0%)        0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-proxy-gqpz5                            0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  cinder-api-66f4f9678-2lgwk                  0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  glance-api-676fd49d4d-j4bdb                 0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  ingress-error-pages-586c7f86d6-455j5        0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  keystone-api-5bcc7cb698-vvwwr               0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  mariadb-ingress-84894687fd-dfnkm            0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  memcached-memcached-5db74ddfd5-wfr9q        0 (0%)        0 (0%)      0 (0%)           0 (0%)
  openstack                  rabbitmq-rabbitmq-0                         0 (0%)        0 (0%)      0 (0%)           0 (0%)

.. note::
  In this test env, MariaDB chart is deployed with only 1 replica. In order to
  test properly, the node with MariaDB server POD (mnode2) should not be shutdown.

.. note::
  In this test env, each node has Ceph and OpenStack related PODs. Due to this,
  shutting down a Node will cause issue with Ceph as well as OpenStack services.
  These PODs level failures are captured following subsequent screenshots.

``Check node status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get nodes
  NAME      STATUS     ROLES     AGE       VERSION
  mnode1    Ready      <none>    1h        v1.10.6
  mnode2    Ready      <none>    1h        v1.10.6
  mnode3    NotReady   <none>    1h        v1.10.6
  mnode4    Ready      <none>    1h        v1.10.6
  mnode5    Ready      <none>    1h        v1.10.6
  mnode6    Ready      <none>    1h        v1.10.6

``Ceph status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph -s
    cluster:
      id:     54d9af7e-da6d-4980-9075-96bb145db65c
      health: HEALTH_WARN
              insufficient standby MDS daemons available
              1 osds down
              1 host (1 osds) down
              Degraded data redundancy: 354/1062 objects degraded (33.333%), 46 pgs degraded, 101 pgs undersized
              1/3 mons down, quorum mnode1,mnode2

    services:
      mon: 3 daemons, quorum mnode1,mnode2, out of quorum: mnode3
      mgr: mnode2(active)
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-6f66956547-5x4ng=up:active}
      osd: 3 osds: 2 up, 3 in
      rgw: 1 daemon active

    data:
      pools:   19 pools, 101 pgs
      objects: 354 objects, 260 MB
      usage:   77845 MB used, 70068 MB / 144 GB avail
      pgs:     354/1062 objects degraded (33.333%)
               55 active+undersized
               46 active+undersized+degraded

``Ceph quorum status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph quorum_status -f json-pretty

.. code-block:: json

  {
      "election_epoch": 96,
      "quorum": [
          0,
          1
      ],
      "quorum_names": [
          "mnode1",
          "mnode2"
      ],
      "quorum_leader_name": "mnode1",
      "monmap": {
          "epoch": 1,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 21:02:24.330403",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              }
          ]
      }
  }


``Ceph MON Status:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph mon_status -f json-pretty

.. code-block:: json

  {
      "name": "mnode1",
      "rank": 0,
      "state": "leader",
      "election_epoch": 96,
      "quorum": [
          0,
          1
      ],
      "features": {
          "required_con": "153140804152475648",
          "required_mon": [
              "kraken",
              "luminous"
          ],
          "quorum_con": "2305244844532236283",
          "quorum_mon": [
              "kraken",
              "luminous"
          ]
      },
      "outside_quorum": [],
      "extra_probe_peers": [],
      "sync_provider": [],
      "monmap": {
          "epoch": 1,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 21:02:24.330403",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              }
          ]
      },
      "feature_map": {
          "mon": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "mds": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "osd": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "client": {
              "group": {
                  "features": "0x7010fb86aa42ada",
                  "release": "jewel",
                  "num": 1
              },
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 5
              }
          }
      }
  }

``Ceph PODs:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get pods -n ceph --show-all=false -o wide
  NAME                                       READY     STATUS     RESTARTS   AGE       IP               NODE
  ceph-cephfs-provisioner-784c6f9d59-n92dx   1/1       Running    0          1m        192.168.0.206    mnode1
  ceph-cephfs-provisioner-784c6f9d59-ndsgn   1/1       Running    0          1h        192.168.4.15     mnode2
  ceph-cephfs-provisioner-784c6f9d59-vgzzx   1/1       Unknown    0          1h        192.168.3.17     mnode3
  ceph-mds-6f66956547-57tf9                  1/1       Running    0          1m        192.168.0.207    mnode1
  ceph-mds-6f66956547-5x4ng                  1/1       Running    0          1h        192.168.4.14     mnode2
  ceph-mds-6f66956547-c25cx                  1/1       Unknown    0          1h        192.168.3.14     mnode3
  ceph-mgr-5746dd89db-9dbmv                  1/1       Unknown    0          1h        192.168.10.248   mnode3
  ceph-mgr-5746dd89db-d5fcw                  1/1       Running    0          1m        192.168.10.246   mnode1
  ceph-mgr-5746dd89db-qq4nl                  1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-mon-5qn68                             1/1       NodeLost   0          1h        192.168.10.248   mnode3
  ceph-mon-check-d85994946-4g5xc             1/1       Running    0          1h        192.168.4.8      mnode2
  ceph-mon-mwkj9                             1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-mon-ql9zp                             1/1       Running    0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-c7gdd            1/1       NodeLost   0          1h        192.168.10.248   mnode3
  ceph-osd-default-83945928-s6gs6            1/1       Running    0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-vsc5b            1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-rbd-provisioner-5bfb577ffd-j6hlx      1/1       Running    0          1h        192.168.4.16     mnode2
  ceph-rbd-provisioner-5bfb577ffd-kdmrv      1/1       Running    0          1m        192.168.0.209    mnode1
  ceph-rbd-provisioner-5bfb577ffd-zdx2d      1/1       Unknown    0          1h        192.168.3.16     mnode3
  ceph-rgw-6c64b444d7-4qgkw                  1/1       Running    0          1m        192.168.0.210    mnode1
  ceph-rgw-6c64b444d7-7bgqs                  1/1       Unknown    0          1h        192.168.3.12     mnode3
  ceph-rgw-6c64b444d7-hv6vn                  1/1       Running    0          1h        192.168.4.13     mnode2
  ingress-796d8cf8d6-4txkq                   1/1       Running    0          1h        192.168.2.6      mnode5
  ingress-796d8cf8d6-9t7m8                   1/1       Running    0          1h        192.168.5.4      mnode4
  ingress-error-pages-54454dc79b-hhb4f       1/1       Running    0          1h        192.168.2.5      mnode5
  ingress-error-pages-54454dc79b-twpgc       1/1       Running    0          1h        192.168.4.4      mnode2

``OpenStack PODs:``

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get pods -n openstack --show-all=false -o wide
  NAME                                           READY     STATUS    RESTARTS   AGE       IP              NODE
  cinder-api-66f4f9678-2lgwk                     1/1       Unknown   0          22m       192.168.3.41    mnode3
  cinder-api-66f4f9678-flvr5                     1/1       Running   0          22m       192.168.0.202   mnode1
  cinder-api-66f4f9678-w5xhd                     1/1       Running   0          1m        192.168.4.45    mnode2
  cinder-backup-659b68b474-582kr                 1/1       Running   0          22m       192.168.4.39    mnode2
  cinder-scheduler-6778f6f88c-mm9mt              1/1       Running   0          22m       192.168.0.201   mnode1
  cinder-volume-79b9bd8bb9-qsxdk                 1/1       Running   0          22m       192.168.4.40    mnode2
  cinder-volume-usage-audit-1534286100-mm8r7     1/1       Running   0          4m        192.168.4.44    mnode2
  glance-api-676fd49d4d-4tnm6                    1/1       Running   0          1m        192.168.0.212   mnode1
  glance-api-676fd49d4d-j4bdb                    1/1       Unknown   0          26m       192.168.3.37    mnode3
  glance-api-676fd49d4d-wtxqt                    1/1       Running   0          26m       192.168.4.31    mnode2
  ingress-7b4bc84cdd-9fs78                       1/1       Running   0          1h        192.168.5.3     mnode4
  ingress-7b4bc84cdd-wztz7                       1/1       Running   0          1h        192.168.1.4     mnode6
  ingress-error-pages-586c7f86d6-2jl5q           1/1       Running   0          1h        192.168.2.4     mnode5
  ingress-error-pages-586c7f86d6-455j5           1/1       Unknown   0          1h        192.168.3.3     mnode3
  ingress-error-pages-586c7f86d6-55j4x           1/1       Running   0          1m        192.168.4.47    mnode2
  keystone-api-5bcc7cb698-dzm8q                  1/1       Running   0          35m       192.168.4.24    mnode2
  keystone-api-5bcc7cb698-vvwwr                  1/1       Unknown   0          35m       192.168.3.25    mnode3
  keystone-api-5bcc7cb698-wx5l6                  1/1       Running   0          1m        192.168.0.213   mnode1
  mariadb-ingress-84894687fd-9lmpx               1/1       Running   0          1m        192.168.4.48    mnode2
  mariadb-ingress-84894687fd-dfnkm               1/1       Unknown   2          1h        192.168.3.20    mnode3
  mariadb-ingress-error-pages-78fb865f84-p8lpg   1/1       Running   0          1h        192.168.4.17    mnode2
  mariadb-server-0                               1/1       Running   0          1h        192.168.4.18    mnode2
  memcached-memcached-5db74ddfd5-926ln           1/1       Running   0          1m        192.168.4.49    mnode2
  memcached-memcached-5db74ddfd5-wfr9q           1/1       Unknown   0          38m       192.168.3.23    mnode3
  rabbitmq-rabbitmq-0                            1/1       Unknown   0          1h        192.168.3.21    mnode3
  rabbitmq-rabbitmq-1                            1/1       Running   0          1h        192.168.4.19    mnode2
  rabbitmq-rabbitmq-2                            1/1       Running   0          1h        192.168.0.195   mnode1


``Result/Observation:``

- PODs that were scheduled on mnode3 node has status of NodeLost/Unknown.
- Ceph status shows HEALTH_WARN as expected
- Ceph status shows 1 Ceph MON and 1 Ceph OSD missing.
- OpenStack PODs that were scheduled mnode3 also shows NodeLost/Unknown.

Step 3: Node Expansion
======================

Let's add more resources for K8s to schedule PODs on.

In this test env, let's use ``mnode4`` and apply Ceph and OpenStack related
labels.

.. note::
  Since the node that was shutdown earlier had both Ceph and OpenStack PODs,
  mnode4 should get Ceph and OpenStack related labels as well.

After applying labels, let's check status

``Ceph status:``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph -s
    cluster:
      id:     54d9af7e-da6d-4980-9075-96bb145db65c
      health: HEALTH_WARN
              1/4 mons down, quorum mnode1,mnode2,mnode4

    services:
      mon: 4 daemons, quorum mnode1,mnode2,mnode4, out of quorum: mnode3
      mgr: mnode2(active), standbys: mnode1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-6f66956547-5x4ng=up:active}, 1 up:standby
      osd: 4 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 101 pgs
      objects: 354 objects, 260 MB
      usage:   74684 MB used, 73229 MB / 144 GB avail
      pgs:     101 active+clean


``Ceph MON Status``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph mon_status -f json-pretty

.. code-block:: json

  {
      "name": "mnode2",
      "rank": 1,
      "state": "peon",
      "election_epoch": 100,
      "quorum": [
          0,
          1,
          3
      ],
      "features": {
          "required_con": "153140804152475648",
          "required_mon": [
              "kraken",
              "luminous"
          ],
          "quorum_con": "2305244844532236283",
          "quorum_mon": [
              "kraken",
              "luminous"
          ]
      },
      "outside_quorum": [],
      "extra_probe_peers": [
          "192.168.10.249:6789/0"
      ],
      "sync_provider": [],
      "monmap": {
          "epoch": 2,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 22:43:31.517568",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              },
              {
                  "rank": 3,
                  "name": "mnode4",
                  "addr": "192.168.10.249:6789/0",
                  "public_addr": "192.168.10.249:6789/0"
              }
          ]
      },
      "feature_map": {
          "mon": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "mds": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          },
          "osd": {
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 2
              }
          },
          "client": {
              "group": {
                  "features": "0x7010fb86aa42ada",
                  "release": "jewel",
                  "num": 1
              },
              "group": {
                  "features": "0x1ffddff8eea4fffb",
                  "release": "luminous",
                  "num": 1
              }
          }
      }
  }


``Ceph quorum status:``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph quorum_status -f json-pretty

.. code-block:: json

  {
      "election_epoch": 100,
      "quorum": [
          0,
          1,
          3
      ],
      "quorum_names": [
          "mnode1",
          "mnode2",
          "mnode4"
      ],
      "quorum_leader_name": "mnode1",
      "monmap": {
          "epoch": 2,
          "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
          "modified": "2018-08-14 22:43:31.517568",
          "created": "2018-08-14 21:02:24.330403",
          "features": {
              "persistent": [
                  "kraken",
                  "luminous"
              ],
              "optional": []
          },
          "mons": [
              {
                  "rank": 0,
                  "name": "mnode1",
                  "addr": "192.168.10.246:6789/0",
                  "public_addr": "192.168.10.246:6789/0"
              },
              {
                  "rank": 1,
                  "name": "mnode2",
                  "addr": "192.168.10.247:6789/0",
                  "public_addr": "192.168.10.247:6789/0"
              },
              {
                  "rank": 2,
                  "name": "mnode3",
                  "addr": "192.168.10.248:6789/0",
                  "public_addr": "192.168.10.248:6789/0"
              },
              {
                  "rank": 3,
                  "name": "mnode4",
                  "addr": "192.168.10.249:6789/0",
                  "public_addr": "192.168.10.249:6789/0"
              }
          ]
      }
  }


``Ceph PODs:``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl get pods -n ceph --show-all=false -o wide
  Flag --show-all has been deprecated, will be removed in an upcoming release
  NAME                                       READY     STATUS     RESTARTS   AGE       IP               NODE
  ceph-cephfs-provisioner-784c6f9d59-n92dx   1/1       Running    0          10m       192.168.0.206    mnode1
  ceph-cephfs-provisioner-784c6f9d59-ndsgn   1/1       Running    0          1h        192.168.4.15     mnode2
  ceph-cephfs-provisioner-784c6f9d59-vgzzx   1/1       Unknown    0          1h        192.168.3.17     mnode3
  ceph-mds-6f66956547-57tf9                  1/1       Running    0          10m       192.168.0.207    mnode1
  ceph-mds-6f66956547-5x4ng                  1/1       Running    0          1h        192.168.4.14     mnode2
  ceph-mds-6f66956547-c25cx                  1/1       Unknown    0          1h        192.168.3.14     mnode3
  ceph-mgr-5746dd89db-9dbmv                  1/1       Unknown    0          1h        192.168.10.248   mnode3
  ceph-mgr-5746dd89db-d5fcw                  1/1       Running    0          10m       192.168.10.246   mnode1
  ceph-mgr-5746dd89db-qq4nl                  1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-mon-5krkd                             1/1       Running    0          4m        192.168.10.249   mnode4
  ceph-mon-5qn68                             1/1       NodeLost   0          1h        192.168.10.248   mnode3
  ceph-mon-check-d85994946-4g5xc             1/1       Running    0          1h        192.168.4.8      mnode2
  ceph-mon-mwkj9                             1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-mon-ql9zp                             1/1       Running    0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-c7gdd            1/1       NodeLost   0          1h        192.168.10.248   mnode3
  ceph-osd-default-83945928-kf5tj            1/1       Running    0          4m        192.168.10.249   mnode4
  ceph-osd-default-83945928-s6gs6            1/1       Running    0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-vsc5b            1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-rbd-provisioner-5bfb577ffd-j6hlx      1/1       Running    0          1h        192.168.4.16     mnode2
  ceph-rbd-provisioner-5bfb577ffd-kdmrv      1/1       Running    0          10m       192.168.0.209    mnode1
  ceph-rbd-provisioner-5bfb577ffd-zdx2d      1/1       Unknown    0          1h        192.168.3.16     mnode3
  ceph-rgw-6c64b444d7-4qgkw                  1/1       Running    0          10m       192.168.0.210    mnode1
  ceph-rgw-6c64b444d7-7bgqs                  1/1       Unknown    0          1h        192.168.3.12     mnode3
  ceph-rgw-6c64b444d7-hv6vn                  1/1       Running    0          1h        192.168.4.13     mnode2
  ingress-796d8cf8d6-4txkq                   1/1       Running    0          1h        192.168.2.6      mnode5
  ingress-796d8cf8d6-9t7m8                   1/1       Running    0          1h        192.168.5.4      mnode4
  ingress-error-pages-54454dc79b-hhb4f       1/1       Running    0          1h        192.168.2.5      mnode5
  ingress-error-pages-54454dc79b-twpgc       1/1       Running    0          1h        192.168.4.4      mnode2

``OpenStack PODs:``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl get pods -n openstack --show-all=false -o wide
  Flag --show-all has been deprecated, will be removed in an upcoming release
  NAME                                           READY     STATUS    RESTARTS   AGE       IP              NODE
  cinder-api-66f4f9678-2lgwk                     1/1       Unknown   0          32m       192.168.3.41    mnode3
  cinder-api-66f4f9678-flvr5                     1/1       Running   0          32m       192.168.0.202   mnode1
  cinder-api-66f4f9678-w5xhd                     1/1       Running   0          11m       192.168.4.45    mnode2
  cinder-backup-659b68b474-582kr                 1/1       Running   0          32m       192.168.4.39    mnode2
  cinder-scheduler-6778f6f88c-mm9mt              1/1       Running   0          32m       192.168.0.201   mnode1
  cinder-volume-79b9bd8bb9-qsxdk                 1/1       Running   0          32m       192.168.4.40    mnode2
  glance-api-676fd49d4d-4tnm6                    1/1       Running   0          11m       192.168.0.212   mnode1
  glance-api-676fd49d4d-j4bdb                    1/1       Unknown   0          36m       192.168.3.37    mnode3
  glance-api-676fd49d4d-wtxqt                    1/1       Running   0          36m       192.168.4.31    mnode2
  ingress-7b4bc84cdd-9fs78                       1/1       Running   0          1h        192.168.5.3     mnode4
  ingress-7b4bc84cdd-wztz7                       1/1       Running   0          1h        192.168.1.4     mnode6
  ingress-error-pages-586c7f86d6-2jl5q           1/1       Running   0          1h        192.168.2.4     mnode5
  ingress-error-pages-586c7f86d6-455j5           1/1       Unknown   0          1h        192.168.3.3     mnode3
  ingress-error-pages-586c7f86d6-55j4x           1/1       Running   0          11m       192.168.4.47    mnode2
  keystone-api-5bcc7cb698-dzm8q                  1/1       Running   0          45m       192.168.4.24    mnode2
  keystone-api-5bcc7cb698-vvwwr                  1/1       Unknown   0          45m       192.168.3.25    mnode3
  keystone-api-5bcc7cb698-wx5l6                  1/1       Running   0          11m       192.168.0.213   mnode1
  mariadb-ingress-84894687fd-9lmpx               1/1       Running   0          11m       192.168.4.48    mnode2
  mariadb-ingress-84894687fd-dfnkm               1/1       Unknown   2          1h        192.168.3.20    mnode3
  mariadb-ingress-error-pages-78fb865f84-p8lpg   1/1       Running   0          1h        192.168.4.17    mnode2
  mariadb-server-0                               1/1       Running   0          1h        192.168.4.18    mnode2
  memcached-memcached-5db74ddfd5-926ln           1/1       Running   0          11m       192.168.4.49    mnode2
  memcached-memcached-5db74ddfd5-wfr9q           1/1       Unknown   0          48m       192.168.3.23    mnode3
  rabbitmq-rabbitmq-0                            1/1       Unknown   0          1h        192.168.3.21    mnode3
  rabbitmq-rabbitmq-1                            1/1       Running   0          1h        192.168.4.19    mnode2
  rabbitmq-rabbitmq-2                            1/1       Running   0          1h        192.168.0.195   mnode1


``Result/Observation:``

- Ceph MON and OSD PODs got scheduled on mnode4 node.
- Ceph status shows that MON and OSD count has been increased.
- Ceph status still shows HEALTH_WARN as one MON and OSD are still down.

Step 4: Ceph cluster recovery
=============================

Now that we have added new node for Ceph and OpenStack PODs, let's perform
maintenance on Ceph cluster.

1) Remove out of quorum MON:
----------------------------

Using ``ceph mon_status`` and ``ceph -s`` commands, confirm ID of MON that is out of quorum.

In this test env, ``mnode3`` is out of quorum.

.. note::
  In this test env, since out of quorum MON is no longer available due to node failure, we can
  processed with removing it from Ceph cluster.

``Remove MON from Ceph cluster``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph mon remove mnode3
  removing mon.mnode3 at 192.168.10.248:6789/0, there will be 3 monitors

``Ceph Status:``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph -s
    cluster:
      id:     54d9af7e-da6d-4980-9075-96bb145db65c
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum mnode1,mnode2,mnode4
      mgr: mnode2(active), standbys: mnode1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-6f66956547-5x4ng=up:active}, 1 up:standby
      osd: 4 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 101 pgs
      objects: 354 objects, 260 MB
      usage:   74705 MB used, 73208 MB / 144 GB avail
      pgs:     101 active+clean

    io:
      client:   132 kB/s wr, 0 op/s rd, 23 op/s wr

As shown above, Ceph status is now HEALTH_OK and shows 3 MONs available.

``Ceph MON Status``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph mon_status -f json-pretty

.. code-block:: json

    {
        "name": "mnode4",
        "rank": 2,
        "state": "peon",
        "election_epoch": 106,
        "quorum": [
            0,
            1,
            2
        ],
        "features": {
            "required_con": "153140804152475648",
            "required_mon": [
                "kraken",
                "luminous"
            ],
            "quorum_con": "2305244844532236283",
            "quorum_mon": [
                "kraken",
                "luminous"
            ]
        },
        "outside_quorum": [],
        "extra_probe_peers": [],
        "sync_provider": [],
        "monmap": {
            "epoch": 3,
            "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
            "modified": "2018-08-14 22:55:41.256612",
            "created": "2018-08-14 21:02:24.330403",
            "features": {
                "persistent": [
                    "kraken",
                    "luminous"
                ],
                "optional": []
            },
            "mons": [
                {
                    "rank": 0,
                    "name": "mnode1",
                    "addr": "192.168.10.246:6789/0",
                    "public_addr": "192.168.10.246:6789/0"
                },
                {
                    "rank": 1,
                    "name": "mnode2",
                    "addr": "192.168.10.247:6789/0",
                    "public_addr": "192.168.10.247:6789/0"
                },
                {
                    "rank": 2,
                    "name": "mnode4",
                    "addr": "192.168.10.249:6789/0",
                    "public_addr": "192.168.10.249:6789/0"
                }
            ]
        },
        "feature_map": {
            "mon": {
                "group": {
                    "features": "0x1ffddff8eea4fffb",
                    "release": "luminous",
                    "num": 1
                }
            },
            "client": {
                "group": {
                    "features": "0x1ffddff8eea4fffb",
                    "release": "luminous",
                    "num": 1
                }
            }
        }
    }

``Ceph quorum status``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph quorum_status -f json-pretty

.. code-block:: json


    {
        "election_epoch": 106,
        "quorum": [
            0,
            1,
            2
        ],
        "quorum_names": [
            "mnode1",
            "mnode2",
            "mnode4"
        ],
        "quorum_leader_name": "mnode1",
        "monmap": {
            "epoch": 3,
            "fsid": "54d9af7e-da6d-4980-9075-96bb145db65c",
            "modified": "2018-08-14 22:55:41.256612",
            "created": "2018-08-14 21:02:24.330403",
            "features": {
                "persistent": [
                    "kraken",
                    "luminous"
                ],
                "optional": []
            },
            "mons": [
                {
                    "rank": 0,
                    "name": "mnode1",
                    "addr": "192.168.10.246:6789/0",
                    "public_addr": "192.168.10.246:6789/0"
                },
                {
                    "rank": 1,
                    "name": "mnode2",
                    "addr": "192.168.10.247:6789/0",
                    "public_addr": "192.168.10.247:6789/0"
                },
                {
                    "rank": 2,
                    "name": "mnode4",
                    "addr": "192.168.10.249:6789/0",
                    "public_addr": "192.168.10.249:6789/0"
                }
            ]
        }
    }


2) Remove down OSD from Ceph cluster:
-------------------------------------

As shown in Ceph status above, ``osd: 4 osds: 3 up, 3 in`` 1 of 4 OSDs is still
down. Let's remove that OSD.

First, run ``ceph osd tree`` command to get list of OSDs.

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph osd tree
  ID CLASS WEIGHT  TYPE NAME       STATUS REWEIGHT PRI-AFF
  -1       0.19995 root default
  -7       0.04999     host mnode1
   2   hdd 0.04999         osd.2       up  1.00000 1.00000
  -2       0.04999     host mnode2
   0   hdd 0.04999         osd.0       up  1.00000 1.00000
  -3       0.04999     host mnode3
   1   hdd 0.04999         osd.1     down        0 1.00000
  -9       0.04999     host mnode4
   3   hdd 0.04999         osd.3       up  1.00000 1.00000

Above output shows that ``osd.1`` is down.

Run ``ceph osd purge`` command to remove OSD from ceph cluster.

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph osd purge osd.1 --yes-i-really-mean-it
  purged osd.1

``Ceph status``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl exec -n ceph ceph-mon-ql9zp -- ceph -s
    cluster:
      id:     54d9af7e-da6d-4980-9075-96bb145db65c
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum mnode1,mnode2,mnode4
      mgr: mnode2(active), standbys: mnode1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-6f66956547-5x4ng=up:active}, 1 up:standby
      osd: 3 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 101 pgs
      objects: 354 objects, 260 MB
      usage:   74681 MB used, 73232 MB / 144 GB avail
      pgs:     101 active+clean

    io:
      client:   57936 B/s wr, 0 op/s rd, 14 op/s wr

Above output shows Ceph cluster in HEALTH_OK with all OSDs and MONs up and running.

``Ceph PODs``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl get pods -n ceph --show-all=false -o wide
  Flag --show-all has been deprecated, will be removed in an upcoming release
  NAME                                       READY     STATUS     RESTARTS   AGE       IP               NODE
  ceph-cephfs-provisioner-784c6f9d59-n92dx   1/1       Running    0          25m       192.168.0.206    mnode1
  ceph-cephfs-provisioner-784c6f9d59-ndsgn   1/1       Running    0          1h        192.168.4.15     mnode2
  ceph-cephfs-provisioner-784c6f9d59-vgzzx   1/1       Unknown    0          1h        192.168.3.17     mnode3
  ceph-mds-6f66956547-57tf9                  1/1       Running    0          25m       192.168.0.207    mnode1
  ceph-mds-6f66956547-5x4ng                  1/1       Running    0          1h        192.168.4.14     mnode2
  ceph-mds-6f66956547-c25cx                  1/1       Unknown    0          1h        192.168.3.14     mnode3
  ceph-mgr-5746dd89db-9dbmv                  1/1       Unknown    0          1h        192.168.10.248   mnode3
  ceph-mgr-5746dd89db-d5fcw                  1/1       Running    0          25m       192.168.10.246   mnode1
  ceph-mgr-5746dd89db-qq4nl                  1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-mon-5krkd                             1/1       Running    0          19m       192.168.10.249   mnode4
  ceph-mon-5qn68                             1/1       NodeLost   0          2h        192.168.10.248   mnode3
  ceph-mon-check-d85994946-4g5xc             1/1       Running    0          2h        192.168.4.8      mnode2
  ceph-mon-mwkj9                             1/1       Running    0          2h        192.168.10.247   mnode2
  ceph-mon-ql9zp                             1/1       Running    0          2h        192.168.10.246   mnode1
  ceph-osd-default-83945928-c7gdd            1/1       NodeLost   0          1h        192.168.10.248   mnode3
  ceph-osd-default-83945928-kf5tj            1/1       Running    0          19m       192.168.10.249   mnode4
  ceph-osd-default-83945928-s6gs6            1/1       Running    0          1h        192.168.10.246   mnode1
  ceph-osd-default-83945928-vsc5b            1/1       Running    0          1h        192.168.10.247   mnode2
  ceph-rbd-provisioner-5bfb577ffd-j6hlx      1/1       Running    0          1h        192.168.4.16     mnode2
  ceph-rbd-provisioner-5bfb577ffd-kdmrv      1/1       Running    0          25m       192.168.0.209    mnode1
  ceph-rbd-provisioner-5bfb577ffd-zdx2d      1/1       Unknown    0          1h        192.168.3.16     mnode3
  ceph-rgw-6c64b444d7-4qgkw                  1/1       Running    0          25m       192.168.0.210    mnode1
  ceph-rgw-6c64b444d7-7bgqs                  1/1       Unknown    0          1h        192.168.3.12     mnode3
  ceph-rgw-6c64b444d7-hv6vn                  1/1       Running    0          1h        192.168.4.13     mnode2
  ingress-796d8cf8d6-4txkq                   1/1       Running    0          2h        192.168.2.6      mnode5
  ingress-796d8cf8d6-9t7m8                   1/1       Running    0          2h        192.168.5.4      mnode4
  ingress-error-pages-54454dc79b-hhb4f       1/1       Running    0          2h        192.168.2.5      mnode5
  ingress-error-pages-54454dc79b-twpgc       1/1       Running    0          2h        192.168.4.4      mnode2

``OpenStack PODs``

.. code-block:: console

  ubuntu@mnode1:~$ kubectl get pods -n openstack --show-all=false -o wide
  Flag --show-all has been deprecated, will be removed in an upcoming release
  NAME                                           READY     STATUS    RESTARTS   AGE       IP              NODE
  cinder-api-66f4f9678-2lgwk                     1/1       Unknown   0          47m       192.168.3.41    mnode3
  cinder-api-66f4f9678-flvr5                     1/1       Running   0          47m       192.168.0.202   mnode1
  cinder-api-66f4f9678-w5xhd                     1/1       Running   0          26m       192.168.4.45    mnode2
  cinder-backup-659b68b474-582kr                 1/1       Running   0          47m       192.168.4.39    mnode2
  cinder-scheduler-6778f6f88c-mm9mt              1/1       Running   0          47m       192.168.0.201   mnode1
  cinder-volume-79b9bd8bb9-qsxdk                 1/1       Running   0          47m       192.168.4.40    mnode2
  glance-api-676fd49d4d-4tnm6                    1/1       Running   0          26m       192.168.0.212   mnode1
  glance-api-676fd49d4d-j4bdb                    1/1       Unknown   0          51m       192.168.3.37    mnode3
  glance-api-676fd49d4d-wtxqt                    1/1       Running   0          51m       192.168.4.31    mnode2
  ingress-7b4bc84cdd-9fs78                       1/1       Running   0          2h        192.168.5.3     mnode4
  ingress-7b4bc84cdd-wztz7                       1/1       Running   0          2h        192.168.1.4     mnode6
  ingress-error-pages-586c7f86d6-2jl5q           1/1       Running   0          2h        192.168.2.4     mnode5
  ingress-error-pages-586c7f86d6-455j5           1/1       Unknown   0          2h        192.168.3.3     mnode3
  ingress-error-pages-586c7f86d6-55j4x           1/1       Running   0          26m       192.168.4.47    mnode2
  keystone-api-5bcc7cb698-dzm8q                  1/1       Running   0          1h        192.168.4.24    mnode2
  keystone-api-5bcc7cb698-vvwwr                  1/1       Unknown   0          1h        192.168.3.25    mnode3
  keystone-api-5bcc7cb698-wx5l6                  1/1       Running   0          26m       192.168.0.213   mnode1
  mariadb-ingress-84894687fd-9lmpx               1/1       Running   0          26m       192.168.4.48    mnode2
  mariadb-ingress-84894687fd-dfnkm               1/1       Unknown   2          1h        192.168.3.20    mnode3
  mariadb-ingress-error-pages-78fb865f84-p8lpg   1/1       Running   0          1h        192.168.4.17    mnode2
  mariadb-server-0                               1/1       Running   0          1h        192.168.4.18    mnode2
  memcached-memcached-5db74ddfd5-926ln           1/1       Running   0          26m       192.168.4.49    mnode2
  memcached-memcached-5db74ddfd5-wfr9q           1/1       Unknown   0          1h        192.168.3.23    mnode3
  rabbitmq-rabbitmq-0                            1/1       Unknown   0          1h        192.168.3.21    mnode3
  rabbitmq-rabbitmq-1                            1/1       Running   0          1h        192.168.4.19    mnode2
  rabbitmq-rabbitmq-2                            1/1       Running   0          1h        192.168.0.195   mnode1
