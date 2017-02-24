# aic-helm/maas

This chart installs a working version of MaaS on kubernetes.

### Quickstart

This chart requires a postgresql instance to be running.  

To install postgresql:

```
helm install postgresql --namespace=maas
```

Note: Postgresql may take a short time to reach the 'Running' state.  Verify that postgresql is running:

```
# kubectl get pods -n maas
NAME                         READY     STATUS        RESTARTS   AGE
postgresql-0                 1/1       Running       0          1m
```

To deploy your MaaS chart:

```
helm install maas --namespace=maas
```

To verify the helm deployment was successful:
```
# helm ls
NAME         	REVISION	UPDATED                 	STATUS  	CHART           
opining-mule 	1       	Mon Feb 13 22:20:08 2017	DEPLOYED	maas-0.1.0      
sweet-manatee	1       	Mon Feb 13 21:57:41 2017	DEPLOYED	postgresql-0.1.0

```

To check that all resources are working as intended:
```
# kubectl get all --namespace=maas
NAME                            READY     STATUS    RESTARTS   AGE
po/maas-rack-3238195061-tn5fv   1/1       Running   0          11m
po/maas-region-0                1/1       Running   0          11m
po/postgresql-0                 1/1       Running   0          34m

NAME                 CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
svc/maas-region-ui   10.105.136.244   <none>        80/TCP,8000/TCP   11m
svc/postgresql       10.107.159.38    <none>        5432/TCP          34m

NAME                       DESIRED   CURRENT   AGE
statefulsets/maas-region   1         1         11m
statefulsets/postgresql    1         1         34m

NAME                           DESIRED   SUCCESSFUL   AGE
jobs/region-import-resources   1         1            11m

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/maas-rack   1         1         1            1           11m

NAME                      DESIRED   CURRENT   READY     AGE
rs/maas-rack-3238195061   1         1         1         11m
```
