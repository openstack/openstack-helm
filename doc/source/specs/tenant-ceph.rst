================================
Deploying multuple Ceph clusters
================================

This guide shows how to setup multiple Ceph clusters. One Ceph cluster will be
used for k8s RBD storage and while other Ceph cluster will be for tenant facing
storage backend for Cinder and Glance.

Ceph Clusters:
==============

Ceph for RBD:
-------------

This Ceph cluster will be used for k8s RBD storage (pvc). This can be used by
entire Kubernetes cluster.

- k8s namespace: ceph
- mon endpoint port: 6789
- mgr endpoint port: 7000
- metric port: 9283
- storage classes: general (rbd based for pvc)
- no ceph-mds and ceph-rgw

Ceph for Tenant:
----------------

This Ceph cluster will be used by Cinder and Glance as storage backend.

- k8s namespace: tenant-ceph
- mon endpoint port: 6790
- mgr endpoint port: 7001
- metric port: 9284
- no storage classes
- no ceph-mds

Env Setup:
==========
6 VM based hosts (node1, node2, node3, node4, node5, node6)

k8s node labels:
----------------
``Ceph for RBD related labels:``

Labels assigned to nodes: node1, node2, node3:

openstack-control-plane=enabled,
ceph-mon=enabled,
ceph-mgr=enabled,
ceph-rgw=enabled,
ceph-mds=enabled,
ceph-osd=enabled

``Ceph for Tenant related labels:``

Labels assigned to nodes: node1, node2, node3:

tenant-ceph-control-plane=enabled,
ceph-mon-tenant=enabled,
ceph-mgr-tenant=enabled,
ceph-rgw-tenant=enabled

Labels assigned to nodes: node4, node5, node6:

openstack-data-plane=enabled,
openstack-compute-node=enabled,
ceph-osd-tenant=enabled,
openstack-data-plane=enabled



``k8s node list with labels``
After applying above labels, node labels should look like following.

.. code-block:: console

  ubuntu@node1:~$ kubectl get nodes --show-labels=true
  NAME      STATUS    ROLES     AGE       VERSION   LABELS
  node1     Ready     <none>    9m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-mds=enabled,ceph-mgr-tenant=enabled,ceph-mgr=enabled,ceph-mon-tenant=enabled,ceph-mon=enabled,ceph-osd=enabled,ceph-rgw-tenant=enabled,ceph-rgw=enabled,kubernetes.io/hostname=node1,linuxbridge=enabled,openstack-control-plane=enabled,openstack-helm-node-class=primary,openvswitch=enabled,tenant-ceph-control-plane=enabled
  node2     Ready     <none>    6m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-mds=enabled,ceph-mgr-tenant=enabled,ceph-mgr=enabled,ceph-mon-tenant=enabled,ceph-mon=enabled,ceph-osd=enabled,ceph-rgw-tenant=enabled,ceph-rgw=enabled,kubernetes.io/hostname=node2,linuxbridge=enabled,openstack-control-plane=enabled,openstack-helm-node-class=general,openvswitch=enabled,tenant-ceph-control-plane=enabled
  node3     Ready     <none>    6m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-mds=enabled,ceph-mgr-tenant=enabled,ceph-mgr=enabled,ceph-mon-tenant=enabled,ceph-mon=enabled,ceph-osd=enabled,ceph-rgw-tenant=enabled,ceph-rgw=enabled,kubernetes.io/hostname=node3,linuxbridge=enabled,openstack-control-plane=enabled,openstack-helm-node-class=general,openvswitch=enabled,tenant-ceph-control-plane=enabled
  node4     Ready     <none>    7m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-osd-tenant=enabled,kubernetes.io/hostname=node4,linuxbridge=enabled,openstack-compute-node=enabled,openstack-data-plane=enabled,openstack-helm-node-class=general,openvswitch=enabled
  node5     Ready     <none>    6m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-osd-tenant=enabled,kubernetes.io/hostname=node5,linuxbridge=enabled,openstack-compute-node=enabled,openstack-data-plane=enabled,openstack-helm-node-class=general,openvswitch=enabled
  node6     Ready     <none>    6m        v1.10.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ceph-osd-tenant=enabled,kubernetes.io/hostname=node6,linuxbridge=enabled,openstack-compute-node=enabled,openstack-data-plane=enabled,openstack-helm-node-class=general,openvswitch=enabled


Test Steps:
===========

1) Prepare scripts:
-------------------

OpenStack-Helm multinode guide includes scripts which are used to specify
overrides and deploy charts.

Duplicate scripts as shows below for later use.

.. code-block:: console

  cd tools/deployment/multinode/
  cp 030-ceph.sh 030-tenant-ceph.sh
  cp 040-ceph-ns-activate.sh 040-tenant-ceph-ns-activate.sh
  cp 090-ceph-radosgateway.sh 090-tenant-ceph-radosgateway.sh


2) Deploy ingress chart:
------------------------

Script to update and execute: ``020-ingress.sh``

Update script to include namespace ``tenant-ceph`` as shown
below.

.. code-block:: yaml

  for NAMESPACE in openstack ceph tenant-ceph; do

Execute script.

3) Deploy Ceph for RBD:
-----------------------

Script to update and execute: ``030-ceph.sh``

Update script with following overrides. Note: The original RBD provisioner
is now deprecated. The CSI RBD provisioner is selected here. If you prefer
the original non-CSI RBD provisioner, then set rbd_provisioner to true instead.

.. code-block:: yaml

  deployment:
    storage_secrets: true
    ceph: true
    rbd_provisioner: false
    csi_rbd_provisioner: true
    cephfs_provisioner: false
    client_secrets: false
  endpoints:
    ceph_mon:
      namespace: ceph
      port:
        mon:
          default: 6789
    ceph_mgr:
      namespace: ceph
      port:
        mgr:
          default: 7000
        metrics:
          default: 9283
  manifests:
    deployment_mds: false
  bootstrap:
    enabled: true
  conf:
    pool:
      target:
        osd: 3
  storageclass:
    rbd:
      ceph_configmap_name: ceph-etc
    cephfs:
      provision_storage_class: false
  ceph_mgr_modules_config:
    prometheus:
      server_port: 9283
  monitoring:
    prometheus:
      enabled: true
      ceph_mgr:
        port: 9283

