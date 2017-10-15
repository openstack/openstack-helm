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

metadata_ip="{{- .Values.conf.metadata_agent.DEFAULT.nova_metadata_ip -}}"
if [ -z "${metadata_ip}" ] ; then
    metadata_ip=$(getent hosts metadata | awk '{print $1}')
fi

cat <<EOF>/tmp/pod-shared/neutron-metadata-agent.ini
[DEFAULT]
nova_metadata_ip=$metadata_ip
EOF

