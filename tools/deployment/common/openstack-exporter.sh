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


set -xe

# Check if Keystone API DNS and HTTP endpoint are available; skip deployment if not
KEYSTONE_HOST="keystone-api.openstack.svc.cluster.local"
KEYSTONE_PORT=5000
KEYSTONE_URL="http://$KEYSTONE_HOST:$KEYSTONE_PORT/v3"
TIMEOUT=${TIMEOUT:-60}
INTERVAL=2
start_time=$(date +%s)

# DNS check
while ! getent hosts "$KEYSTONE_HOST" >/dev/null; do
    now=$(date +%s)
    elapsed=$((now - start_time))
    if [ $elapsed -ge $TIMEOUT ]; then
        echo "[INFO] Keystone API DNS not found after $TIMEOUT seconds, skipping prometheus-openstack-exporter deployment."
        exit 0
    fi
    echo "[INFO] Waiting for Keystone DNS... ($elapsed/$TIMEOUT)"
    sleep $INTERVAL
done

# HTTP check
while ! curl -sf "$KEYSTONE_URL" >/dev/null; do
    now=$(date +%s)
    elapsed=$((now - start_time))
    if [ $elapsed -ge $TIMEOUT ]; then
        echo "[INFO] Keystone API not responding after $TIMEOUT seconds, skipping prometheus-openstack-exporter deployment."
        exit 0
    fi
    echo "[INFO] Waiting for Keystone API... ($elapsed/$TIMEOUT)"
    sleep $INTERVAL
done

echo "[INFO] Keystone API is available. Proceeding with exporter deployment."

#NOTE: Define variables
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS_OSEXPORTER:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c prometheus-openstack-exporter ${FEATURES})"}

#NOTE: Deploy command
helm upgrade --install prometheus-openstack-exporter ${OSH_HELM_REPO}/prometheus-openstack-exporter \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_OSEXPORTER}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack
