.. -*- coding: utf-8 -*-

.. NOTE TO MAINTAINERS: use rst2html script to convert .rst to .html
   rst2html ./failure-domain.rst ./failure-domain.html
   open ./failure-domain.html

==============================
 Failure Domains in CRUSH Map
==============================

.. contents::
.. sectnum::

Overview
========

The `CRUSH Map <http://docs.ceph.com/docs/master/rados/operations/crush-map/?highlight=hammer%20profile>`__ in a Ceph cluster is best visualized
as an inverted tree.  The hierarchical layout describes the physical
topology of the Ceph cluster.  Through the physical topology, failure
domains are conceptualized from the different branches in the inverted
tree.  CRUSH rules are created and map to failure domains with data
placement policy to distribute the data.

The internal nodes (non-leaves and non-root) in the hierarchy are identified
as buckets.  Each bucket is a hierarchical aggregation of storage locations
and their assigned weights.  These are the types defined by CRUSH as the
supported buckets.

::

  # types
  type 0 osd
  type 1 host
  type 2 chassis
  type 3 rack
  type 4 row
  type 5 pdu
  type 6 pod
  type 7 room
  type 8 datacenter
  type 9 region
  type 10 root

This guide describes the host and rack buckets and their role in constructing
a CRUSH Map with separate failure domains.  Once a Ceph cluster is configured
with the expected CRUSh Map and Rule, the PGs of the designated pool are
verified with a script (**utils-checkPGs.py**) to ensure that the OSDs in all the PGs
reside in separate failure domains.

Ceph Environment
================

The ceph commands and scripts described in this write-up are executed as
Linux user root on one of orchestration nodes and one of the ceph monitors
deployed as kubernetes pods. The root user has the credential to execute
all the ceph commands.

On a kubernetes cluster, a separate namespace named **ceph** is configured
for the ceph cluster.  Include the **ceph** namespace in **kubectl** when
executing this command.

A kubernetes pod is a collection of docker containers sharing a network
and mount namespace.  It is the basic unit of deployment in the kubernetes
cluster.  The node in the kubernetes cluster where the orchestration
operations are performed needs access to the **kubectl** command.  In this
guide, this node is referred to as the orchestration node.  On this
node, you can list all the pods that are deployed.  To execute a command
in a given pod, use **kubectl** to locate the name of the pod and switch
to it to execute the command.

Orchestration Node
------------------

To gain access to the kubernetes orchestration node, use your login
credential and the authentication procedure assigned to you.  For
environments setup with SSH key-based access, your id_rsa.pub (generated
through the ssh-keygen) public key should be in your ~/.ssh/authorized_keys
file on the orchestration node.

The kubernetes and ceph commands require the root login credential to
execute.  Your Linux login requires the *sudo* privilege to execute
commands as user root.  On the orchestration node, acquire the root's
privilege with your Linux login through the *sudo* command.

::

  [orchestration]$ sudo -i
  <Your Linux login's password>:
  [orchestration]#

Kubernetes Pods
---------------

On the orchestration node, execute the **kubectl** command to list the
specific set of pods with the **--selector** option.  This **kubectl**
command lists all the ceph monitor pods.

::

  [orchestration]# kubectl get pods -n ceph --selector component=mon
  NAME             READY     STATUS    RESTARTS   AGE
  ceph-mon-85mlt   2/2       Running   0          9d
  ceph-mon-9mpnb   2/2       Running   0          9d
  ceph-mon-rzzqr   2/2       Running   0          9d
  ceph-mon-snds8   2/2       Running   0          9d
  ceph-mon-snzwx   2/2       Running   0          9d

The following **kubectl** command lists the Ceph OSD pods.

::

  [orchestration]# kubectl get pods -n ceph --selector component=osd
  NAME                              READY     STATUS    RESTARTS   AGE
  ceph-osd-default-166a1044-95s74   2/2       Running   0          9d
  ceph-osd-default-166a1044-bglnm   2/2       Running   0          9d
  ceph-osd-default-166a1044-lq5qq   2/2       Running   0          9d
  ceph-osd-default-166a1044-lz6x6   2/2       Running   0          9d
  . . .

To list all the pods in all the namespaces, execute this **kubectl** command.

::

  [orchestration]# kubectl get pods --all-namespaces
  NAMESPACE     NAME                                       READY     STATUS      RESTARTS   AGE
  ceph          ceph-bootstrap-rpzld                       0/1       Completed   0          10d
  ceph          ceph-cephfs-client-key-generator-pvzs6     0/1       Completed   0          10d
  ceph          ceph-cephfs-provisioner-796668cd7-bn6mn    1/1       Running     0          10d


Execute Commands in Pods
^^^^^^^^^^^^^^^^^^^^^^^^

To execute multiple commands in a pod, you can switch to the execution
context of the pod with a /bin/bash session.

::

  [orchestration]# kubectl exec -it ceph-mon-85mlt -n ceph -- /bin/bash
  [ceph-mon]# ceph status
    cluster:
      id:     07c31d0f-bcc6-4db4-aadf-2d2a0f13edb8
      health: HEALTH_OK

    services:
      mon: 5 daemons, quorum host1,host2,host3,host4,host5
      mgr: host6(active), standbys: host1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-7cb4f57cc-prh87=up:active}, 1 up:standby
      osd: 72 osds: 72 up, 72 in
      rgw: 2 daemons active

    data:
      pools:   20 pools, 3944 pgs
      objects: 86970 objects, 323 GB
      usage:   1350 GB used, 79077 GB / 80428 GB avail
      pgs:     3944 active+clean

    io:
      client:   981 kB/s wr, 0 op/s rd, 84 op/s wr

To verify that you are executing within the context of a pod.  Display the
content of the */proc/self/cgroup* control group file.  The *kubepods* output
in the cgroup file shows that you're executing in a docker container of a pod.

::

  [ceph-mon]# cat /proc/self/cgroup
  11:hugetlb:/kubepods/besteffort/podafb3689c-8c5b-11e8-be6a-246e96290f14/ff6cbc58348a44722ee6a493845b9c2903fabdce80d0902d217cc4d6962d7b53
  . . .

To exit the pod and resume the orchestration node's execution context.

::

  [ceph-mon]# exit
  [orchestration]#

To verify that you are executing on the orchestration node's context, display
the */proc/self/cgroup* control group file.  You would not see the *kubepods*
docker container in the output.

::

  [orchestration]# cat /proc/self/cgroup
  11:blkio:/user.slice
  10:freezer:/
  9:hugetlb:/
  . . .

It is also possible to run the ceph commands via the **kubectl exec**
without switching to a pod's container.

::

  [orchestration]# kubectl exec ceph-mon-9mpnb -n ceph -- ceph status
    cluster:
      id:     07c31d0f-bcc6-4db4-aadf-2d2a0f13edb8
      health: HEALTH_OK
  . . .


Failure Domains
===============

A failure domain provides the fault isolation for the data and it corresponds
to a branch on the hierarchical topology.  To protect against data loss, OSDs
that are allocated to PGs should be chosen from different failure
domains.  Losing a branch takes down all the OSDs in that branch only and
OSDs in the other branches are not effected.

In a data center, baremetal hosts are typically installed in a
rack (refrigerator size cabinet).  Multiple racks with hosts in each rack
are used to provision the OSDs running on each host.  A rack is envisioned
as a branch in the CRUSH topology.

To provide data redundancy, ceph maintains multiple copies of the data.  The
total number of copies to store for each piece of data is determined by the
ceph **osd_pool_default_size** ceph.conf parameter.  With this parameter set
to 3, each piece of the data has 3 copies that gets stored in a pool.  Each
copy is stored on different OSDs allocated from different failure domains.

Host
----

Choosing host as the failure domain lacks all the protections against
data loss.

To illustrate, a Ceph cluster has been provisioned with six hosts and four
OSDs on each host.  The hosts are enclosed in respective racks where each
rack contains two hosts.

In the configuration of the Ceph cluster, without explicit instructions on
where the host and rack buckets should be placed, Ceph would create a
CRUSH map without the rack bucket.  A CRUSH rule that get created uses
the host as the failure domain.  With the size (replica) of a pool set
to 3, the OSDs in all the PGs are allocated from different hosts.

::

  root=default
  ├── host1
  │   ├── osd.1
  │   ├── osd.2
  │   ├── osd.3
  │   └── osd.4
  ├── host2
  │   ├── osd.5
  │   ├── osd.6
  │   ├── osd.7
  │   └── osd.8
  ├── host3
  │   ├── osd.9
  │   ├── osd.10
  │   ├── osd.11
  │   └── osd.12
  ├── host4
  │   ├── osd.13
  │   ├── osd.14
  │   ├── osd.15
  │   └── osd.16
  ├── host5
  │   ├── osd.17
  │   ├── osd.18
  │   ├── osd.19
  │   └── osd.20
  └── host6
      ├── osd.21
      ├── osd.22
      ├── osd.23
      └── osd.24

On this ceph cluster, it has a CRUSH rule that uses the host as the
failure domain.

::

  # ceph osd crush rule ls
  replicated_host
  # ceph osd crush rule dump replicated_host
  {
      "rule_id": 0,
      "rule_name": "replicated_host",
      "ruleset": 0,
      "type": 1,
      "min_size": 1,
      "max_size": 10,
      "steps": [
          {
              "op": "take",
              "item": -1,
              "item_name": "default"
          },
          {
              "op": "chooseleaf_firstn",
              "num": 0,
              "type": "host" },
          {
              "op": "emit"
          }
      ]
  }

Verify the CRUSH rule that is assigned to the ceph pool.  In this
example, the rbd pool is used.

::

  # ceph osd pool get rbd crush_rule
  crush_rule: replicated_host
  # ceph osd pool get rbd size
  size: 3
  # ceph osd pool get rbd pg_num
  pg_num: 1024


To verify that the OSDs in all the PGs are allocated from different
hosts, invoke the **utils-checkPGs.py** utility on the ceph pool.  The offending
PGs are printed to stdout.

::

  # /tmp/utils-checkPGs.py rbd
  Checking PGs in pool rbd ... Passed

With host as the failure domain, quite possibly, some of the PGs might
have OSDs allocated from different hosts that are located in the same
rack.  For example, one PG might have OSD numbers [1, 8, 13]. OSDs 1 and 8
are found on hosts located in rack1.  When rack1 suffers a catastrophe
failure, PGs with OSDs allocated from the hosts in rack1 would be severely
degraded.

Rack
----

Choosing rack as the failure domain provides better protection against data
loss.

To prevent PGs with OSDs allocated from hosts that are located in the same
rack, configure the CRUSH hierarchy with the rack buckets.  In each rack
bucket, it contains the hosts that reside in the same physical rack.  A
CRUSH Rule is configured with rack as the failure domain.

In the following hierarchical topology, the Ceph cluster was configured with
three rack buckets.  Each bucket has two hosts.  In pools that were created
with the CRUSH rule set to rack, the OSDs in all the PGs are allocated from
the distinct rack.

::

  root=default
  ├── rack1
  │   ├── host1
  │   │   ├── osd.1
  │   │   ├── osd.2
  │   │   ├── osd.3
  │   │   └── osd.4
  │   └── host2
  │       ├── osd.5
  │       ├── osd.6
  │       ├── osd.7
  │       └── osd.8
  ├── rack2
  │   ├── host3
  │   │   ├── osd.9
  │   │   ├── osd.10
  │   │   ├── osd.11
  │   │   └── osd.12
  │   └── host4
  │       ├── osd.13
  │       ├── osd.14
  │       ├── osd.15
  │       └── osd.16
  └── rack3
      ├── host5
      │   ├── osd.17
      │   ├── osd.18
      │   ├── osd.19
      │   └── osd.20
      └── host6
          ├── osd.21
          ├── osd.22
          ├── osd.23
          └── osd.24

Verify the Ceph cluster has a CRUSH rule with rack as the failure domain.

