============
Ceph Upgrade
============

This guide documents steps showing Ceph version upgrade. The main goal of this
document is to demostrate Ceph chart update without downtime for OSH components.

Test Scenario:
==============
Upgrade Ceph component version from ``12.2.4`` to ``12.2.5`` without downtime
to OSH components.

Setup:
======
- 3 Node (VM based) env.
- Followed OSH multinode guide steps to setup nodes and install K8s cluster
- Followed OSH multinode guide steps upto Ceph install

Plan:
=====
1) Install Ceph charts (12.2.4) by updating Docker images in overrides.
2) Install OSH components as per OSH multinode guide.
3) Upgrade Ceph charts to version 12.2.5 by updating docker images in overrides.


Docker Images:
==============
1) Ceph Luminous point release images for Ceph components

.. code-block:: console

  Ceph 12.2.4: ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64
  Ceph 12.2.5: ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64

2) Ceph RBD provisioner docker images.

.. code-block:: console

  quay.io/external_storage/rbd-provisioner:v0.1.0
  quay.io/external_storage/rbd-provisioner:v0.1.1

3) Ceph Cephfs provisioner docker images.

.. code-block:: console

  quay.io/external_storage/cephfs-provisioner:v0.1.1
  quay.io/external_storage/cephfs-provisioner:v0.1.2

Steps:
======

.. note::
  Follow all steps from OSH multinode guide with below changes.

1) Install Ceph charts (version 12.2.4)


  Update ceph install script ``./tools/deployment/multinode/030-ceph.sh``
  to add ``images:`` section in overrides as shown below.

.. note::
  OSD count is set to 3 based on env setup.

.. note::
  Following is a partial part from script to show changes.

.. code-block:: yaml

    tee /tmp/ceph.yaml << EOF
      ...
    	network:
    	  public: ${CEPH_PUBLIC_NETWORK}
    	  cluster: ${CEPH_CLUSTER_NETWORK}
      images:
        tags:
          ceph_bootstrap: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_config_helper: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
          ceph_rbd_pool: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
          ceph_mon_check: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
          ceph_mon: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_osd: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_mds: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_mgr: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_rgw: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
          ceph_cephfs_provisioner: 'quay.io/external_storage/cephfs-provisioner:v0.1.1'
          ceph_rbd_provisioner: 'quay.io/external_storage/rbd-provisioner:v0.1.0'
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
            # NOTE(portdirect): 5 nodes, with one osd per node
    	      osd: 5
    	      pg_per_osd: 100
      ...
    EOF

.. note::
  ``ceph_bootstrap``, ``ceph-config_helper`` and ``ceph_rbs_pool`` images
  are used for jobs. ``ceph_mon_check`` has one script that is stable so no
  need to upgrade.

2) Deploy and Validate Ceph

.. code-block:: console

    + kubectl exec -n ceph ceph-mon-4c8xs -- ceph -s
      cluster:
        id:     39061799-d25e-4f3b-8c1a-a350e4c6d06c
        health: HEALTH_OK

      services:
        mon: 3 daemons, quorum mnode1,mnode2,mnode3
        mgr: mnode2(active), standbys: mnode3
        mds: cephfs-1/1/1 up  {0=mds-ceph-mds-745576757f-4vdn4=up:active}, 1 up:standby
        osd: 3 osds: 3 up, 3 in
        rgw: 2 daemons active

      data:
        pools:   18 pools, 93 pgs
        objects: 208 objects, 3359 bytes
        usage:   72175 MB used, 75739 MB / 144 GB avail
        pgs:     93 active+clean

3) Check Ceph Pods

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl get pods -n ceph
  NAME                                       READY     STATUS      RESTARTS   AGE
  ceph-bootstrap-s4jkx                       0/1       Completed   0          10m
  ceph-cephfs-client-key-generator-6bmzz     0/1       Completed   0          3m
  ceph-cephfs-provisioner-784c6f9d59-2z6ww   1/1       Running     0          3m
  ceph-cephfs-provisioner-784c6f9d59-sg8wv   1/1       Running     0          3m
  ceph-mds-745576757f-4vdn4                  1/1       Running     0          6m
  ceph-mds-745576757f-bxdcs                  1/1       Running     0          6m
  ceph-mds-keyring-generator-f5lxf           0/1       Completed   0          10m
  ceph-mgr-86bdc7c64b-7ptr4                  1/1       Running     0          6m
  ceph-mgr-86bdc7c64b-xgplj                  1/1       Running     0          6m
  ceph-mgr-keyring-generator-w7nxq           0/1       Completed   0          10m
  ceph-mon-4c8xs                             1/1       Running     0          10m
  ceph-mon-check-d85994946-zzwb4             1/1       Running     0          10m
  ceph-mon-keyring-generator-jdgfw           0/1       Completed   0          10m
  ceph-mon-kht8d                             1/1       Running     0          10m
  ceph-mon-mkpmm                             1/1       Running     0          10m
  ceph-osd-default-83945928-7jz4s            1/1       Running     0          8m
  ceph-osd-default-83945928-bh82j            1/1       Running     0          8m
  ceph-osd-default-83945928-t9szk            1/1       Running     0          8m
  ceph-osd-keyring-generator-6rg65           0/1       Completed   0          10m
  ceph-rbd-pool-z8vlc                        0/1       Completed   0          6m
  ceph-rbd-provisioner-84665cb84f-6s55r      1/1       Running     0          3m
  ceph-rbd-provisioner-84665cb84f-chwhd      1/1       Running     0          3m
  ceph-rgw-74559877-h56xs                    1/1       Running     0          6m
  ceph-rgw-74559877-pfjr5                    1/1       Running     0          6m
  ceph-rgw-keyring-generator-6rwct           0/1       Completed   0          10m
  ceph-storage-keys-generator-bgj2t          0/1       Completed   0          10m
  ingress-796d8cf8d6-nzrd2                   1/1       Running     0          11m
  ingress-796d8cf8d6-qqvq9                   1/1       Running     0          11m
  ingress-error-pages-54454dc79b-d5r5w       1/1       Running     0          11m
  ingress-error-pages-54454dc79b-gfpqv       1/1       Running     0          11m


4) Check version of each Ceph components.

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-4c8xs -- ceph -v
  ceph version 12.2.4 (52085d5249a80c5f5121a76d6288429f35e4e77b) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-osd-default-83945928-7jz4s -- ceph -v
  ceph version 12.2.4 (52085d5249a80c5f5121a76d6288429f35e4e77b) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mgr-86bdc7c64b-7ptr4 -- ceph -v
  ceph version 12.2.4 (52085d5249a80c5f5121a76d6288429f35e4e77b) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mds-745576757f-4vdn4 -- ceph -v
  ceph version 12.2.4 (52085d5249a80c5f5121a76d6288429f35e4e77b) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-rgw-74559877-h56xs -- ceph -v
  ceph version 12.2.4 (52085d5249a80c5f5121a76d6288429f35e4e77b) luminous (stable)

5) Check which images Provisionors and Mon-Check PODs are using

.. note::
  Showing partial output from kubectl describe command to show which image is Docker
  container is using

.. code-block:: console

  ubuntu@mnode1:~$ kubectl describe pod -n ceph ceph-cephfs-provisioner-784c6f9d59-2z6ww

  Containers:
    ceph-cephfs-provisioner:
      Container ID:  docker://98ed65617f6c4b60fe60d94b8707e52e0dd4c87791e7d72789a0cb603fa80e2c
      Image:         quay.io/external_storage/cephfs-provisioner:v0.1.1

.. code-block:: console

  ubuntu@mnode1:~$ kubectl describe pod -n ceph ceph-rbd-provisioner-84665cb84f-6s55r

  Containers:
    ceph-rbd-provisioner:
      Container ID:  docker://383be3d653cecf4cbf0c3c7509774d39dce54102309f1f0bdb07cdc2441e5e47
      Image:         quay.io/external_storage/rbd-provisioner:v0.1.0

.. code-block:: console

  ubuntu@mnode1:~$ kubectl describe pod -n ceph ceph-mon-check-d85994946-zzwb4

  Containers:
    ceph-mon:
      Container ID:  docker://d5a3396f99704038ab8ef6bfe329013ed46472ebb8e26dddc140b621329f0f92
      Image:         docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal


6) Install Openstack charts

Continue with OSH multinode guide to install other Openstack charts.

