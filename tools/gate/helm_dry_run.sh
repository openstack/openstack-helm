#!/bin/bash
#
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
set -ex

source ${WORK_DIR}/tools/gate/funcs/helm.sh

helm_build

mkdir -p ${LOGS_DIR}/dry-runs
for CHART in $(helm search | awk '{ print $1 }' | tail -n +2 | awk -F '/' '{ print $NF }'); do
  echo "Dry Running chart: $CHART"
  helm install --dry-run --debug local/$CHART --name=$CHART --namespace=openstack > ${LOGS_DIR}/dry-runs/$CHART
done
