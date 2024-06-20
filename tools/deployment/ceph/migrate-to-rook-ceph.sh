#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -x

# These variables can be set prior to running the script to deploy a specific
# Ceph release using a specific Rook release. The namespaces for the Rook
# operator and the Ceph cluster may also be set, along with the YAML definition
# files that should be used for the Rook operator and Ceph cluster Helm charts.
# The default values deploy the Rook operator in the rook-ceph namespace and
# the Ceph cluster in the ceph namespace using rook-operator.yaml and
# rook-ceph.yaml in the current directory.
ROOK_RELEASE=${ROOK_RELEASE:-1.13.7}
CEPH_RELEASE=${CEPH_RELEASE:-18.2.2}
ROOK_CEPH_NAMESPACE=${ROOK_CEPH_NAMESPACE:-rook-ceph}
CEPH_NAMESPACE=${CEPH_NAMESPCE:-ceph}
ROOK_OPERATOR_YAML=${ROOK_OPERATOR_YAML:-/tmp/rook-operator.yaml}
ROOK_CEPH_YAML=${ROOK_CEPH_YAML:-/tmp/rook-ceph.yaml}

# Return a list of unique status strings for pods for a specified application
# (Pods with the same status will return a single status)
function app_status() {
  kubectl -n ${CEPH_NAMESPACE} get pods -l app=${1} -o json | jq -r '.items[].status.phase' | sort | uniq
}

# Function to wait for the initial Rook Ceph deployment to complete
function wait_for_initial_rook_deployment() {
  set +x
  echo "Waiting for initial Rook Ceph cluster deployment..."

  # Here in the while clause we have to check this
  # if monitoring is enabled
  # $(app_status rook-ceph-exporter)" != "Running"

  # The initial deployment can't deploy OSDs or RGW
  while [[ "$(app_status rook-ceph-mon)" != "Running" || \
           "$(app_status rook-ceph-mgr)" != "Running" || \
           "$(app_status rook-ceph-mds)" != "Running" || \
           "$(app_status rook-ceph-tools)" != "Running" || \
           "$(app_status rook-ceph-osd-prepare)" != "Succeeded" ]]
  do
    echo "Waiting for INITIAL Rook Ceph deployment ..."
    sleep 5
  done
  set -x
}

# Function to wait for a full cluster deployment
function wait_for_full_rook_deployment() {
  set +x
  echo "Waiting for full Rook Ceph cluster deployment..."

  # Here in the while clause we have to check this
  # if monitoring is enabled
  # $(app_status rook-ceph-exporter)" != "Running"

  # Look for everything from the initial deployment plus OSDs and RGW
  while [[ "$(app_status rook-ceph-mon)" != "Running" || \
           "$(app_status rook-ceph-mgr)" != "Running" || \
           "$(app_status rook-ceph-mds)" != "Running" || \
           "$(app_status rook-ceph-tools)" != "Running" || \
           "$(app_status rook-ceph-osd-prepare)" != "Succeeded" || \
           "$(app_status rook-ceph-osd)" != "Running" || \
           "$(app_status rook-ceph-rgw)" != "Running" ]]
  do
    echo "Waiting for FULL Rook Ceph deployment ..."
    sleep 5
  done
  set -x
}

# Function to wait for all pods except rook-ceph-tools to terminate
function wait_for_terminate() {
  set +x
  echo "Waiting for pods to terminate..."

  while [[ $(kubectl -n ${CEPH_NAMESPACE} get pods | grep -c "Running") -gt 1 ]]
  do
    sleep 5
  done
  set -x
}