7) Capture Ceph pods statuses.

.. code-block:: console

  NAME                                       READY     STATUS      RESTARTS   AGE
  ceph-bootstrap-s4jkx                       0/1       Completed   0          2h
  ceph-cephfs-client-key-generator-6bmzz     0/1       Completed   0          2h
  ceph-cephfs-provisioner-784c6f9d59-2z6ww   1/1       Running     0          2h
  ceph-cephfs-provisioner-784c6f9d59-sg8wv   1/1       Running     0          2h
  ceph-mds-745576757f-4vdn4                  1/1       Running     0          2h
  ceph-mds-745576757f-bxdcs                  1/1       Running     0          2h
  ceph-mds-keyring-generator-f5lxf           0/1       Completed   0          2h
  ceph-mgr-86bdc7c64b-7ptr4                  1/1       Running     0          2h
  ceph-mgr-86bdc7c64b-xgplj                  1/1       Running     0          2h
  ceph-mgr-keyring-generator-w7nxq           0/1       Completed   0          2h
  ceph-mon-4c8xs                             1/1       Running     0          2h
  ceph-mon-check-d85994946-zzwb4             1/1       Running     0          2h
  ceph-mon-keyring-generator-jdgfw           0/1       Completed   0          2h
  ceph-mon-kht8d                             1/1       Running     0          2h
  ceph-mon-mkpmm                             1/1       Running     0          2h
  ceph-osd-default-83945928-7jz4s            1/1       Running     0          2h
  ceph-osd-default-83945928-bh82j            1/1       Running     0          2h
  ceph-osd-default-83945928-t9szk            1/1       Running     0          2h
  ceph-osd-keyring-generator-6rg65           0/1       Completed   0          2h
  ceph-rbd-pool-z8vlc                        0/1       Completed   0          2h
  ceph-rbd-provisioner-84665cb84f-6s55r      1/1       Running     0          2h
  ceph-rbd-provisioner-84665cb84f-chwhd      1/1       Running     0          2h
  ceph-rgw-74559877-h56xs                    1/1       Running     0          2h
  ceph-rgw-74559877-pfjr5                    1/1       Running     0          2h
  ceph-rgw-keyring-generator-6rwct           0/1       Completed   0          2h
  ceph-storage-keys-generator-bgj2t          0/1       Completed   0          2h
  ingress-796d8cf8d6-nzrd2                   1/1       Running     0          2h
  ingress-796d8cf8d6-qqvq9                   1/1       Running     0          2h
  ingress-error-pages-54454dc79b-d5r5w       1/1       Running     0          2h
  ingress-error-pages-54454dc79b-gfpqv       1/1       Running     0          2h

8) Capture Openstack pods statuses.