::

  # ceph osd crush rule ls
  rack_replicated_rule
  # ceph osd crush rule dump rack_replicated_rule
  {
      "rule_id": 2,
      "rule_name": "rack_replicated_rule",
      "ruleset": 2,
      "type": 1,
      "min_size": 1,
      "max_size": 10,
      "steps": [
          {
              "op": "take",
              "item": -1,
              "item_name": "default"
          },
          {
              "op": "chooseleaf_firstn",
              "num": 0,
              "type": "rack"
          },
          {
              "op": "emit"
          }
      ]
  }

Create a ceph pool with its CRUSH rule set to the rack's rule.

::

  # ceph osd pool create rbd 2048 2048 replicated rack_replicated_rule
  pool 'rbd' created
  # ceph osd pool get rbd crush_rule
  crush_rule: rack_replicated_rule
  # ceph osd pool get rbd size
  size: 3
  # ceph osd pool get rbd pg_num
  pg_num: 2048

Invoke the **utils-checkPGs.py** script on the pool to verify that there are no PGs
with OSDs allocated from the same rack.  The offending PGs are printed to
stdout.

::

  # /tmp/utils-checkPGs.py rbd
  Checking PGs in pool rbd ... Passed


CRUSH Map and Rule
==================

On a properly configured Ceph cluster, there are different ways to view
the CRUSH hierarchy.

ceph CLI
--------

Print to stdout the CRUSH hierarchy with the ceph CLI.

::

  root@host5:/# ceph osd crush tree
  ID  CLASS WEIGHT   TYPE NAME
   -1       78.47974 root default
  -15       26.15991     rack rack1
   -2       13.07996         host host1
    0   hdd  1.09000             osd.0
    1   hdd  1.09000             osd.1
    2   hdd  1.09000             osd.2
    3   hdd  1.09000             osd.3
    4   hdd  1.09000             osd.4
    5   hdd  1.09000             osd.5
    6   hdd  1.09000             osd.6
    7   hdd  1.09000             osd.7
    8   hdd  1.09000             osd.8
    9   hdd  1.09000             osd.9
   10   hdd  1.09000             osd.10
   11   hdd  1.09000             osd.11
   -5       13.07996         host host2
   12   hdd  1.09000             osd.12
   13   hdd  1.09000             osd.13
   14   hdd  1.09000             osd.14
   15   hdd  1.09000             osd.15
   16   hdd  1.09000             osd.16
   17   hdd  1.09000             osd.17
   18   hdd  1.09000             osd.18
   19   hdd  1.09000             osd.19
   20   hdd  1.09000             osd.20
   21   hdd  1.09000             osd.21
   22   hdd  1.09000             osd.22
   23   hdd  1.09000             osd.23
  -16       26.15991     rack rack2
  -13       13.07996         host host3
   53   hdd  1.09000             osd.53
   54   hdd  1.09000             osd.54
   58   hdd  1.09000             osd.58
   59   hdd  1.09000             osd.59
   64   hdd  1.09000             osd.64
   65   hdd  1.09000             osd.65
   66   hdd  1.09000             osd.66
   67   hdd  1.09000             osd.67
   68   hdd  1.09000             osd.68
   69   hdd  1.09000             osd.69
   70   hdd  1.09000             osd.70
   71   hdd  1.09000             osd.71
   -9       13.07996         host host4
   36   hdd  1.09000             osd.36
   37   hdd  1.09000             osd.37
   38   hdd  1.09000             osd.38
   39   hdd  1.09000             osd.39
   40   hdd  1.09000             osd.40
   41   hdd  1.09000             osd.41
   42   hdd  1.09000             osd.42
   43   hdd  1.09000             osd.43
   44   hdd  1.09000             osd.44
   45   hdd  1.09000             osd.45
   46   hdd  1.09000             osd.46
   47   hdd  1.09000             osd.47
  -17       26.15991     rack rack3
  -11       13.07996         host host5
   48   hdd  1.09000             osd.48
   49   hdd  1.09000             osd.49
   50   hdd  1.09000             osd.50
   51   hdd  1.09000             osd.51
   52   hdd  1.09000             osd.52
   55   hdd  1.09000             osd.55
   56   hdd  1.09000             osd.56
   57   hdd  1.09000             osd.57
   60   hdd  1.09000             osd.60
   61   hdd  1.09000             osd.61
   62   hdd  1.09000             osd.62
   63   hdd  1.09000             osd.63
   -7       13.07996         host host6
   24   hdd  1.09000             osd.24
   25   hdd  1.09000             osd.25
   26   hdd  1.09000             osd.26
   27   hdd  1.09000             osd.27
   28   hdd  1.09000             osd.28
   29   hdd  1.09000             osd.29
   30   hdd  1.09000             osd.30
   31   hdd  1.09000             osd.31
   32   hdd  1.09000             osd.32
   33   hdd  1.09000             osd.33
   34   hdd  1.09000             osd.34
   35   hdd  1.09000             osd.35
  root@host5:/#