.. note::
  ``cephfs_provisioner: false`` and ``provision_storage_class: false`` are set
  to false to disable cephfs.
  ``deployment_mds: false`` is set to disable ceph-mds

Execute script.

4) Deploy MariaDB, RabbitMQ, Memcached and Keystone:
----------------------------------------------------

Use default overrides and execute following scripts as per OSH guide steps:

- ``040-ceph-ns-activate.sh``
- ``050-mariadb.sh``
- ``060-rabbitmq.sh``
- ``070-memcached.sh``
- ``080-keystone.sh``


Result from Steps 2, 3, 4:
--------------------------

``Ceph Pods``

.. code-block:: console

  ubuntu@node1:~$  kubectl get pods -n ceph -o wide
  NAME                                    READY     STATUS      RESTARTS   AGE       IP              NODE
  ceph-bootstrap-g45qc                    0/1       Completed   0          28m       192.168.5.16    node3
  ceph-mds-keyring-generator-gsw4m        0/1       Completed   0          28m       192.168.2.11    node2
  ceph-mgr-5746dd89db-mmrg4               1/1       Running     0          23m       10.0.0.12       node2
  ceph-mgr-5746dd89db-q25lt               1/1       Running     0          23m       10.0.0.9        node3
  ceph-mgr-keyring-generator-t4s8l        0/1       Completed   0          28m       192.168.2.9     node2
  ceph-mon-6n4hk                          1/1       Running     0          28m       10.0.0.9        node3
  ceph-mon-b2d9w                          1/1       Running     0          28m       10.0.0.12       node2
  ceph-mon-check-d85994946-2dcpg          1/1       Running     0          28m       192.168.5.17    node3
  ceph-mon-keyring-generator-rmvfz        0/1       Completed   0          28m       192.168.2.10    node2
  ceph-mon-svkdl                          1/1       Running     0          28m       10.0.0.16       node1
  ceph-osd-default-83945928-2mhrj         1/1       Running     0          25m       10.0.0.9        node3
  ceph-osd-default-83945928-gqbd9         1/1       Running     0          25m       10.0.0.16       node1
  ceph-osd-default-83945928-krrl8         1/1       Running     0          25m       10.0.0.12       node2
  ceph-osd-keyring-generator-zg8s5        0/1       Completed   0          28m       192.168.0.195   node1
  ceph-rbd-pool-92nbv                     0/1       Completed   0          23m       192.168.5.18    node3
  ceph-rbd-provisioner-599895579c-jl6qk   1/1       Running     0          21m       192.168.2.15    node2
  ceph-rbd-provisioner-599895579c-n4hbk   1/1       Running     0          21m       192.168.5.19    node3
  ceph-rgw-keyring-generator-2wv4j        0/1       Completed   0          28m       192.168.5.15    node3
  ceph-storage-keys-generator-8vzrx       0/1       Completed   0          28m       192.168.2.12    node2
  ingress-796d8cf8d6-9khkm                1/1       Running     0          28m       192.168.2.6     node2
  ingress-796d8cf8d6-nznvc                1/1       Running     0          28m       192.168.5.12    node3
  ingress-error-pages-54454dc79b-bgc5m    1/1       Running     0          28m       192.168.2.5     node2
  ingress-error-pages-54454dc79b-hwnv4    1/1       Running     0          28m       192.168.5.7     node3

``Openstack Pods:``

.. code-block:: console

  ubuntu@node1:~$ kubectl get pods -n openstack -o wide
  NAME                                                READY     STATUS      RESTARTS   AGE       IP              NODE
  ceph-openstack-config-ceph-ns-key-generator-mcxrs   0/1       Completed   0          11m       192.168.2.16    node2
  ingress-7b4bc84cdd-7wslz                            1/1       Running     0          30m       192.168.5.5     node3
  ingress-7b4bc84cdd-z6t2z                            1/1       Running     0          30m       192.168.2.4     node2
  ingress-error-pages-586c7f86d6-7m58l                1/1       Running     0          30m       192.168.5.6     node3
  ingress-error-pages-586c7f86d6-n9tzv                1/1       Running     0          30m       192.168.2.3     node2
  keystone-api-7974676d5d-5k27d                       1/1       Running     0          6m        192.168.5.24    node3
  keystone-api-7974676d5d-cd9kv                       1/1       Running     0          6m        192.168.2.21    node2
  keystone-bootstrap-twfrj                            0/1       Completed   0          6m        192.168.0.197   node1
  keystone-credential-setup-txf5p                     0/1       Completed   0          6m        192.168.5.25    node3
  keystone-db-init-tjxgm                              0/1       Completed   0          6m        192.168.2.20    node2
  keystone-db-sync-zl9t4                              0/1       Completed   0          6m        192.168.2.22    node2
  keystone-domain-manage-thwdm                        0/1       Completed   0          6m        192.168.0.198   node1
  keystone-fernet-setup-qm424                         0/1       Completed   0          6m        192.168.5.26    node3
  keystone-rabbit-init-6699r                          0/1       Completed   0          6m        192.168.2.23    node2
  keystone-test                                       0/1       Completed   0          4m        192.168.3.3     node4
  mariadb-ingress-84894687fd-wfc9b                    1/1       Running     0          11m       192.168.2.17    node2
  mariadb-ingress-error-pages-78fb865f84-bg8sg        1/1       Running     0          11m       192.168.5.20    node3
  mariadb-server-0                                    1/1       Running     0          11m       192.168.5.22    node3
  memcached-memcached-5db74ddfd5-m5gw2                1/1       Running     0          7m        192.168.2.19    node2
  rabbitmq-rabbitmq-0                                 1/1       Running     0          8m        192.168.2.18    node2
  rabbitmq-rabbitmq-1                                 1/1       Running     0          8m        192.168.5.23    node3
  rabbitmq-rabbitmq-2                                 1/1       Running     0          8m        192.168.0.196   node1

``Ceph Status``

.. code-block:: console

  ubuntu@node1:~$ kubectl exec -n ceph ceph-mon-b2d9w -- ceph -s
    cluster:
      id:     3e53e3b7-e5d9-4bab-9701-134687f4954e
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum node3,node2,node1
      mgr: node3(active), standbys: node2
      osd: 3 osds: 3 up, 3 in

    data:
      pools:   18 pools, 93 pgs
      objects: 127 objects, 218 MB
      usage:   46820 MB used, 186 GB / 232 GB avail
      pgs:     93 active+clean


``Ceph ConfigMaps``

.. code-block:: console

  ubuntu@node1:~$ kubectl get cm -n ceph
  NAME                                      DATA      AGE
  ceph-client-bin                           7         25m
  ceph-client-etc                           1         25m
  ceph-etc                                  1         23m
  ceph-mon-bin                              10        29m
  ceph-mon-etc                              1         29m
  ceph-osd-bin                              7         27m
  ceph-osd-default                          1         27m
  ceph-osd-etc                              1         27m
  ceph-provisioners-ceph-provisioners-bin   4         23m
  ceph-templates                            6         29m
  ingress-bin                               2         30m
  ingress-ceph-nginx                        0         30m
  ingress-conf                              3         30m
  ingress-services-tcp                      0         30m
  ingress-services-udp                      0         30m


``ceph-mon-etc (ceph.conf)``

.. code-block:: console

  ubuntu@node1:~$ kubectl get cm -n ceph ceph-mon-etc -o yaml

.. code-block:: yaml

  apiVersion: v1
  data:
    ceph.conf: |
      [global]
      cephx = true
      cephx_cluster_require_signatures = true
      cephx_require_signatures = false
      cephx_service_require_signatures = false
      fsid = 3e53e3b7-e5d9-4bab-9701-134687f4954e
      mon_addr = :6789
      mon_host = ceph-mon-discovery.ceph.svc.cluster.local:6789
      [osd]
      cluster_network = 10.0.0.0/24
      ms_bind_port_max = 7100
      ms_bind_port_min = 6800
      osd_max_object_name_len = 256
      osd_mkfs_options_xfs = -f -i size=2048
      osd_mkfs_type = xfs
      public_network = 10.0.0.0/24
  kind: ConfigMap
  metadata:
    creationTimestamp: 2018-08-27T04:55:32Z
    name: ceph-mon-etc
    namespace: ceph
    resourceVersion: "3218"
    selfLink: /api/v1/namespaces/ceph/configmaps/ceph-mon-etc
    uid: 6d9fdcba-a9b5-11e8-bb1d-fa163ec12213

.. note::
  Note that mon_addr and mon_host have default mon port 6789.

``k8s storageclass``

.. code-block:: console

  ubuntu@node1:~$ kubectl get storageclasses
  NAME      PROVISIONER    AGE
  general   ceph.com/rbd   14m

``Ceph services``

.. code-block:: console

  ubuntu@node1:~$ kubectl get svc -n ceph
  NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
  ceph-mgr              ClusterIP   10.111.185.73    <none>        7000/TCP,9283/TCP   27m
  ceph-mon              ClusterIP   None             <none>        6789/TCP            31m
  ceph-mon-discovery    ClusterIP   None             <none>        6789/TCP            31m
  ingress               ClusterIP   10.100.23.32     <none>        80/TCP,443/TCP      32m
  ingress-error-pages   ClusterIP   None             <none>        80/TCP              32m
  ingress-exporter      ClusterIP   10.109.196.155   <none>        10254/TCP           32m

``Ceph endpoints``

.. code-block:: console

  ubuntu@node1:~$ kubectl get endpoints -n ceph
  NAME                  ENDPOINTS                                                    AGE
  ceph-mgr              10.0.0.12:9283,10.0.0.9:9283,10.0.0.12:7000 + 1 more...      27m
  ceph-mon              10.0.0.12:6789,10.0.0.16:6789,10.0.0.9:6789                  31m
  ceph-mon-discovery    10.0.0.12:6789,10.0.0.16:6789,10.0.0.9:6789                  31m
  ingress               192.168.2.6:80,192.168.5.12:80,192.168.2.6:443 + 1 more...   32m
  ingress-error-pages   192.168.2.5:8080,192.168.5.7:8080                            32m
  ingress-exporter      192.168.2.6:10254,192.168.5.12:10254                         32m

``netstat ceph mon port``

.. code-block:: console

  ubuntu@node1: netstat -ntlp | grep 6789
  (Not all processes could be identified, non-owned process info
   will not be shown, you would have to be root to see it all.)
  tcp        0      0 10.0.0.16:6789          0.0.0.0:*               LISTEN      -

  ubuntu@node1: netstat -ntlp | grep 6790
  (Not all processes could be identified, non-owned process info
   will not be shown, you would have to be root to see it all.)

``Ceph secrets``

