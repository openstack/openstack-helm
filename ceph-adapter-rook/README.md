# Summary
This is the minimal set of templates necessary to make the rest
of Openstack-Helm charts work with Ceph clusters managed by the
Rook operator. Rook operator not only deploys Ceph clusters but
also provides convenience when interfacing with those clusters
via CRDs which can be used for managing pools/keys/users etc.
However Openstack-Helm charts do not utilize Rook CRDs but instead
manage Ceph assets like pools/keyrings/users/buckets etc. by means
of running bootstrap scripts. Before using Openstack-Helm charts we
have to provision a minimal set of assets like Ceph admin key and
Ceph client config.

# Usage
```
helm upgrade --install ceph-adapter-rook ./ceph-adapter-rook \
  --namespace=openstack
```

Once all the jobs are finished you can deploy other Openstack-Helm charts.