# Function to wait for Ceph to reach a HEALTH_OK state
function wait_for_health_checks() {
  CEPH_NAMESPACE=${1}
  CLIENT_POD=${2}
  set +x
  echo "Waiting for the Ceph cluster to reach HEALTH_OK with all of the expectd resources..."

  # Time out each loop after ~15 minutes
  for retry in {0..180}
  do
    if [[ $(kubectl -n ${CEPH_NAMESPACE} exec ${CLIENT_POD} -- ceph mon stat -f json | jq -r '.quorum[].name' | wc -l) -eq ${MON_COUNT} &&
          $(kubectl -n ${CEPH_NAMESPACE} exec ${CLIENT_POD} -- ceph mgr count-metadata name | jq '.unknown') -eq ${MGR_COUNT} &&
          $(kubectl -n ${CEPH_NAMESPACE} exec ${CLIENT_POD} -- ceph osd stat -f json | jq '.num_up_osds') -eq ${OSD_COUNT} ]]
    then
      break
    fi
    sleep 5
  done

  for retry in {0..180}
  do
    if [[ "$(kubectl -n ${CEPH_NAMESPACE} exec ${CLIENT_POD} -- ceph health)" == "HEALTH_OK" ]]
    then
      break
    fi
    sleep 5
  done

  kubectl -n ${CEPH_NAMESPACE} exec ${CLIENT_POD} -- ceph status
  set -x
}

# Save a legacy ceph-mon host and the existing cluster FSID for later
export MON_POD=$(kubectl -n ${CEPH_NAMESPACE} get pods -l component=mon -o json | jq -r '.items[0].metadata.name')
export FSID=$(kubectl -n ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph fsid)
export OLD_MON_HOST=$(kubectl -n ${CEPH_NAMESPACE} get pods -l component=mon -o json | jq -r '.items[0].spec.nodeName')
export OLD_MON_HOST_IP=$(kubectl get nodes -o json | jq -r '.items[] | select(.metadata.name == env.OLD_MON_HOST) | .status.addresses | .[] | select(.type == "InternalIP") | .address')
export MON_COUNT=$(kubectl -n ${CEPH_NAMESPACE} get pods -l component=mon -o json | jq '.items | length')
export MGR_COUNT=$(kubectl -n ${CEPH_NAMESPACE} get pods -l component=mgr -o json | jq '.items | length')
export OSD_COUNT=$(kubectl -n ${CEPH_NAMESPACE} get pods -l component=osd -o json | jq '.items | length')

# Rename CephFS pools to match the expected names for Rook CephFS
FS_SPEC="$(kubectl -n ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph fs ls -f json 2> /dev/null)"
for fs in $(echo $FS_SPEC | jq -r '.[].name')
do
  EXPECTED_METADATA_POOL="${fs}-metadata"
  METADATA_POOL=$(echo ${FS_SPEC} | jq -r ".[] | select(.name==\"${fs}\") | .metadata_pool")

  if [[ "${METADATA_POOL}" != "${EXPECTED_METADATA_POOL}" ]]
  then
    kubectl -n ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph osd pool rename ${METADATA_POOL} ${EXPECTED_METADATA_POOL}
  fi

  EXPECTED_DATA_POOL="${fs}-data"
  # NOTE: Only one data pool must have the expected name. Only the first one is
  # checked here. If it is renamed and another pool with the same name already
  # exists, the rename will fail and there is no further action needed.
  DATA_POOL=$(echo ${FS_SPEC} | jq -r ".[] | select(.name==\"${fs}\") | .data_pools[0]")

  if [[ "${DATA_POOL}" != "${EXPECTED_DATA_POOL}" ]]
  then
    kubectl -n ${CEPH_NAMESPACE} exec ${MON_POD} -- ceph osd pool rename ${DATA_POOL} ${EXPECTED_DATA_POOL}
  fi
done

# Destroy resources in the Ceph namespace, delete Helm charts, and remove Ceph-related node labels
for resource in cj deploy ds service job
do
  kubectl -n ${CEPH_NAMESPACE} get ${resource} -o json | jq -r '.items[].metadata.name' | xargs kubectl -n ${CEPH_NAMESPACE} delete ${resource}