.. code-block:: console

  ubuntu@node1:~$ kubectl get secrets -n ceph
  NAME                                                 TYPE                                  DATA      AGE
  ceph-bootstrap-mds-keyring                           Opaque                                1         34m
  ceph-bootstrap-mgr-keyring                           Opaque                                1         34m
  ceph-bootstrap-osd-keyring                           Opaque                                1         34m
  ceph-bootstrap-rgw-keyring                           Opaque                                1         34m
  ceph-bootstrap-token-w2sqp                           kubernetes.io/service-account-token   3         34m
  ceph-client-admin-keyring                            Opaque                                1         34m
  ceph-mds-keyring-generator-token-s9kst               kubernetes.io/service-account-token   3         34m
  ceph-mgr-keyring-generator-token-h5sw6               kubernetes.io/service-account-token   3         34m
  ceph-mgr-token-hr88m                                 kubernetes.io/service-account-token   3         30m
  ceph-mon-check-token-bfvgk                           kubernetes.io/service-account-token   3         34m
  ceph-mon-keyring                                     Opaque                                1         34m
  ceph-mon-keyring-generator-token-5gs5q               kubernetes.io/service-account-token   3         34m
  ceph-mon-token-zsd6w                                 kubernetes.io/service-account-token   3         34m
  ceph-osd-keyring-generator-token-h97wb               kubernetes.io/service-account-token   3         34m
  ceph-osd-token-4wfm5                                 kubernetes.io/service-account-token   3         32m
  ceph-provisioners-ceph-rbd-provisioner-token-f92tw   kubernetes.io/service-account-token   3         28m
  ceph-rbd-pool-token-p2nxt                            kubernetes.io/service-account-token   3         30m
  ceph-rgw-keyring-generator-token-wmfx6               kubernetes.io/service-account-token   3         34m
  ceph-storage-keys-generator-token-dq5ts              kubernetes.io/service-account-token   3         34m
  default-token-j8h48                                  kubernetes.io/service-account-token   3         35m
  ingress-ceph-ingress-token-68rws                     kubernetes.io/service-account-token   3         35m
  ingress-error-pages-token-mpvhm                      kubernetes.io/service-account-token   3         35m
  pvc-ceph-conf-combined-storageclass                  kubernetes.io/rbd                     1         34m

``Openstack secrets``

.. code-block:: console

  ubuntu@node1:~$ kubectl get secrets -n openstack
  NAME                                                      TYPE                                  DATA      AGE
  ceph-openstack-config-ceph-ns-key-cleaner-token-jj7n6     kubernetes.io/service-account-token   3         17m
  ceph-openstack-config-ceph-ns-key-generator-token-5sqfw   kubernetes.io/service-account-token   3         17m
  default-token-r5knr                                       kubernetes.io/service-account-token   3         35m
  ingress-error-pages-token-xxjxt                           kubernetes.io/service-account-token   3         35m
  ingress-openstack-ingress-token-hrvv8                     kubernetes.io/service-account-token   3         35m
  keystone-api-token-xwczg                                  kubernetes.io/service-account-token   3         12m
  keystone-bootstrap-token-dhnb6                            kubernetes.io/service-account-token   3         12m
  keystone-credential-keys                                  Opaque                                2         12m
  keystone-credential-rotate-token-68lnk                    kubernetes.io/service-account-token   3         12m
  keystone-credential-setup-token-b2smc                     kubernetes.io/service-account-token   3         12m
  keystone-db-admin                                         Opaque                                1         12m
  keystone-db-init-token-brzkj                              kubernetes.io/service-account-token   3         12m
  keystone-db-sync-token-xzqj9                              kubernetes.io/service-account-token   3         12m
  keystone-db-user                                          Opaque                                1         12m
  keystone-domain-manage-token-48gn5                        kubernetes.io/service-account-token   3         12m
  keystone-etc                                              Opaque                                9         12m
  keystone-fernet-keys                                      Opaque                                2         12m
  keystone-fernet-rotate-token-djtzb                        kubernetes.io/service-account-token   3         12m
  keystone-fernet-setup-token-n9st2                         kubernetes.io/service-account-token   3         12m
  keystone-keystone-admin                                   Opaque                                8         12m
  keystone-keystone-test                                    Opaque                                8         12m
  keystone-rabbit-init-token-pt5b2                          kubernetes.io/service-account-token   3         12m
  keystone-rabbitmq-admin                                   Opaque                                1         12m
  keystone-rabbitmq-user                                    Opaque                                1         12m
  keystone-test-token-z8mb6                                 kubernetes.io/service-account-token   3         12m
  mariadb-db-root-password                                  Opaque                                1         17m
  mariadb-ingress-error-pages-token-cnrqp                   kubernetes.io/service-account-token   3         17m
  mariadb-ingress-token-gfrg4                               kubernetes.io/service-account-token   3         17m
  mariadb-secrets                                           Opaque                                1         17m
  mariadb-token-pr5lp                                       kubernetes.io/service-account-token   3         17m
  memcached-memcached-token-gq96p                           kubernetes.io/service-account-token   3         13m
  pvc-ceph-client-key                                       kubernetes.io/rbd                     1         17m
  rabbitmq-rabbitmq-token-5bj85                             kubernetes.io/service-account-token   3         14m
  rabbitmq-test-token-w4clj                                 kubernetes.io/service-account-token   3         14m

``Openstack PV list``

.. code-block:: console

  ubuntu@node1:~$ kubectl get pv -n openstack
  NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                                         STORAGECLASS   REASON    AGE
  pvc-348f4c52-a9b8-11e8-bb1d-fa163ec12213   256Mi      RWO            Delete           Bound     openstack/rabbitmq-data-rabbitmq-rabbitmq-0   general                  15m
  pvc-4418c745-a9b8-11e8-bb1d-fa163ec12213   256Mi      RWO            Delete           Bound     openstack/rabbitmq-data-rabbitmq-rabbitmq-1   general                  14m
  pvc-524d4213-a9b8-11e8-bb1d-fa163ec12213   256Mi      RWO            Delete           Bound     openstack/rabbitmq-data-rabbitmq-rabbitmq-2   general                  14m
  pvc-da9c9dd2-a9b7-11e8-bb1d-fa163ec12213   5Gi        RWO            Delete           Bound     openstack/mysql-data-mariadb-server-0         general                  17m

``Openstack endpoints``

.. code-block:: console

  ubuntu@node1:~$ openstack endpoint list
  +----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------------------+
  | ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                                     |
  +----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------------------+
  | 480cc7360752498e822cbbc7211d213a | RegionOne | keystone     | identity     | True    | internal  | http://keystone-api.openstack.svc.cluster.local:5000/v3 |
  | 8dfe4e4725b84e51a5eda564dee0960c | RegionOne | keystone     | identity     | True    | public    | http://keystone.openstack.svc.cluster.local:80/v3       |
  | 9b3526e36307400b9accfc7cc834cf99 | RegionOne | keystone     | identity     | True    | admin     | http://keystone.openstack.svc.cluster.local:80/v3       |
  +----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------------------+