To see weight and affinity of each OSD.

::

  root@host5:/# ceph osd tree
  ID  CLASS WEIGHT   TYPE NAME                 STATUS REWEIGHT PRI-AFF
   -1       78.47974 root default
  -15       26.15991     rack rack1
   -2       13.07996         host host1
    0   hdd  1.09000             osd.0             up  1.00000 1.00000
    1   hdd  1.09000             osd.1             up  1.00000 1.00000
    2   hdd  1.09000             osd.2             up  1.00000 1.00000
    3   hdd  1.09000             osd.3             up  1.00000 1.00000
    4   hdd  1.09000             osd.4             up  1.00000 1.00000
    5   hdd  1.09000             osd.5             up  1.00000 1.00000
    6   hdd  1.09000             osd.6             up  1.00000 1.00000
    7   hdd  1.09000             osd.7             up  1.00000 1.00000
    8   hdd  1.09000             osd.8             up  1.00000 1.00000
    9   hdd  1.09000             osd.9             up  1.00000 1.00000
   10   hdd  1.09000             osd.10            up  1.00000 1.00000
   11   hdd  1.09000             osd.11            up  1.00000 1.00000
   -5       13.07996         host host2
   12   hdd  1.09000             osd.12            up  1.00000 1.00000
   13   hdd  1.09000             osd.13            up  1.00000 1.00000
   14   hdd  1.09000             osd.14            up  1.00000 1.00000
   15   hdd  1.09000             osd.15            up  1.00000 1.00000
   16   hdd  1.09000             osd.16            up  1.00000 1.00000
   17   hdd  1.09000             osd.17            up  1.00000 1.00000
   18   hdd  1.09000             osd.18            up  1.00000 1.00000
   19   hdd  1.09000             osd.19            up  1.00000 1.00000
   20   hdd  1.09000             osd.20            up  1.00000 1.00000
   21   hdd  1.09000             osd.21            up  1.00000 1.00000
   22   hdd  1.09000             osd.22            up  1.00000 1.00000
   23   hdd  1.09000             osd.23            up  1.00000 1.00000



crushtool CLI
-------------

To extract the CRUSH Map from a running cluster and convert it into ascii text.