.. code-block:: console

  NAME                                           READY     STATUS    RESTARTS   AGE
  cinder-api-67495cdffc-24fhs                    1/1       Running   0          51m
  cinder-api-67495cdffc-kz5fn                    1/1       Running   0          51m
  cinder-backup-65b7bd9b79-8n9pb                 1/1       Running   0          51m
  cinder-scheduler-9ddbb7878-rbt4l               1/1       Running   0          51m
  cinder-volume-75bf4cc9bd-6298x                 1/1       Running   0          51m
  glance-api-68f6df4d5d-q84hs                    1/1       Running   0          1h
  glance-api-68f6df4d5d-qbfwb                    1/1       Running   0          1h
  ingress-7b4bc84cdd-84dtj                       1/1       Running   0          2h
  ingress-7b4bc84cdd-ws45r                       1/1       Running   0          2h
  ingress-error-pages-586c7f86d6-dlpm2           1/1       Running   0          2h
  ingress-error-pages-586c7f86d6-w7cj2           1/1       Running   0          2h
  keystone-api-7d9759db58-dz6kt                  1/1       Running   0          1h
  keystone-api-7d9759db58-pvsc2                  1/1       Running   0          1h
  libvirt-f7ngc                                  1/1       Running   0          24m
  libvirt-gtjc7                                  1/1       Running   0          24m
  libvirt-qmwf5                                  1/1       Running   0          24m
  mariadb-ingress-84894687fd-m8fkr               1/1       Running   0          1h
  mariadb-ingress-error-pages-78fb865f84-c6th5   1/1       Running   0          1h
  mariadb-server-0                               1/1       Running   0          1h
  memcached-memcached-5db74ddfd5-qjgvz           1/1       Running   0          1h
  neutron-dhcp-agent-default-9bpxc               1/1       Running   0          16m
  neutron-l3-agent-default-47n7k                 1/1       Running   0          16m
  neutron-metadata-agent-default-hp46c           1/1       Running   0          16m
  neutron-ovs-agent-default-6sbtg                1/1       Running   0          16m
  neutron-ovs-agent-default-nl8fr                1/1       Running   0          16m
  neutron-ovs-agent-default-tvmc4                1/1       Running   0          16m
  neutron-server-775c765d9f-cx2gk                1/1       Running   0          16m
  neutron-server-775c765d9f-ll5ml                1/1       Running   0          16m
  nova-api-metadata-557c68cb46-8f8d5             1/1       Running   1          16m
  nova-api-osapi-7658bfd554-7fbtx                1/1       Running   0          16m
  nova-api-osapi-7658bfd554-v7qcr                1/1       Running   0          16m
  nova-compute-default-g2jbd                     1/1       Running   0          16m
  nova-compute-default-ljcbc                     1/1       Running   0          16m
  nova-compute-default-mr24c                     1/1       Running   0          16m
  nova-conductor-64457cf995-lbv65                1/1       Running   0          16m
  nova-conductor-64457cf995-zts48                1/1       Running   0          16m
  nova-novncproxy-54467b9c66-vp49j               1/1       Running   0          16m
  nova-scheduler-59647c6d9f-vm78p                1/1       Running   0          16m
  openvswitch-db-cv47r                           1/1       Running   0          41m
  openvswitch-db-dq7rc                           1/1       Running   0          41m
  openvswitch-db-znp6l                           1/1       Running   0          41m
  openvswitch-vswitchd-8p2j5                     1/1       Running   0          41m
  openvswitch-vswitchd-v9rrp                     1/1       Running   0          41m
  openvswitch-vswitchd-wlgkx                     1/1       Running   0          41m
  rabbitmq-rabbitmq-0                            1/1       Running   0          1h
  rabbitmq-rabbitmq-1                            1/1       Running   0          1h
  rabbitmq-rabbitmq-2                            1/1       Running   0          1h


9) Upgrade Ceph charts to update version

Use Ceph override file ``ceph.yaml`` that was generated previously and update
images section as below

``cp /tmp/ceph.yaml ceph-update.yaml``

Update, image section in new overrides ``ceph-update.yaml`` as shown below

.. code-block:: yaml

  images:
    tags:
      ceph_bootstrap: 'docker.io/ceph/daemon:master-0351083-luminous-ubuntu-16.04-x86_64'
      ceph_config_helper: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
      ceph_rbd_pool: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
      ceph_mon_check: 'docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal'
      ceph_mon: 'docker.io/ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64'
      ceph_osd: 'docker.io/ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64'
      ceph_mds: 'docker.io/ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64'
      ceph_mgr: 'docker.io/ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64'
      ceph_rgw: 'docker.io/ceph/daemon:master-a8d20ed-luminous-ubuntu-16.04-x86_64'
      ceph_cephfs_provisioner: 'quay.io/external_storage/cephfs-provisioner:v0.1.2'
      ceph_rbd_provisioner: 'quay.io/external_storage/rbd-provisioner:v0.1.1'


10) Update Ceph Mon chart with new overrides


``helm upgrade ceph-mon ./ceph-mon --values=ceph-update.yaml``

``series of console outputs:``

.. code-block:: console

  ceph-mon-4c8xs                             0/1       Terminating   0          2h
  ceph-mon-check-d85994946-zzwb4             1/1       Running       0          2h
  ceph-mon-keyring-generator-jdgfw           0/1       Completed     0          2h
  ceph-mon-kht8d                             1/1       Running       0          2h
  ceph-mon-mkpmm                             1/1       Running       0          2h

.. code-block:: console

  ceph-mon-7zxjs                             1/1       Running     1          4m
  ceph-mon-84xt2                             1/1       Running     1          2m
  ceph-mon-check-d85994946-zzwb4             1/1       Running     0          2h
  ceph-mon-fsrv4                             1/1       Running     1          6m
  ceph-mon-keyring-generator-jdgfw           0/1       Completed   0          2h


``Results:`` Mon pods got updated one by one (rolling updates). Each Mon pod
got respawn and was in 1/1 running state before next Mon pod got updated.
Each Mon pod got restarted. Other ceph pods were not affected with this update.
No interruption to OSH pods.


11) Update Ceph OSD chart with new overrides:

``helm upgrade ceph-osd ./ceph-osd --values=ceph-update.yaml``

``series of console outputs:``

.. code-block:: console

  ceph-osd-default-83945928-7jz4s            0/1       Terminating   0          2h
  ceph-osd-default-83945928-bh82j            1/1       Running       0          2h
  ceph-osd-default-83945928-t9szk            1/1       Running       0          2h
  ceph-osd-keyring-generator-6rg65           0/1       Completed     0          2h

.. code-block:: console

  ceph-osd-default-83945928-l84tl            1/1       Running     0          9m
  ceph-osd-default-83945928-twzmk            1/1       Running     0          6m
  ceph-osd-default-83945928-wxpmh            1/1       Running     0          11m
  ceph-osd-keyring-generator-6rg65           0/1       Completed   0          2h

``Results:`` Rolling updates (one pod at a time). Other ceph pods are running.
No interruption to OSH pods.


12) Update Ceph Client chart with new overrides:

``helm upgrade ceph-client ./ceph-client --values=ceph-update.yaml``

.. code-block:: console

  ceph-mds-5fdcb5c64c-t9nmb                  0/1       Init:0/2      0          11s
  ceph-mds-745576757f-4vdn4                  1/1       Running       0          2h
  ceph-mds-745576757f-bxdcs                  1/1       Running       0          2h
  ceph-mgr-86bdc7c64b-7ptr4                  1/1       Terminating   0          2h
  ceph-mgr-86bdc7c64b-xgplj                  0/1       Terminating   0          2h
  ceph-rgw-57c68b7cd5-vxcc5                  0/1       Init:1/3      0          11s
  ceph-rgw-74559877-h56xs                    1/1       Running       0          2h
  ceph-rgw-74559877-pfjr5                    1/1       Running       0          2h

.. code-block:: console

  ceph-mds-5fdcb5c64c-c52xq                  1/1       Running     0          2m
  ceph-mds-5fdcb5c64c-t9nmb                  1/1       Running     0          2m
  ceph-mgr-654f97cbfd-9kcvb                  1/1       Running     0          1m
  ceph-mgr-654f97cbfd-gzb7k                  1/1       Running     0          1m
  ceph-rgw-57c68b7cd5-vxcc5                  1/1       Running     0          2m
  ceph-rgw-57c68b7cd5-zmdqb                  1/1       Running     0          2m

``Results:`` Rolling updates (one pod at a time). Other ceph pods are running.
No interruption to OSH pods.

13) Update Ceph Provisioners chart with new overrides:

``helm upgrade ceph-provisioners ./ceph-provisioners --values=ceph-update.yaml``

.. code-block:: console

  ceph-cephfs-provisioner-784c6f9d59-2z6ww   0/1       Terminating   0          2h
  ceph-cephfs-provisioner-784c6f9d59-sg8wv   0/1       Terminating   0          2h
  ceph-rbd-provisioner-84665cb84f-6s55r      0/1       Terminating   0          2h
  ceph-rbd-provisioner-84665cb84f-chwhd      0/1       Terminating   0          2h


.. code-block:: console

  ceph-cephfs-provisioner-65ffbd47c4-cl4hj   1/1       Running     0          1m
  ceph-cephfs-provisioner-65ffbd47c4-qrtg2   1/1       Running     0          1m
  ceph-rbd-provisioner-5bfb577ffd-b7tkx      1/1       Running     0          1m
  ceph-rbd-provisioner-5bfb577ffd-m6gg6      1/1       Running     0          1m

``Results:`` All provisioner pods got terminated at once (same time). Other ceph
pods are running. No interruption to OSH pods.

14) Capture final Ceph pod statuses:

