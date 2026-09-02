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
# Without this the job would pass whether or not the feature works:
# oslo.messaging retries its AMQP connection indefinitely, so a service whose
# account was never declared comes up and merely logs, and helm tests that do
# not exercise notifications would not notice.
#
# Either reconciler is verified the same way, which is the point of the
# resources being compatible: the API group is discovered rather than assumed,
# and everything below is expressed in terms of the resources and the broker
# rather than of whoever reconciled them. The group can still be forced with
# GROUP= to check one path in a deployment that happens to have both installed.
#
# Self-skipping, so the playbook can call it unconditionally. The definitions
# are installed by default, so their presence says nothing about which
# provisioning path a deployment took. What settles it is whether any resources
# of these kinds exist: a deployment still using the per-chart rabbit-init jobs
# renders none, and this exits 0 there.

set -euo pipefail

NAMESPACE=${1:-openstack}
TIMEOUT=${TIMEOUT:-600s}
KINDS=${KINDS:-"vhosts users permissions policies"}
OSH_GROUP=rabbitmq.osh.openstack.org
UPSTREAM_GROUP=rabbitmq.com

# Count the resources of one group, so the group carrying them can be picked
# without waiting on anything.
count_group() {
  local group=$1 total=0 kind n
  kubectl get crd "vhosts.${group}" > /dev/null 2>&1 || { echo 0; return; }
  for kind in ${KINDS}; do
    n=$(kubectl -n "${NAMESPACE}" get "${kind}.${group}" -o name 2>/dev/null | grep -c . || true)
    total=$((total + ${n:-0}))
  done
  echo "${total}"
}

if [ -n "${GROUP:-}" ]; then
  groups="${GROUP}"
else
  groups="${OSH_GROUP} ${UPSTREAM_GROUP}"
fi

group=""
for candidate in ${groups}; do
  if [ "$(count_group "${candidate}")" -gt 0 ]; then
    group="${candidate}"
    break
  fi
done

if [ -z "${group}" ]; then
  echo "No RabbitMQ topology resources in ${NAMESPACE}: this deployment"
  echo "provisions messaging with the per-chart rabbit-init jobs, or with"
  echo "neither, so there is nothing to verify"
  exit 0
fi
echo "Verifying the ${group} resources in ${NAMESPACE}"

# Collected before anything is waited on, so that "no resources at all" is told
# apart from "resources that never went Ready" rather than by a timeout.
resources=()
for kind in ${KINDS}; do
  while read -r resource; do
    [ -n "${resource}" ] && resources+=("${resource}")
  done <<< "$(kubectl -n "${NAMESPACE}" get "${kind}.${group}" -o name 2>/dev/null || true)"
done
found=${#resources[@]}

# Something has to be acting on the resources; without a reconciler they would
# sit untouched and every wait below would time out with a less obvious message.
# Which reconciler is expected follows from the group.
if [ "${group}" = "${OSH_GROUP}" ]; then
  reconciler=$(kubectl -n "${NAMESPACE}" get deployment \
    -l application=rabbitmq,component=topology-controller -o name 2>/dev/null || true)
  hint="Enable manifests.deployment_topology_controller on the rabbitmq chart."
else
  # Matched by name rather than by label: the operator installs itself into a
  # namespace of its own choosing, and its labels are not part of any contract.
  reconciler=$(kubectl get deployment --all-namespaces -o name 2>/dev/null \
    | grep 'messaging-topology-operator' || true)
  hint="Deploy the upstream messaging-topology-operator."
fi
if [ -z "${reconciler}" ]; then
  echo "ERROR: ${found} ${group} resources exist but no reconciler is running."
  echo "       ${hint}"
  exit 1
fi

echo "Waiting for ${found} topology custom resources in ${NAMESPACE} to be Ready"
for resource in "${resources[@]}"; do
  # kubectl wait reads .status.conditions for the entry of type Ready, which is
  # the whole point of keeping the upstream status shape: any tooling written
  # against either reconciler reads it the same way.
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

# The broker pod carries the rabbitmq chart's labels or the cluster operator's,
# depending on who deployed it, and rabbitmqctl is on both images.
CONTAINER=rabbitmq
POD=""
for selector in \
    "application=rabbitmq,component=server" \
    "app.kubernetes.io/component=rabbitmq" \
    "app.kubernetes.io/part-of=rabbitmq"; do
  POD=$(kubectl -n "${NAMESPACE}" get pod -l "${selector}" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  [ -n "${POD}" ] && break
done
if [ -z "${POD}" ]; then
  echo "ERROR: no RabbitMQ server pod found in ${NAMESPACE}"
  kubectl -n "${NAMESPACE}" get pods
  exit 1
fi

broker_vhosts=$(kubectl -n "${NAMESPACE}" exec "${POD}" -c "${CONTAINER}" -- \
  rabbitmqctl -q list_vhosts | awk '{print $1}')
broker_users=$(kubectl -n "${NAMESPACE}" exec "${POD}" -c "${CONTAINER}" -- \
  rabbitmqctl -q list_users | awk '{print $1}')

echo "Checking the broker on ${POD} agrees"

# A Ready condition says the reconciler got a success from the management API.
# Reading the objects back out of the broker says it meant what we think.
for vhost in $(kubectl -n "${NAMESPACE}" get "vhosts.${group}" \
    -o jsonpath='{range .items[*]}{.spec.name}{"\n"}{end}'); do
  if ! grep -qxF "${vhost}" <<< "${broker_vhosts}"; then
    echo "ERROR: vhost ${vhost} is Ready but absent from the broker"
    echo "broker reported: ${broker_vhosts}"
    exit 1
  fi
  echo "  vhost ${vhost}: present"
done

# The account name is read from the secret the User imports rather than from
# status: both reconcilers publish the imported credentials, but only one of
# them is guaranteed to echo the name into a status field.
for secret in $(kubectl -n "${NAMESPACE}" get "users.${group}" \
    -o jsonpath='{range .items[*]}{.spec.importCredentialsSecret.name}{"\n"}{end}'); do
  [ -n "${secret}" ] || continue
  user=$(kubectl -n "${NAMESPACE}" get secret "${secret}" \
    -o jsonpath='{.data.username}' | base64 -d)
  if ! grep -qxF "${user}" <<< "${broker_users}"; then
    echo "ERROR: user ${user} is Ready but absent from the broker"
    echo "broker reported: ${broker_users}"
    exit 1
  fi
  echo "  user ${user}: present"
done

# The rabbitmq chart declares guest in definitions.json and
# management.load_definitions re-imports it on every node boot, while
# loopback_users.guest is false, so its controller removes it on every sweep --
# the thing the one-shot rabbit-init deletion could not do. A cluster the
# operator builds never has the account, so this holds either way.
if grep -qxF 'guest' <<< "${broker_users}"; then
  echo "ERROR: the guest account is still present. With the rabbitmq chart the"
  echo "       reconciler should remove it on every sweep; check"
  echo "       RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER."
  exit 1
fi
echo "  guest account: absent"

echo "RabbitMQ topology verified"
