#!/bin/bash -x

helm delete triliovault
kubectl delete job triliovault-datamover-db-init -n triliovault
kubectl delete job triliovault-wlm-db-init -n triliovault
kubectl delete job triliovault-datamover-db-sync -n triliovault
kubectl delete job triliovault-wlm-db-sync -n triliovault
kubectl delete job triliovault-datamover-ks-service -n triliovault
kubectl delete job triliovault-datamover-ks-endpoints -n triliovault
kubectl delete job triliovault-datamover-ks-user -n triliovault
kubectl delete job triliovault-wlm-ks-endpoints -n triliovault
kubectl delete job triliovault-wlm-ks-service -n triliovault
kubectl delete job triliovault-wlm-ks-user -n triliovault
kubectl delete job triliovault-wlm-rabbit-init -n triliovault

sleep 50s

kubectl get pods -n triliovault | grep trilio
kubectl get jobs -n triliovault | grep trilio
kubectl get pv -n triliovault | grep trilio

