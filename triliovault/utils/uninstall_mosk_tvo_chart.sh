#!/bin/bash -x

helm delete triliovault
kubectl delete job triliovault-datamover-db-init -n openstack
kubectl delete job triliovault-wlm-db-init -n openstack
kubectl delete job triliovault-datamover-db-sync -n openstack
kubectl delete job triliovault-wlm-db-sync -n openstack
kubectl delete job triliovault-datamover-ks-service -n openstack
kubectl delete job triliovault-datamover-ks-endpoints -n openstack
kubectl delete job triliovault-datamover-ks-user -n openstack
kubectl delete job triliovault-wlm-ks-endpoints -n openstack
kubectl delete job triliovault-wlm-ks-service -n openstack
kubectl delete job triliovault-wlm-ks-user -n openstack
kubectl delete job triliovault-wlm-rabbit-init -n openstack

sleep 50s

kubectl get pods -n openstack | grep trilio
kubectl get jobs -n openstack | grep trilio
kubectl get pv -n openstack | grep trilio

