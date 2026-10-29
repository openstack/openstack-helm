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

# Upgrade the mariadb release in place once mariadb-controller has pointed the
# master service at the elected primary, and verify that it still points there.
#
# The controller writes the service's selector, the server pods' labels plus
# statefulset.kubernetes.io/pod-name of the primary. A Service selector is an
# atomic map and Helm 4 applies manifests server-side, so a chart that also
# renders the selector is refused with a conflict on .spec.selector on every
# upgrade, and one forced through resets the selector to every galera node
# until the controller relinks it. A job that
# only installs the chart never upgrades it after the controller has acted, so
# without this step it passes either way.
#
# Self-skipping, so the playbook can call it unconditionally: there is nothing
# to verify without the mariadb release or without the controller that edits
# the selector.

set -euo pipefail

NAMESPACE=${1:-openstack}
CHART=${2:?usage: $0 NAMESPACE CHART_PATH}
RELEASE=${RELEASE:-mariadb}
SERVICE=${SERVICE:-mariadb}
TIMEOUT=${TIMEOUT:-120}
HELM_TIMEOUT=${HELM_TIMEOUT:-600s}
KEY='statefulset\.kubernetes\.io/pod-name'

if ! helm status "${RELEASE}" --namespace "${NAMESPACE}" > /dev/null 2>&1; then
  echo "No ${RELEASE} release in ${NAMESPACE}: the database is provided by"
  echo "something else, so there is no upgrade to verify"
  exit 0
fi

if [ -z "$(kubectl -n "${NAMESPACE}" get deployment \
    -l application=mariadb,component=controller -o name 2>/dev/null)" ]; then
  echo "No mariadb-controller in ${NAMESPACE}: nothing points ${SERVICE} at a"
  echo "primary, so there is no selector to keep"
  exit 0
fi

primary() {
  kubectl -n "${NAMESPACE}" get service "${SERVICE}" \
    -o jsonpath="{.spec.selector.${KEY}}"
}

# The conflict only exists once the controller has written the selector.
deadline=$((SECONDS + TIMEOUT))
until [ -n "$(primary)" ]; do
  if [ "${SECONDS}" -ge "${deadline}" ]; then
    echo "ERROR: mariadb-controller did not point ${SERVICE} at a primary"
    echo "       within ${TIMEOUT}s"
    kubectl -n "${NAMESPACE}" get service "${SERVICE}" -o yaml
    exit 1
  fi
  sleep 5
done
before=$(primary)
echo "${SERVICE} points at ${before}; upgrading ${RELEASE} in place"

if ! helm upgrade "${RELEASE}" "${CHART}" --namespace "${NAMESPACE}" \
    --reuse-values --timeout "${HELM_TIMEOUT}"; then
  echo "ERROR: upgrading ${RELEASE} failed; a conflict on .spec.selector means"
  echo "       the chart applied a selector the controller also writes"
  exit 1
fi

after=$(primary)
if [ "${after}" != "${before}" ]; then
  echo "ERROR: the upgrade changed the selector of ${SERVICE}: it pointed at"
  echo "       '${before}' and now points at '${after}'"
  exit 1
fi
echo "${SERVICE} still points at ${after} after the upgrade"

echo "mariadb upgrade verified"
