# Summary
This is the minimal set of templates necessary to make the rest
of Openstack-Helm charts work with Ceph clusters managed by the
Rook operator. Rook operator not only deploys Ceph clusters but
also provides convenience when interfacing with those clusters
via CRDs which can be used for managing pools/keys/users etc.
However Openstack-Helm charts do not utilize Rook CRDs but instead
manage Ceph assets like pools/keyrings/users/buckets etc. by means
of running bootstrap scripts. Before using Openstack-Helm charts we
have to provision a minimal set of assets like Ceph admin keys and
endpoints and this chart provides exactly this minimal set of templates.

# Usage
Deploy Ceph admin key and Ceph mon endpoint in the namespace where Ceph cluster is deployed.
```
tee > /tmp/ceph-adapter-rook-ceph.yaml <<EOF
manifests:
  configmap_bin: true
  configmap_templates: true
  configmap_etc: false
  job_storage_admin_keys: true
  job_namespace_client_key: false
  job_namespace_client_ceph_config: false
  service_mon_discovery: true
EOF

helm upgrade --install ceph-adapter-rook ./ceph-adapter-rook \
  --namespace=ceph \
  --values=/tmp/ceph-adapter-ceph.yaml
```

Now wait until all jobs are finished and deploy client key and client
configuration in the namespace where Openstack charts are going to be deployed.

tee > /tmp/ceph-adapter-rook-openstack.yaml <<EOF
manifests:
  configmap_bin: true
  configmap_templates: false
  configmap_etc: true
  job_storage_admin_keys: false
  job_namespace_client_key: true
  job_namespace_client_ceph_config: true
  service_mon_discovery: false
EOF

helm upgrade --install ceph-adapter-rook ./ceph-adapter-rook \
  --namespace=openstack \
  --values=/tmp/ceph-adapter-rook-openstack.yaml
```

Again wait until all jobs are finished and then you can deploy other Openstack-Helm charts.
