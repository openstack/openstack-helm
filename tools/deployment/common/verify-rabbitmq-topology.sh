#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Verify that the RabbitMQ topology custom resources the consumer charts render
# were reconciled, and that the broker agrees with them.
#
# Without this the rabbitmq-crd job would pass whether or not the feature works:
# oslo.messaging retries its AMQP connection indefinitely, so a service whose
# account was never declared comes up and merely logs, and helm tests that do
# not exercise notifications would not notice.
#
# Self-skipping, so the playbook can call it unconditionally. The definitions
# are installed by default, so their presence says nothing about which
# provisioning path a deployment took. What settles it is whether any resources
# of these kinds exist: a deployment still using the per-chart rabbit-init jobs
# renders none, and this exits 0 there.

set -euo pipefail

NAMESPACE=${1:-openstack}
GROUP=${GROUP:-rabbitmq.osh.openstack.org}
TIMEOUT=${TIMEOUT:-600s}
KINDS=${KINDS:-"vhosts users permissions policies"}

if ! kubectl get crd "vhosts.${GROUP}" > /dev/null 2>&1; then
  echo "No ${GROUP} custom resource definitions installed, nothing to verify"
  exit 0
fi

# Collected before anything is waited on, so that "no resources at all" is told
# apart from "resources that never went Ready" rather than by a timeout.
resources=()
for kind in ${KINDS}; do
  while read -r resource; do
    [ -n "${resource}" ] && resources+=("${resource}")
  done <<< "$(kubectl -n "${NAMESPACE}" get "${kind}.${GROUP}" -o name 2>/dev/null || true)"
done
found=${#resources[@]}

if [ "${found}" -eq 0 ]; then
  echo "No ${GROUP} resources in ${NAMESPACE}: this deployment provisions"
  echo "messaging with the per-chart rabbit-init jobs, nothing to verify"
  exit 0
fi

# The reconciler is what acts on the resources; without it they would sit
# unreconciled and every wait below would time out with a less obvious message.
if ! kubectl -n "${NAMESPACE}" get deployment -l application=rabbitmq,component=topology-controller \
    -o name | grep -q .; then
  echo "ERROR: ${found} ${GROUP} resources exist but no"
  echo "       rabbitmq-topology-controller deployment is running. Enable"
  echo "       manifests.deployment_topology_controller on the rabbitmq chart."
  exit 1
fi

echo "Waiting for ${found} topology custom resources in ${NAMESPACE} to be Ready"
for resource in "${resources[@]}"; do
  # kubectl wait reads .status.conditions for the entry of type Ready, which is
  # the whole point of keeping the upstream status shape: any tooling written
  # against the real operator reads it the same way.
  kubectl -n "${NAMESPACE}" wait --for=condition=Ready --timeout="${TIMEOUT}" "${resource}"
done
echo "${found} topology resources are Ready"

# Both provisioning paths write the same account's password, so finding a
# rabbit-init job here means the charts did not actually switch over.
if kubectl -n "${NAMESPACE}" get jobs -o name 2>/dev/null | grep -q 'rabbit-init'; then
  echo "ERROR: a rabbit-init job is present alongside the custom resources."
  kubectl -n "${NAMESPACE}" get jobs -o name | grep 'rabbit-init'
  exit 1
fi
echo "No rabbit-init job remains"

POD=$(kubectl -n "${NAMESPACE}" get pod \
  -l application=rabbitmq,component=server \
  -o jsonpath='{.items[0].metadata.name}')

broker_vhosts=$(kubectl -n "${NAMESPACE}" exec "${POD}" -c rabbitmq -- \
  rabbitmqctl -q list_vhosts | awk '{print $1}')
broker_users=$(kubectl -n "${NAMESPACE}" exec "${POD}" -c rabbitmq -- \
  rabbitmqctl -q list_users | awk '{print $1}')

echo "Checking the broker on ${POD} agrees"

# A Ready condition says the reconciler got a success from the management API.
# Reading the objects back out of the broker says it meant what we think.
for vhost in $(kubectl -n "${NAMESPACE}" get "vhosts.${GROUP}" \
    -o jsonpath='{range .items[*]}{.spec.name}{"\n"}{end}'); do
  if ! grep -qxF "${vhost}" <<< "${broker_vhosts}"; then
    echo "ERROR: vhost ${vhost} is Ready but absent from the broker"
    echo "broker reported: ${broker_vhosts}"
    exit 1
  fi
  echo "  vhost ${vhost}: present"
done

for user in $(kubectl -n "${NAMESPACE}" get "users.${GROUP}" \
    -o jsonpath='{range .items[*]}{.status.username}{"\n"}{end}'); do
  if ! grep -qxF "${user}" <<< "${broker_users}"; then
    echo "ERROR: user ${user} is Ready but absent from the broker"
    echo "broker reported: ${broker_users}"
    exit 1
  fi
  echo "  user ${user}: present"
done

# The chart declares guest in definitions.json and management.load_definitions
# re-imports it on every node boot, while loopback_users.guest is false. The
# reconciler removes it on every sweep, which is the thing the one-shot
# rabbit-init deletion could not do.
if grep -qxF 'guest' <<< "${broker_users}"; then
  echo "ERROR: the guest account is still present. The reconciler should"
  echo "       remove it on every sweep; check"
  echo "       RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER."
  exit 1
fi
echo "  guest account: absent"

echo "RabbitMQ topology verified"
