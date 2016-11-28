# aic-helm/maas

This chart installs a working version of MaaS on kubernetes.

### Quickstart

To deploy your MaaS chart:

```
helm install maas --namespace=maas
```

To verify the helm deployment was successful:
```
# helm ls
NAME          	REVISION	UPDATED                 	STATUS  	CHART     
opining-ocelot	1       	Wed Nov 23 19:48:41 2016	DEPLOYED	maas-0.1.0
```

To check that all resources are working as intended:
```
# kubectl get all --namespace=maas
NAME                 CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
svc/maas-region-ui   10.109.228.165   <nodes>       80/TCP,8000/TCP   2m
NAME                             READY     STATUS    RESTARTS   AGE
po/maas-rack-2449935402-ppn34    1/1       Running   0          2m
po/maas-region-638716514-miczz   1/1       Running   0          2m
```