.. code-block:: console

  ceph-bootstrap-s4jkx                       0/1       Completed   0          2h
  ceph-cephfs-client-key-generator-6bmzz     0/1       Completed   0          2h
  ceph-cephfs-provisioner-65ffbd47c4-cl4hj   1/1       Running     0          2m
  ceph-cephfs-provisioner-65ffbd47c4-qrtg2   1/1       Running     0          2m
  ceph-mds-5fdcb5c64c-c52xq                  1/1       Running     0          8m
  ceph-mds-5fdcb5c64c-t9nmb                  1/1       Running     0          8m
  ceph-mds-keyring-generator-f5lxf           0/1       Completed   0          2h
  ceph-mgr-654f97cbfd-9kcvb                  1/1       Running     0          8m
  ceph-mgr-654f97cbfd-gzb7k                  1/1       Running     0          8m
  ceph-mgr-keyring-generator-w7nxq           0/1       Completed   0          2h
  ceph-mon-7zxjs                             1/1       Running     1          27m
  ceph-mon-84xt2                             1/1       Running     1          24m
  ceph-mon-check-d85994946-zzwb4             1/1       Running     0          2h
  ceph-mon-fsrv4                             1/1       Running     1          29m
  ceph-mon-keyring-generator-jdgfw           0/1       Completed   0          2h
  ceph-osd-default-83945928-l84tl            1/1       Running     0          19m
  ceph-osd-default-83945928-twzmk            1/1       Running     0          16m
  ceph-osd-default-83945928-wxpmh            1/1       Running     0          21m
  ceph-osd-keyring-generator-6rg65           0/1       Completed   0          2h
  ceph-rbd-pool-z8vlc                        0/1       Completed   0          2h
  ceph-rbd-provisioner-5bfb577ffd-b7tkx      1/1       Running     0          2m
  ceph-rbd-provisioner-5bfb577ffd-m6gg6      1/1       Running     0          2m
  ceph-rgw-57c68b7cd5-vxcc5                  1/1       Running     0          8m
  ceph-rgw-57c68b7cd5-zmdqb                  1/1       Running     0          8m
  ceph-rgw-keyring-generator-6rwct           0/1       Completed   0          2h
  ceph-storage-keys-generator-bgj2t          0/1       Completed   0          2h
  ingress-796d8cf8d6-nzrd2                   1/1       Running     0          2h
  ingress-796d8cf8d6-qqvq9                   1/1       Running     0          2h
  ingress-error-pages-54454dc79b-d5r5w       1/1       Running     0          2h
  ingress-error-pages-54454dc79b-gfpqv       1/1       Running     0          2h

15) Capture final Openstack pod statuses:

