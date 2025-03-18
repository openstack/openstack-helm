#!/bin/sh

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

active_members_present() {
  res=1
  for endpoint in $(echo $ETCD_ENDPOINTS | tr ',' '\n'); do
      if etcdctl endpoint health --endpoints=$endpoint >/dev/null 2>&1; then
          res=$?
          if [[ "$res" == 0 ]]; then
              break
          fi
      fi
  done
  echo $res
}

ETCD_REPLICAS={{ .Values.pod.replicas.etcd }}
PEER_PREFIX_NAME={{- printf "%s-%s" .Release.Name "etcd"  }}
DISCOVERY_DOMAIN={{ tuple "etcd" "discovery" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
ETCD_PEER_PORT=2380
ETCD_CLIENT_PORT={{ tuple "etcd" "internal" "client" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
ETCD_PROTOCOL={{ tuple "etcd" "internal" "client" . | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
PEERS="${PEER_PREFIX_NAME}-0=${ETCD_PROTOCOL}://${PEER_PREFIX_NAME}-0.${DISCOVERY_DOMAIN}:${ETCD_PEER_PORT}"
ETCD_ENDPOINTS="${ETCD_PROTOCOL}://${PEER_PREFIX_NAME}-0.${DISCOVERY_DOMAIN}:${ETCD_PEER_PORT}"
if [[ ${ETCD_REPLICAS} -gt 1 ]] ; then
  for i in $(seq 1 $(( ETCD_REPLICAS - 1 ))); do
    PEERS="$PEERS,${PEER_PREFIX_NAME}-${i}=${ETCD_PROTOCOL}://${PEER_PREFIX_NAME}-${i}.${DISCOVERY_DOMAIN}:${ETCD_PEER_PORT}"
    ETCD_ENDPOINTS="${ETCD_ENDPOINTS},${ETCD_PROTOCOL}://${PEER_PREFIX_NAME}-${i}.${DISCOVERY_DOMAIN}:${ETCD_PEER_PORT}"
  done
fi
ADVERTISE_PEER_URL="${ETCD_PROTOCOL}://${HOSTNAME}.${DISCOVERY_DOMAIN}:${ETCD_PEER_PORT}"
ADVERTISE_CLIENT_URL="${ETCD_PROTOCOL}://${HOSTNAME}.${DISCOVERY_DOMAIN}:${ETCD_CLIENT_PORT}"

ETCD_INITIAL_CLUSTER_STATE=new

if [[ -z "$(ls -A $ETCD_DATA_DIR)" ]]; then
  echo "State directory $ETCD_DATA_DIR is empty."
  if [[ $(active_members_present) -eq 0 ]]; then
      ETCD_INITIAL_CLUSTER_STATE=existing
      member_id=$(etcdctl --endpoints=${ETCD_ENDPOINTS} member list | grep -w ${ADVERTISE_CLIENT_URL} | awk -F "," '{ print $1 }')
      if [[ -n "$member_id" ]]; then
          echo "Current node is a member of cluster, member_id: ${member_id}"
          echo "Rejoining..."
          echo "Removing member from the cluster"
          etcdctl member remove "$member_id" --endpoints=${ETCD_ENDPOINTS}
          etcdctl member add ${ADVERTISE_CLIENT_URL} --peer-urls=${ADVERTISE_PEER_URL} --endpoints=${ETCD_ENDPOINTS}
      fi
  else
      echo "Do not have active members. Starting initial cluster state."
  fi
fi

exec etcd \
  --name ${HOSTNAME} \
  --listen-peer-urls ${ETCD_PROTOCOL}://0.0.0.0:${ETCD_PEER_PORT} \
  --listen-client-urls ${ETCD_PROTOCOL}://0.0.0.0:${ETCD_CLIENT_PORT} \
  --advertise-client-urls ${ADVERTISE_CLIENT_URL} \
  --initial-advertise-peer-urls ${ADVERTISE_PEER_URL} \
  --initial-cluster ${PEERS} \
  --initial-cluster-state ${ETCD_INITIAL_CLUSTER_STATE}