::

  # ceph osd getcrushmap -o /tmp/cm.bin
  100
  # crushtool -d /tmp/cm.bin -o /tmp/cm.rack.ascii
  # cat /tmp/cm.rack.ascii
  . . .
  # buckets
  host host1 {
        id -2           # do not change unnecessarily
        id -3 class hdd         # do not change unnecessarily
        # weight 13.080
        alg straw2
        hash 0  # rjenkins1
        item osd.0 weight 1.090
        item osd.1 weight 1.090
        item osd.2 weight 1.090
        item osd.3 weight 1.090
        item osd.4 weight 1.090
        item osd.5 weight 1.090
        item osd.6 weight 1.090
        item osd.7 weight 1.090
        item osd.8 weight 1.090
        item osd.9 weight 1.090
        item osd.10 weight 1.090
        item osd.11 weight 1.090
  }
  host host2 {
        id -5           # do not change unnecessarily
        id -6 class hdd         # do not change unnecessarily
        # weight 13.080
        alg straw2
        hash 0  # rjenkins1
        item osd.12 weight 1.090
        item osd.13 weight 1.090
        item osd.14 weight 1.090
        item osd.15 weight 1.090
        item osd.16 weight 1.090
        item osd.18 weight 1.090
        item osd.19 weight 1.090
        item osd.17 weight 1.090
        item osd.20 weight 1.090
        item osd.21 weight 1.090
        item osd.22 weight 1.090
        item osd.23 weight 1.090
  }
  rack rack1 {
        id -15          # do not change unnecessarily
        id -20 class hdd        # do not change unnecessarily
        # weight 26.160
        alg straw2
        hash 0  # rjenkins1
        item host1 weight 13.080
        item host2 weight 13.080
  }
  . . .
  root default {
        id -1          # do not change unnecessarily
        id -4 class hdd        # do not change unnecessarily
        # weight 78.480
        alg straw2
        hash 0  # rjenkins1
        item rack1 weight 26.160
        item rack2 weight 26.160
        item rack3 weight 26.160
  }

  # rules
  rule replicated_rack {
        id 2
        type replicated
        min_size 1
        max_size 10
        step take default
        step chooseleaf firstn 0 type rack
        step emit
  }
  # end crush map

The **utils-checkPGs.py** script can read the same data from memory and construct
the failure domains with OSDs.  Verify the OSDs in each PG against the
constructed failure domains.

Configure the Failure Domain in CRUSH Map
=========================================

The Ceph ceph-osd, ceph-client and cinder charts accept configuration parameters to set the Failure Domain for CRUSH.
The options available are **failure_domain**, **failure_domain_by_hostname**, **failure_domain_name** and **crush_rule**

::

 ceph-osd specific overrides
 failure_domain: Set the CRUSH bucket type for your OSD to reside in. (DEFAULT: "host")
 failure_domain_by_hostname: Specify the portion of the hostname to use for your failure domain bucket name. (DEFAULT: "false")
 failure_domain_name: Manually name the failure domain bucket name. This configuration option should only be used when using host based overrides. (DEFAULT: "false")

::

 ceph-client and cinder specific overrides
 crush_rule**: Set the crush rule for a pool (DEFAULT: "replicated_rule")

An example of a lab enviroment had the following paramters set for the ceph yaml override file to apply a rack level failure domain within CRUSH.

::

  endpoints:
    identity:
      namespace: openstack
    object_store:
      namespace: ceph
    ceph_mon:
      namespace: ceph
  network:
    public: 10.0.0.0/24
    cluster: 10.0.0.0/24
  deployment:
    storage_secrets: true
    ceph: true
    csi_rbd_provisioner: true
    rbd_provisioner: false
    cephfs_provisioner: false
    client_secrets: false
    rgw_keystone_user_and_endpoints: false
  bootstrap:
    enabled: true
  conf:
    ceph:
      global:
        fsid: 6c12a986-148d-45a7-9120-0cf0522ca5e0
    rgw_ks:
      enabled: true
    pool:
      default:
        crush_rule: rack_replicated_rule
      crush:
        tunables: null
      target:
        # NOTE(portdirect): 5 nodes, with one osd per node
        osd: 18
        pg_per_osd: 100
    storage:
      osd:
        - data:
            type: block-logical
            location: /dev/vdb
          journal:
            type: block-logical
            location: /dev/vde1
        - data:
            type: block-logical
            location: /dev/vdc
          journal:
            type: block-logical
            location: /dev/vde2
        - data:
            type: block-logical
            location: /dev/vdd
          journal:
            type: block-logical
            location: /dev/vde3
    overrides:
      ceph_osd:
        hosts:
          - name: osh-1
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack1"
          - name: osh-2
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack1"
          - name: osh-3
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack2"
          - name: osh-4
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack2"
          - name: osh-5
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack3"
          - name: osh-6
            conf:
              storage:
                failure_domain: "rack"
                failure_domain_name: "rack3"