.. code-block:: console

  cinder-api-67495cdffc-24fhs                    1/1       Running   0          1h
  cinder-api-67495cdffc-kz5fn                    1/1       Running   0          1h
  cinder-backup-65b7bd9b79-8n9pb                 1/1       Running   0          1h
  cinder-scheduler-9ddbb7878-rbt4l               1/1       Running   0          1h
  cinder-volume-75bf4cc9bd-6298x                 1/1       Running   0          1h
  glance-api-68f6df4d5d-q84hs                    1/1       Running   0          2h
  glance-api-68f6df4d5d-qbfwb                    1/1       Running   0          2h
  ingress-7b4bc84cdd-84dtj                       1/1       Running   0          2h
  ingress-7b4bc84cdd-ws45r                       1/1       Running   0          2h
  ingress-error-pages-586c7f86d6-dlpm2           1/1       Running   0          2h
  ingress-error-pages-586c7f86d6-w7cj2           1/1       Running   0          2h
  keystone-api-7d9759db58-dz6kt                  1/1       Running   0          2h
  keystone-api-7d9759db58-pvsc2                  1/1       Running   0          2h
  libvirt-f7ngc                                  1/1       Running   0          1h
  libvirt-gtjc7                                  1/1       Running   0          1h
  libvirt-qmwf5                                  1/1       Running   0          1h
  mariadb-ingress-84894687fd-m8fkr               1/1       Running   0          2h
  mariadb-ingress-error-pages-78fb865f84-c6th5   1/1       Running   0          2h
  mariadb-server-0                               1/1       Running   0          2h
  memcached-memcached-5db74ddfd5-qjgvz           1/1       Running   0          2h
  neutron-dhcp-agent-default-9bpxc               1/1       Running   0          52m
  neutron-l3-agent-default-47n7k                 1/1       Running   0          52m
  neutron-metadata-agent-default-hp46c           1/1       Running   0          52m
  neutron-ovs-agent-default-6sbtg                1/1       Running   0          52m
  neutron-ovs-agent-default-nl8fr                1/1       Running   0          52m
  neutron-ovs-agent-default-tvmc4                1/1       Running   0          52m
  neutron-server-775c765d9f-cx2gk                1/1       Running   0          52m
  neutron-server-775c765d9f-ll5ml                1/1       Running   0          52m
  nova-api-metadata-557c68cb46-8f8d5             1/1       Running   1          52m
  nova-api-osapi-7658bfd554-7fbtx                1/1       Running   0          52m
  nova-api-osapi-7658bfd554-v7qcr                1/1       Running   0          52m
  nova-compute-default-g2jbd                     1/1       Running   0          52m
  nova-compute-default-ljcbc                     1/1       Running   0          52m
  nova-compute-default-mr24c                     1/1       Running   0          52m
  nova-conductor-64457cf995-lbv65                1/1       Running   0          52m
  nova-conductor-64457cf995-zts48                1/1       Running   0          52m
  nova-novncproxy-54467b9c66-vp49j               1/1       Running   0          52m
  nova-scheduler-59647c6d9f-vm78p                1/1       Running   0          52m
  openvswitch-db-cv47r                           1/1       Running   0          1h
  openvswitch-db-dq7rc                           1/1       Running   0          1h
  openvswitch-db-znp6l                           1/1       Running   0          1h
  openvswitch-vswitchd-8p2j5                     1/1       Running   0          1h
  openvswitch-vswitchd-v9rrp                     1/1       Running   0          1h
  openvswitch-vswitchd-wlgkx                     1/1       Running   0          1h
  rabbitmq-rabbitmq-0                            1/1       Running   0          2h
  rabbitmq-rabbitmq-1                            1/1       Running   0          2h
  rabbitmq-rabbitmq-2                            1/1       Running   0          2h

16) Confirm Ceph component's version.

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mon-fsrv4 -- ceph -v
  ceph version 12.2.5 (cad919881333ac92274171586c827e01f554a70a) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-osd-default-83945928-l84tl -- ceph -v
  ceph version 12.2.5 (cad919881333ac92274171586c827e01f554a70a) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-rgw-57c68b7cd5-vxcc5 -- ceph -v
  ceph version 12.2.5 (cad919881333ac92274171586c827e01f554a70a) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mgr-654f97cbfd-gzb7k -- ceph -v
  ceph version 12.2.5 (cad919881333ac92274171586c827e01f554a70a) luminous (stable)

  ubuntu@mnode1:/opt/openstack-helm$ kubectl exec -n ceph ceph-mds-5fdcb5c64c-c52xq -- ceph -v
  ceph version 12.2.5 (cad919881333ac92274171586c827e01f554a70a) luminous (stable)

17) Check which images Provisionors and Mon-Check PODs are using

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl describe pod -n ceph ceph-cephfs-provisioner-65ffbd47c4-cl4hj

  Containers:
    ceph-cephfs-provisioner:
      Container ID:  docker://079f148c1fb9ba13ed6caa0ca9d1e63b455373020a565a212b5bd261cbaedb43
      Image:         quay.io/external_storage/cephfs-provisioner:v0.1.2

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl describe pod -n ceph ceph-rbd-provisioner-5bfb577ffd-b7tkx

  Containers:
    ceph-rbd-provisioner:
      Container ID:  docker://55b18b3400e8753f49f1343ee918a308ed1760816a1ce9797281dbfe3c5f9671
      Image:         quay.io/external_storage/rbd-provisioner:v0.1.1

.. code-block:: console

  ubuntu@mnode1:/opt/openstack-helm$ kubectl describe pod -n ceph ceph-mon-check-d85994946-zzwb4

  Containers:
    ceph-mon:
      Container ID:  docker://d5a3396f99704038ab8ef6bfe329013ed46472ebb8e26dddc140b621329f0f92
      Image:         docker.io/openstackhelm/ceph-config-helper:latest-ubuntu_focal

Conclusion:
===========
Ceph can be upgraded without downtime for Openstack components in a multinode env.
