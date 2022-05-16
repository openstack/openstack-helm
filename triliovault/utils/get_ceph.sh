#!/bin/bash -x

set -e


CINDER_CEPH_KEYRING=$(kubectl -n rook-ceph get secrets/rook-ceph-client-cinder --template={{.data.cinder}} | base64 -d)
CEPH_CONF=$(kubectl -n openstack get configmap/rook-ceph-config -o "jsonpath={.data['ceph\.conf']}")
cd ../

tee > values_overrides/ceph.yaml  << EOF
ceph:
  enabled: true
  conf: |
    $CEPH_CONF
  rbd_user: cinder
  keyring: $CINDER_CEPH_KEYRING
EOF