.. NOTE::

   Note that the cinder chart will need an override configured to ensure the cinder pools in Ceph are using the correct **crush_rule**.

::

  pod:
    replicas:
      api: 2
      volume: 1
      scheduler: 1
      backup: 1
  conf:
    cinder:
      DEFAULT:
        backup_driver: cinder.backup.drivers.swift
    ceph:
      pools:
        backup:
          replicated: 3
          crush_rule: rack_replicated_rule
          chunk_size: 8
        volume:
          replicated: 3
          crush_rule: rack_replicated_rule
          chunk_size: 8

The charts can be updated with these overrides pre or post deployment. If this is a post deployment change then the following steps will apply for a gate based openstack-helm deployment.

::

  cd /opt/openstack-helm
  helm upgrade --install ceph-osd ../openstack-helm-infra/ceph-osd --namespace=ceph --values=/tmp/ceph.yaml
  kubectl delete jobs/ceph-rbd-pool -n ceph
  helm upgrade --install ceph-client ../openstack-helm-infra/ceph-client --namespace=ceph --values=/tmp/ceph.yaml
  helm delete cinder --purge
  helm upgrade --install cinder ./cinder --namespace=openstack --values=/tmp/cinder.yaml

.. NOTE::

  There will be a brief interuption of I/O and a data movement of placement groups in Ceph while these changes are
  applied. The data movement operation can take several minutes to several days to complete.

The utils-checkPGs.py Script
============================

The purpose of the **utils-checkPGs.py** script is to check whether a PG has OSDs
allocated from the same failure domain.  The violating PGs with their
respective OSDs are printed to the stdout.

In this example, a pool was created with the CRUSH rule set to the host
failure domain.  The ceph cluster was configured with the rack
buckets.  The CRUSH algorithm allocated the OSDs from different hosts
in each PG.  The rack buckets were ignored and thus the duplicate
racks which get reported by the script.

::

  root@host5:/# /tmp/utils-checkPGs.py cmTestPool
  Checking PGs in pool cmTestPool ... Failed
  OSDs [44, 32, 53] in PG 20.a failed check in rack [u'rack2', u'rack2', u'rack2']
  OSDs [61, 5, 12] in PG 20.19 failed check in rack [u'rack1', u'rack1', u'rack1']
  OSDs [69, 9, 15] in PG 20.2a failed check in rack [u'rack1', u'rack1', u'rack1']
  . . .


.. NOTE::

  The **utils-checkPGs.py** utility is executed on-demand.  It is intended to be executed on one of the ceph-mon pods.

If the **utils-checkPGs.py** script did not find any violation, it prints
Passed.  In this example, the ceph cluster was configured with the rack
buckets.  The rbd pool was created with its CRUSH rule set to the
rack.  The **utils-checkPGs.py** script did not find duplicate racks in PGs.

::

  root@host5:/# /tmp/utils-checkPGs.py rbd
  Checking PGs in pool rbd ... Passed

Invoke the **utils-checkPGs.py** script with the --help option to get the
script's usage.

::

  root@host5:/# /tmp/utils-checkPGs.py --help
  usage: utils-checkPGs.py [-h] PoolName [PoolName ...]

  Cross-check the OSDs assigned to the Placement Groups (PGs) of a ceph pool
  with the CRUSH topology.  The cross-check compares the OSDs in a PG and
  verifies the OSDs reside in separate failure domains.  PGs with OSDs in
  the same failure domain are flagged as violation.  The offending PGs are
  printed to stdout.

  This CLI is executed on-demand on a ceph-mon pod.  To invoke the CLI, you
  can specify one pool or list of pools to check.  The special pool name
  All (or all) checks all the pools in the ceph cluster.

  positional arguments:
    PoolName    List of pools (or All) to validate the PGs and OSDs mapping

  optional arguments:
    -h, --help  show this help message and exit
  root@host5:/#


The source for the **utils-checkPGs.py** script is available
at **openstack-helm/ceph-mon/templates/bin/utils/_checkPGs.py.tpl**.

Ceph Deployments
================

