#!/bin/bash

#NOTE(srwilkers): To simplify the process, we simply remove the ceph related
# labels from half the deployed nodes. This allows us to relabel them with the
# tenant ceph labels instead

# Find the number of nodes and determine half of them
export NUM_NODES=$(kubectl get nodes -o name | wc -w)
export NUM_RELABEL=$(expr $NUM_NODES / 2)

# Store all node information in JSON
kubectl get nodes -o json >> /tmp/nodes.json

# Use jq to find the names of the nodes to relabel by slicing the output at the
# number identified above
export RELABEL_NODES=$(cat /tmp/nodes.json | jq -r '.items[0:(env.NUM_RELABEL|tonumber)] | .[].metadata.name')

# Relabel the nodes appropriately
for node in $RELABEL_NODES; do
  for ceph_label in ceph-mon ceph-osd ceph-mds ceph-rgw ceph-mgr; do
    kubectl label node $node $ceph_label-;
    kubectl label node $node $ceph_label-tenant=enabled;
  done;
  kubectl label node $node tenant-ceph-control-plane=enabled;
done;
