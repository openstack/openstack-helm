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

set -x

export ETCDCTL_API=3

ETCD_CLIENT_PORT={{ tuple "etcd" "internal" "client" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
DISCOVERY_DOMAIN={{ tuple "etcd" "discovery" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}

etcdctl endpoint health --endpoints=${POD_NAME}.${DISCOVERY_DOMAIN}:${ETCD_CLIENT_PORT}