``Openstack services``

.. code-block:: console

  ubuntu@node1:~$ openstack service list
  +----------------------------------+----------+----------+
  | ID                               | Name     | Type     |
  +----------------------------------+----------+----------+
  | 67cc6b945e934246b25d31a9374a64af | keystone | identity |
  +----------------------------------+----------+----------+



5) Deploy Ceph for Tenant:
--------------------------

Script to update and execute: ``030-tenant-ceph.sh``

Make following changes to script:
1 Replace occurrence of ``ceph-fs-uuid.txt`` with ``tenant-ceph-fs-uuid.txt``

2 Replace occurrence of ``ceph.yaml`` with ``tenant-ceph.yaml``

3 For tenant Ceph, no need to deploy ceph-provisioners. Update script
to ``for CHART in ceph-mon ceph-osd ceph-client; do``


Update script's override section with following:


.. code-block:: yaml

  endpoints:
    identity:
      namespace: openstack
    object_store:
      namespace: openstack
    ceph_mon:
      namespace: tenant-ceph
      port:
        mon:
          default: 6790
    ceph_mgr:
      namespace: tenant-ceph
      port:
        mgr:
          default: 7001
        metrics:
          default: 9284
  network:
    public: ${CEPH_PUBLIC_NETWORK}
    cluster: ${CEPH_CLUSTER_NETWORK}
  deployment:
    storage_secrets: true
    ceph: true
    rbd_provisioner: false
    csi_rbd_provisioner: false
    cephfs_provisioner: false
    client_secrets: false
  labels:
    mon:
      node_selector_key: ceph-mon-tenant
    osd:
      node_selector_key: ceph-osd-tenant
    rgw:
      node_selector_key: ceph-rgw-tenant
    mgr:
      node_selector_key: ceph-mgr-tenant
    job:
      node_selector_key: tenant-ceph-control-plane
  storageclass:
    rbd:
      ceph_configmap_name: tenant-ceph-etc
      provision_storage_class: false
      name: tenant-rbd
      admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
      admin_secret_namespace: tenant-ceph
      user_secret_name: pvc-tenant-ceph-client-key
    cephfs:
      provision_storage_class: false
      name: cephfs
      user_secret_name: pvc-tenant-ceph-cephfs-client-key
      admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
      admin_secret_namespace: tenant-ceph
  bootstrap:
    enabled: true
  manifests:
    deployment_mds: false
  ceph_mgr_modules_config:
    prometheus:
      server_port: 9284
  monitoring:
    prometheus:
      enabled: true
      ceph_mgr:
        port: 9284
  conf:
    ceph:
      global:
        fsid: ${CEPH_FS_ID}
    rgw_ks:
      enabled: true
    pool:
      crush:
        tunables: ${CRUSH_TUNABLES}
      target:
        osd: 3
        pg_per_osd: 100
    storage:
      osd:
        - data:
            type: directory
            location: /var/lib/openstack-helm/tenant-ceph/osd/osd-one
          journal:
            type: directory
            location: /var/lib/openstack-helm/tenant-ceph/osd/journal-one
      mon:
        directory: /var/lib/openstack-helm/tenant-ceph/mon


.. note::
  - Port numbers for Ceph_Mon and Ceph_Mgr are different from default.
  - We are disabling rbd and cephfs provisioners.
  - Labels for mon, osd, rgw, mgr and job have been updated for tenant Ceph.
  - Under storageclass section, values for following have been updated:
    ceph_configmap_name, admin_secret_name, admin_secret_namespace, user_secret_name
  - Under storage: mon directory have been updated.

For Tenant Ceph, we will not be provisioning storage classes therefor, update
script to not install ceph-provisioners chart as following.

``for CHART in ceph-mon ceph-osd ceph-client; do``

Execute script.

6) Enable Openstack namespace to use Tenant Ceph:
-------------------------------------------------

Script to update and execute: ``040-tenant-ceph-ns-activate.sh``

Update script as following:

.. code-block:: console

  ...
  tee /tmp/tenant-ceph-openstack-config.yaml <<EOF
  endpoints:
    identity:
      namespace: openstack
    object_store:
      namespace: openstack
    ceph_mon:
      namespace: tenant-ceph
      port:
        mon:
          default: 6790
  network:
    public: ${CEPH_PUBLIC_NETWORK}
    cluster: ${CEPH_CLUSTER_NETWORK}
  deployment:
    storage_secrets: false
    ceph: false
    rbd_provisioner: false
    csi_rbd_provisioner: false
    cephfs_provisioner: false
    client_secrets: true
  bootstrap:
    enabled: false
  conf:
    rgw_ks:
      enabled: true
  storageclass:
    rbd:
      ceph_configmap_name: tenant-ceph-etc
      provision_storage_class: false
      name: tenant-rbd
      admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
      admin_secret_namespace: tenant-ceph
      user_secret_name: pvc-tenant-ceph-client-key
    cephfs:
      provision_storage_class: false
      name: cephfs
      admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
      admin_secret_namespace: tenant-ceph
      user_secret_name: pvc-tenant-ceph-cephfs-client-key
  EOF
  helm upgrade --install tenant-ceph-openstack-config ./ceph-provisioners \
    --namespace=openstack \
    --values=/tmp/tenant-ceph-openstack-config.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh openstack

  #NOTE: Validate Deployment info
  helm status tenant-ceph-openstack-config

Execute script.

7) Tenant Ceph: Deploy Rados Gateway:
-------------------------------------

Script to update: ``090-tenant-ceph-radosgateway.sh``

Update script with following overrides:

.. code-block:: console

  tee /tmp/tenant-radosgw-openstack.yaml <<EOF
  endpoints:
    identity:
      namespace: openstack
    object_store:
      namespace: openstack
    ceph_mon:
      namespace: tenant-ceph
      port:
        mon:
          default: 6790
  network:
    public: ${CEPH_PUBLIC_NETWORK}
    cluster: ${CEPH_CLUSTER_NETWORK}
  deployment:
    storage_secrets: false
    ceph: true
    rbd_provisioner: false
    csi_rbd_provisioner: false
    cephfs_provisioner: false
    client_secrets: false
  bootstrap:
    enabled: false
  conf:
    rgw_ks:
      enabled: true
  secrets:
    keyrings:
      admin: pvc-tenant-ceph-client-key
      rgw: os-ceph-bootstrap-rgw-keyring
    identity:
      admin: ceph-keystone-admin
      swift: ceph-keystone-user
      user_rgw: ceph-keystone-user-rgw
  ceph_client:
    configmap: tenant-ceph-etc
  EOF
  helm upgrade --install tenant-radosgw-openstack ./ceph-rgw \
    --namespace=openstack \
    --values=/tmp/tenant-radosgw-openstack.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_HEAT}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh openstack

  #NOTE: Validate Deployment info
  helm status tenant-radosgw-openstack


Execute script

.. code-block:: console

  + openstack service list
  +----------------------------------+----------+--------------+
  | ID                               | Name     | Type         |
  +----------------------------------+----------+--------------+
  | 0eddeb6af4fd43ea8f73f63a1ae01438 | swift    | object-store |
  | 67cc6b945e934246b25d31a9374a64af | keystone | identity     |
  +----------------------------------+----------+--------------+

.. code-block:: console

  ubuntu@node1: openstack endpoint list
  +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+
  | ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                                                         |
  +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+
  | 265212a5856e4a0aba8eb294508279c7 | RegionOne | swift        | object-store | True    | admin     | http://ceph-rgw.openstack.svc.cluster.local:8088/swift/v1/KEY_$(tenant_id)s |
  | 430174e280444598b676d503c5ed9799 | RegionOne | swift        | object-store | True    | internal  | http://ceph-rgw.openstack.svc.cluster.local:8088/swift/v1/KEY_$(tenant_id)s |
  | 480cc7360752498e822cbbc7211d213a | RegionOne | keystone     | identity     | True    | internal  | http://keystone-api.openstack.svc.cluster.local:5000/v3                     |
  | 8dfe4e4725b84e51a5eda564dee0960c | RegionOne | keystone     | identity     | True    | public    | http://keystone.openstack.svc.cluster.local:80/v3                           |
  | 948552a0d90940f7944f8c2eba7ef462 | RegionOne | swift        | object-store | True    | public    | http://radosgw.openstack.svc.cluster.local:80/swift/v1/KEY_$(tenant_id)s    |
  | 9b3526e36307400b9accfc7cc834cf99 | RegionOne | keystone     | identity     | True    | admin     | http://keystone.openstack.svc.cluster.local:80/v3                           |
  +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+

Results from Step 5, 6, 7:
--------------------------

``Storage on node1, node2, node3:``

.. code-block:: console

  ubuntu@node1:~$ ls -l /var/lib/openstack-helm/
  total 8
  drwxr-xr-x 4 root root 4096 Aug 27 04:57 ceph
  drwxr-xr-x 3 root root 4096 Aug 27 05:47 tenant-ceph

``Storage on node4, node5, node6:``

.. code-block:: console

  ubuntu@node6:~$ ls -l /var/lib/openstack-helm/
  total 4
  drwxr-xr-x 3 root root 4096 Aug 27 05:49 tenant-ceph

``Ceph Status``

.. code-block:: console

  ubuntu@node1: kubectl exec -n tenant-ceph ceph-mon-2g6km -- ceph -s
    cluster:
      id:     38339a5a-d976-49dd-88a0-2ac092c271c7
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum node3,node2,node1
      mgr: node2(active), standbys: node1
      osd: 3 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   18 pools, 93 pgs
      objects: 193 objects, 37421 bytes
      usage:   33394 MB used, 199 GB / 232 GB avail
      pgs:     93 active+clean


.. code-block:: console

  ubuntu@node1: kubectl get cm -n openstack
  NAME                                                 DATA      AGE
  ceph-etc                                             1         2h
  ceph-openstack-config-ceph-prov-bin-clients          2         2h
  ceph-rgw-bin                                         5         3m
  ceph-rgw-bin-ks                                      3         3m
  ceph-rgw-etc                                         1         3m
  tenant-ceph-etc                                      1         1h
  tenant-ceph-openstack-config-ceph-prov-bin-clients   2         1h
  tenant-radosgw-openstack-ceph-templates              1         3m
  ...

.. code-block:: console

  ubuntu@node1: kubectl get cm -n openstack ceph-rgw-etc -o yaml

.. code-block:: yaml

  apiVersion: v1
  data:
    ceph.conf: |
      [global]
      cephx = true
      cephx_cluster_require_signatures = true
      cephx_require_signatures = false
      cephx_service_require_signatures = false
      mon_addr = :6790
      mon_host = ceph-mon.tenant-ceph.svc.cluster.local:6790
      [osd]
      cluster_network = 10.0.0.0/24
      ms_bind_port_max = 7100
      ms_bind_port_min = 6800
      osd_max_object_name_len = 256
      osd_mkfs_options_xfs = -f -i size=2048
      osd_mkfs_type = xfs
      public_network = 10.0.0.0/24
  kind: ConfigMap
  metadata:
    creationTimestamp: 2018-08-27T07:47:59Z
    name: ceph-rgw-etc
    namespace: openstack
    resourceVersion: "30058"
    selfLink: /api/v1/namespaces/openstack/configmaps/ceph-rgw-etc
    uid: 848df05c-a9cd-11e8-bb1d-fa163ec12213

.. note::
  mon_addr and mon_host have non default mon port 6790.

