#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(kubectl get endpoints ceph-mon -n ${NAMESPACE} -o json | awk -F'"' -v port=${MON_PORT} '/ip/{print $4":"port}' | paste -sd',')
  if [[ ${ENDPOINT} == "" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's/mon_host.*/mon_host = ${ENDPOINT}/g' | tee ${CEPH_CONF}" || true
  fi
fi

echo "LAUNCHING OSD: in ${STORAGE_TYPE%-*}:${STORAGE_TYPE#*-} mode"
exec "/tmp/osd-${STORAGE_TYPE%-*}.sh"
