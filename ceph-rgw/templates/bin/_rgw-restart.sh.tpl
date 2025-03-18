#!/bin/bash

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

export LC_ALL=C
TIMEOUT="{{ .Values.conf.rgw_restart.timeout | default 600 }}s"

kubectl rollout restart deployment ceph-rgw
kubectl rollout status --timeout=${TIMEOUT} deployment ceph-rgw

if [ "$?" -ne 0 ]; then
  echo "Ceph rgw deployment was not able to restart in ${TIMEOUT}"
fi