.. code-block:: console

  ubuntu@node1: kubectl get secrets -n openstack
  NAME                                                             TYPE                                  DATA      AGE
  ceph-keystone-admin                                              Opaque                                8         4m
  ceph-keystone-user                                               Opaque                                8         4m
  ceph-keystone-user-rgw                                           Opaque                                8         4m
  ceph-ks-endpoints-token-crnrr                                    kubernetes.io/service-account-token   3         4m
  ceph-ks-service-token-9bnr8                                      kubernetes.io/service-account-token   3         4m
  ceph-openstack-config-ceph-ns-key-cleaner-token-jj7n6            kubernetes.io/service-account-token   3         2h
  ceph-openstack-config-ceph-ns-key-generator-token-5sqfw          kubernetes.io/service-account-token   3         2h
  ceph-rgw-storage-init-token-mhqdw                                kubernetes.io/service-account-token   3         4m
  ceph-rgw-token-9s6nd                                             kubernetes.io/service-account-token   3         4m
  os-ceph-bootstrap-rgw-keyring                                    Opaque                                1         36m
  pvc-ceph-client-key                                              kubernetes.io/rbd                     1         2h
  pvc-tenant-ceph-client-key                                       kubernetes.io/rbd                     1         1h
  swift-ks-user-token-9slvc                                        kubernetes.io/service-account-token   3         4m
  tenant-ceph-openstack-config-ceph-ns-key-cleaner-token-r6v9v     kubernetes.io/service-account-token   3         1h
  tenant-ceph-openstack-config-ceph-ns-key-generator-token-dt472   kubernetes.io/service-account-token   3         1h
  ...

.. code-block:: console

  ubuntu@node1: kubectl get svc -n tenant-ceph
  NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
  ceph-mgr              ClusterIP   10.107.183.4     <none>        7001/TCP,9284/TCP   2h
  ceph-mon              ClusterIP   None             <none>        6790/TCP            2h
  ceph-mon-discovery    ClusterIP   None             <none>        6790/TCP            2h
  ingress               ClusterIP   10.109.105.140   <none>        80/TCP,443/TCP      3h
  ingress-error-pages   ClusterIP   None             <none>        80/TCP              3h
  ingress-exporter      ClusterIP   10.102.110.153   <none>        10254/TCP           3h

.. code-block:: console

  ubuntu@node1: kubectl get endpoints -n tenant-ceph
  NAME                  ENDPOINTS                                                    AGE
  ceph-mgr              10.0.0.12:9284,10.0.0.16:9284,10.0.0.12:7001 + 1 more...     2h
  ceph-mon              10.0.0.12:6790,10.0.0.16:6790,10.0.0.9:6790                  2h
  ceph-mon-discovery    10.0.0.12:6790,10.0.0.16:6790,10.0.0.9:6790                  2h
  ingress               192.168.2.7:80,192.168.5.14:80,192.168.2.7:443 + 1 more...   3h
  ingress-error-pages   192.168.2.8:8080,192.168.5.13:8080                           3h
  ingress-exporter      192.168.2.7:10254,192.168.5.14:10254                         3h

.. code-block:: console

  ubuntu@node1: kubectl get endpoints -n openstack
  NAME                          ENDPOINTS                                                               AGE
  ceph-rgw                      192.168.2.42:8088,192.168.5.44:8088                                     20m
  ingress                       192.168.2.4:80,192.168.5.5:80,192.168.2.4:443 + 1 more...               3h
  ingress-error-pages           192.168.2.3:8080,192.168.5.6:8080                                       3h
  ingress-exporter              192.168.2.4:10254,192.168.5.5:10254                                     3h
  keystone                      192.168.2.4:80,192.168.5.5:80,192.168.2.4:443 + 1 more...               2h
  keystone-api                  192.168.2.21:5000,192.168.5.24:5000                                     2h
  mariadb                       192.168.2.17:3306                                                       2h
  mariadb-discovery             192.168.5.22:4567,192.168.5.22:3306                                     2h
  mariadb-ingress-error-pages   192.168.5.20:8080                                                       2h
  mariadb-server                192.168.5.22:3306                                                       2h
  memcached                     192.168.2.19:11211                                                      2h
  rabbitmq                      192.168.0.196:15672,192.168.2.18:15672,192.168.5.23:15672 + 6 more...   2h
  rabbitmq-dsv-7b1733           192.168.0.196:15672,192.168.2.18:15672,192.168.5.23:15672 + 6 more...   2h
  rabbitmq-mgr-7b1733           192.168.2.4:80,192.168.5.5:80,192.168.2.4:443 + 1 more...               2h
  radosgw                       192.168.2.4:80,192.168.5.5:80,192.168.2.4:443 + 1 more...               20m

.. code-block:: console

  ubuntu@node1: kubectl get svc -n openstack
  NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                        AGE
  ceph-rgw                      ClusterIP   10.102.173.130   <none>        8088/TCP                       20m
  ingress                       ClusterIP   10.102.1.71      <none>        80/TCP,443/TCP                 3h
  ingress-error-pages           ClusterIP   None             <none>        80/TCP                         3h
  ingress-exporter              ClusterIP   10.105.29.29     <none>        10254/TCP                      3h
  keystone                      ClusterIP   10.108.94.108    <none>        80/TCP,443/TCP                 2h
  keystone-api                  ClusterIP   10.99.50.35      <none>        5000/TCP                       2h
  mariadb                       ClusterIP   10.111.140.93    <none>        3306/TCP                       2h
  mariadb-discovery             ClusterIP   None             <none>        3306/TCP,4567/TCP              2h
  mariadb-ingress-error-pages   ClusterIP   None             <none>        80/TCP                         2h
  mariadb-server                ClusterIP   10.101.237.241   <none>        3306/TCP                       2h
  memcached                     ClusterIP   10.111.175.130   <none>        11211/TCP                      2h
  rabbitmq                      ClusterIP   10.96.78.137     <none>        5672/TCP,25672/TCP,15672/TCP   2h
  rabbitmq-dsv-7b1733           ClusterIP   None             <none>        5672/TCP,25672/TCP,15672/TCP   2h
  rabbitmq-mgr-7b1733           ClusterIP   10.104.105.46    <none>        80/TCP,443/TCP                 2h
  radosgw                       ClusterIP   10.101.237.167   <none>        80/TCP,443/TCP                 20m

.. code-block:: console

  ubuntu@node1: kubectl get storageclasses
  NAME      PROVISIONER    AGE
  general   ceph.com/rbd   1h


8) Deploy Glance:
-----------------