Through testing and verification, you derive at a CRUSH Map with the buckets
that are deemed beneficial to your ceph cluster.  Standardize on the verified
CRUSH map to have the consistency in all the Ceph deployments across the
data centers.

Mimicking the hierarchy in your CRUSH Map with the physical hardware setup
should provide the needed information on the topology layout.  With the
racks layout, each rack can store a replica of your data.

To validate a ceph cluster with the number of replica that is based on
the number of racks:

#. The number of physical racks and the number of replicas are 3, respectively.  Create a ceph pool with replica set to 3 and pg_num set to (# of OSDs * 50) / 3 and round the number to the next power-of-2.  For example, if the calculation is 240, round it to 256.  Assuming the pool you just created had 256 PGs.  In each PG, verify the OSDs are chosen from the three racks, respectively.  Use the **utils-checkPGs.py** script to verify the OSDs in all the PGs of the pool.

#. The number of physical racks is 2 and the number of replica is 3.  Create a ceph pool as described in the previous step.  In the pool you created, in each PG, verify two of the OSDs are chosen from the two racks, respectively.  The third OSD can come from one of the two racks but not from the same hosts as the other two OSDs.

Data Movement
=============

Changes to the CRUSH Map always trigger data movement.  It is prudent that
you plan accordingly when restructuring the CRUSH Map.  Once started, the
CRUSH Map restructuring runs to completion and can neither be stopped nor
suspended.  On a busy Ceph cluster with live transactions, it is always
safer to use divide-and-conquer approach to complete small chunk of works
in multiple sessions.

Watch the progress of the data movement while the Ceph cluster re-balances
itself.

::

  # watch ceph status
    cluster:
      id:     07c31d0f-bcc6-4db4-aadf-2d2a0f13edb8
      health: HEALTH_WARN
              137084/325509 objects misplaced (42.114%)
              Degraded data redundancy: 28/325509 objects degraded (0.009%), 15 pgs degraded

    services:
      mon: 5 daemons, quorum host1,host2,host3,host4,host5
      mgr: host6(active), standbys: host1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-7cb4f57cc-prh87=up:active}, 1 up:standby
      osd: 72 osds: 72 up, 72 in; 815 remapped pgs
      rgw: 2 daemons active

    data:
      pools:   19 pools, 2920 pgs
      objects: 105k objects, 408 GB
      usage:   1609 GB used, 78819 GB / 80428 GB avail
      pgs:     28/325509 objects degraded (0.009%)
               137084/325509 objects misplaced (42.114%)
               2085 active+clean
               790  active+remapped+backfill_wait
               22   active+remapped+backfilling
               15   active+recovery_wait+degraded
               4    active+recovery_wait+remapped
               4    active+recovery_wait

    io:
      client:   11934 B/s rd, 3731 MB/s wr, 2 op/s rd, 228 kop/s wr
      recovery: 636 MB/s, 163 objects/s

At the time this **ceph status** command was executed, the status's output
showed that the ceph cluster was going through re-balancing.  Among the
overall 2920 pgs, 2085 of them are in **active+clean** state.  The
remaining pgs are either being remapped or recovered.  As the ceph
cluster continues its re-balance, the number of pgs
in **active+clean** increases.

::

  # ceph status
    cluster:
      id:     07c31d0f-bcc6-4db4-aadf-2d2a0f13edb8
      health: HEALTH_OK

    services:
      mon: 5 daemons, quorum host1,host2,host3,host4,host5
      mgr: host6(active), standbys: host1
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-7cc55c9695-lj22d=up:active}, 1 up:standby
      osd: 72 osds: 72 up, 72 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 2920 pgs
      objects: 134k objects, 519 GB
      usage:   1933 GB used, 78494 GB / 80428 GB avail
      pgs:     2920 active+clean

    io:
      client:   1179 B/s rd, 971 kB/s wr, 1 op/s rd, 41 op/s wr

When the overall number of pgs is equal to the number
of **active+clean** pgs, the health of the ceph cluster changes
to **HEALTH_OK** (assuming there are no other warning conditions).