done
helm -n ${CEPH_NAMESPACE} delete ceph-provisioners
helm -n ${CEPH_NAMESPACE} delete ceph-client
helm -n ${CEPH_NAMESPACE} delete ceph-mon
helm -n ${CEPH_NAMESPACE} delete ceph-osd
for node in $(kubectl get nodes -o json | jq -r '.items[].metadata.name' | xargs)
do
  kubectl label node ${node} ceph-mds- ceph-mgr- ceph-mon- ceph-osd- ceph-rgw-
done

# Use rook-helm to deploy a new Ceph cluster
helm repo add rook-release https://charts.rook.io/release
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph --version ${ROOK_RELEASE} -f ${ROOK_OPERATOR_YAML}
helm upgrade --install --create-namespace --namespace ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster --version ${ROOK_RELEASE} -f ${ROOK_CEPH_YAML}
wait_for_initial_rook_deployment

# Retrieve the keyring from the new mon pod and save its host for further work
export MON_POD=$(kubectl -n ${CEPH_NAMESPACE} get pods -l app=rook-ceph-mon -o json | jq -r '.items[0].metadata.name')
kubectl -n ${CEPH_NAMESPACE} exec ${MON_POD} -- cat /etc/ceph/keyring-store/keyring > /tmp/mon-a.keyring
export MON_HOST=$(kubectl -n ${CEPH_NAMESPACE} get pods -l app=rook-ceph-mon -o json | jq -r '.items[0].spec.nodeName')
export MON_HOST_IP=$(kubectl get nodes -o json | jq -r '.items[] | select(.metadata.name == env.MON_HOST) | .status.addresses | .[] | select(.type == "InternalIP") | .address')

# Shut down the Rook operator, delete the rook-ceph deployments, and get the new rook-ceph-mon IP address
kubectl -n ${ROOK_CEPH_NAMESPACE} scale deploy rook-ceph-operator --replicas=0
kubectl -n ${CEPH_NAMESPACE} get deploy -o json | jq -r '.items[] | select(.metadata.name != "rook-ceph-tools") | .metadata.name' | xargs kubectl -n ${CEPH_NAMESPACE} delete deploy
#MON_IP=$(kubectl -n ${CEPH_NAMESPACE} get service rook-ceph-mon-a -o json | jq -r '.spec.clusterIP')
MON_IP=$(kubectl -n ${CEPH_NAMESPACE} get cm rook-ceph-mon-endpoints -o jsonpath='{.data.data}' | sed 's/.=//g' | awk -F: '{print $1}')
wait_for_terminate

# Download the old mon store and update its key to the new one
ssh ${MON_HOST_IP} "sudo rm -rf /var/lib/rook/mon-a/data"
ssh ${OLD_MON_HOST_IP} "sudo chmod -R a+rX /var/lib/openstack-helm/ceph/mon/mon/ceph-${OLD_MON_HOST}"
scp -rp ${OLD_MON_HOST_IP}:/var/lib/openstack-helm/ceph/mon/mon/ceph-${OLD_MON_HOST} /tmp
mv /tmp/ceph-${OLD_MON_HOST} /tmp/mon-a
grep -A2 "\[mon\.\]" /tmp/mon-a.keyring > /tmp/mon-a/keyring

# Generate a script to rewrite the monmap in the old mon store
cat > /tmp/mon-a/fix-monmap.sh <<EOF
#!/bin/bash
touch /etc/ceph/ceph.conf
cd /var/lib/rook
ceph-mon --extract-monmap monmap --mon-data mon-a/data
monmaptool --print monmap | awk '/mon\./{print \$3}' | cut -d. -f2 | xargs -I{} monmaptool --rm {} monmap
monmaptool --addv a [v2:$(echo ${MON_IP}):3300,v1:$(echo ${MON_IP}):6789] monmap
ceph-mon --inject-monmap monmap --mon-data mon-a/data
rm monmap
rm mon-a/data/fix-monmap.sh
EOF
chmod +x /tmp/mon-a/fix-monmap.sh