Script to update and execute: ``100-glance.sh``

Update script overrides as following:

.. code-block:: yaml

  endpoints:
    object_store:
      namespace: tenant-ceph
    ceph_object_store:
      namespace: tenant-ceph
  ceph_client:
    configmap: tenant-ceph-etc
    user_secret_name: tenant-pvc-ceph-client-key

.. code-block:: console

    ubuntu@node1: openstack service list
    +----------------------------------+----------+--------------+
    | ID                               | Name     | Type         |
    +----------------------------------+----------+--------------+
    | 0eddeb6af4fd43ea8f73f63a1ae01438 | swift    | object-store |
    | 67cc6b945e934246b25d31a9374a64af | keystone | identity     |
    | 81a61ec8eff74070bb3c2f0118c1bcd5 | glance   | image        |
    +----------------------------------+----------+--------------+

.. code-block:: console

    ubuntu@node1: openstack endpoint list
    +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+
    | ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                                                         |
    +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+
    | 265212a5856e4a0aba8eb294508279c7 | RegionOne | swift        | object-store | True    | admin     | http://ceph-rgw.openstack.svc.cluster.local:8088/swift/v1/KEY_$(tenant_id)s |
    | 3fd88bc6e4774ff78c94bfa8aaaec3cf | RegionOne | glance       | image        | True    | admin     | http://glance-api.openstack.svc.cluster.local:9292/                         |
    | 430174e280444598b676d503c5ed9799 | RegionOne | swift        | object-store | True    | internal  | http://ceph-rgw.openstack.svc.cluster.local:8088/swift/v1/KEY_$(tenant_id)s |
    | 47505d5186ab448e9213f67bc833d2f1 | RegionOne | glance       | image        | True    | public    | http://glance.openstack.svc.cluster.local:80/                               |
    | 480cc7360752498e822cbbc7211d213a | RegionOne | keystone     | identity     | True    | internal  | http://keystone-api.openstack.svc.cluster.local:5000/v3                     |
    | 8dfe4e4725b84e51a5eda564dee0960c | RegionOne | keystone     | identity     | True    | public    | http://keystone.openstack.svc.cluster.local:80/v3                           |
    | 937c2eacce8b4159bf918f4005c2b0ab | RegionOne | glance       | image        | True    | internal  | http://glance-api.openstack.svc.cluster.local:9292/                         |
    | 948552a0d90940f7944f8c2eba7ef462 | RegionOne | swift        | object-store | True    | public    | http://radosgw.openstack.svc.cluster.local:80/swift/v1/KEY_$(tenant_id)s    |
    | 9b3526e36307400b9accfc7cc834cf99 | RegionOne | keystone     | identity     | True    | admin     | http://keystone.openstack.svc.cluster.local:80/v3                           |
    +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------------------------------------+

.. note::
  Above output shows ``http://ceph-rgw.openstack.svc.cluster.local`` which shows
  that swift is pointing to tenant-ceph.

9) Deploy Cinder:
-----------------

Script to update and execute: ``110-cinder.sh``

Update script overrides as following:

.. code-block:: yaml

  backup:
    posix:
      volume:
        class_name: rbd-tenant
  ceph_client:
    configmap: tenant-ceph-etc
    user_secret_name: pvc-tenant-ceph-client-key


.. code-block:: console

    + OS_CLOUD=openstack_helm
    + openstack service list
    +----------------------------------+----------+--------------+
    | ID                               | Name     | Type         |
    +----------------------------------+----------+--------------+
    | 0eddeb6af4fd43ea8f73f63a1ae01438 | swift    | object-store |
    | 66bd0179eada4ab8899a58356fd4d508 | cinder   | volume       |
    | 67cc6b945e934246b25d31a9374a64af | keystone | identity     |
    | 81a61ec8eff74070bb3c2f0118c1bcd5 | glance   | image        |
    | c126046fc5ec4c52acfc8fee0e2f4dda | cinderv2 | volumev2     |
    | f89b99a31a124b7790e3bb60387380b1 | cinderv3 | volumev3     |
    +----------------------------------+----------+--------------+
    + sleep 30
    + openstack volume type list
    +--------------------------------------+------+-----------+
    | ID                                   | Name | Is Public |
    +--------------------------------------+------+-----------+
    | d1734540-38e7-4ef8-b74d-36a2c71df8e5 | rbd1 | True      |
    +--------------------------------------+------+-----------+
    + helm test cinder --timeout 900
    RUNNING: cinder-test
    PASSED: cinder-test

.. code-block:: console

  ubuntu@node1: kubectl exec -n tenant-ceph ceph-mon-2g6km -- ceph osd lspools
  1 rbd,2 cephfs_metadata,3 cephfs_data,4 .rgw.root,5 default.rgw.control,
  6 default.rgw.data.root,7 default.rgw.gc,8 default.rgw.log,
  9 default.rgw.intent-log,10 default.rgw.meta,
  11 default.rgw.usage,12 default.rgw.users.keys,
  13 default.rgw.users.email,14 default.rgw.users.swift,
  15 default.rgw.users.uid,16 default.rgw.buckets.extra,
  17 default.rgw.buckets.index,18 default.rgw.buckets.data,
  19 cinder.volumes,

.. note::
  Above output shows that tenant ceph now has 19 pools including one for Cinder.

.. code-block:: console

  ubuntu@node1: kubectl exec -n tenant-ceph ceph-mon-2g6km -- ceph -s
    cluster:
      id:     38339a5a-d976-49dd-88a0-2ac092c271c7
      health: HEALTH_OK

    services:
      mon: 3 daemons, quorum node3,node2,node1
      mgr: node2(active), standbys: node1
      osd: 3 osds: 3 up, 3 in
      rgw: 2 daemons active

    data:
      pools:   19 pools, 101 pgs
      objects: 233 objects, 52644 bytes
      usage:   33404 MB used, 199 GB / 232 GB avail
      pgs:     101 active+clean

    io:
      client:   27544 B/s rd, 0 B/s wr, 26 op/s rd, 17 op/s wr