# Upload the mon store and script to the new mon host and run the script
scp -rp /tmp/mon-a ${MON_HOST_IP}:/tmp
ssh ${MON_HOST_IP} "sudo mv /tmp/mon-a /var/lib/rook/mon-a"
ssh ${MON_HOST_IP} "sudo mv /var/lib/rook/mon-a/mon-a /var/lib/rook/mon-a/data"
ssh ${MON_HOST_IP} "docker run --rm -v /var/lib/rook:/var/lib/rook quay.io/ceph/ceph:v${CEPH_RELEASE} /var/lib/rook/mon-a/data/fix-monmap.sh"

# Write the old cluster FSID to the rook-ceph-mon secret, disable authentication, and revive the Rook operator
kubectl -n ${CEPH_NAMESPACE} get secret rook-ceph-mon -o json | jq --arg fsid "$(echo -n ${FSID} | base64)" '.data.fsid = $fsid' | kubectl apply -f -
kubectl -n ${CEPH_NAMESPACE} get cm rook-config-override -o yaml | \
sed '/\[global\]/a \ \ \ \ auth_supported = none' | \
sed '/\[global\]/a \ \ \ \ auth_client_required = none' | \
sed '/\[global\]/a \ \ \ \ auth_service_required = none' | \
sed '/\[global\]/a \ \ \ \ auth_cluster_required = none' | \
kubectl apply -f -
kubectl -n ${ROOK_CEPH_NAMESPACE} scale deploy rook-ceph-operator --replicas=1
wait_for_full_rook_deployment

# Write the new mon key to the rook-ceph-tools pod and import it for authentication
TOOLS_POD=$(kubectl -n ${CEPH_NAMESPACE} get pods -l app=rook-ceph-tools -o json | jq -r '.items[0].metadata.name')
CLIENT_KEY=$(grep -A1 "\[client\.admin\]" /tmp/mon-a.keyring | awk '/key/{print $3}')
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e '[client.admin]' > /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e \"        key = ${CLIENT_KEY}\" >> /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e '        caps mds = \"allow *\"' >> /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e '        caps mon = \"allow *\"' >> /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e '        caps osd = \"allow *\"' >> /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- bash -c "echo -e '        caps mgr = \"allow *\"' >> /tmp/keyring"
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- ceph auth import -i /tmp/keyring
kubectl -n ${CEPH_NAMESPACE} exec ${TOOLS_POD} -- rm /tmp/keyring

# Remove the auth config options to re-enable authentication
kubectl -n ${CEPH_NAMESPACE} get cm rook-config-override -o yaml | \
sed '/    auth_cluster_required = none/d' | \
sed '/    auth_service_required = none/d' | \
sed '/    auth_client_required = none/d' | \
sed '/    auth_supported = none/d' | \
kubectl apply -f -

# Restart the Rook operator and Ceph cluster with the new config
kubectl -n ${ROOK_CEPH_NAMESPACE} scale deploy rook-ceph-operator --replicas=0
kubectl -n ${CEPH_NAMESPACE} get deploy -o json | jq -r '.items[] | select(.metadata.name != "rook-ceph-tools") | .metadata.name' | xargs kubectl -n ${CEPH_NAMESPACE} delete deploy
wait_for_terminate
kubectl -n ${ROOK_CEPH_NAMESPACE} scale deploy rook-ceph-operator --replicas=1
wait_for_full_rook_deployment

# Scale the mon and mgr deployments to original replica counts
kubectl -n ${CEPH_NAMESPACE} get cephcluster ceph -o json | \
jq ".spec.mon.count = ${MON_COUNT} | .spec.mgr.count = ${MGR_COUNT}" | \
kubectl apply -f -
wait_for_health_checks ${CEPH_NAMESPACE} ${TOOLS_POD}
