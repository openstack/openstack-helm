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

set -e
endpt={{ tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
path={{ .Values.conf.keystone.identity.domain_config_dir | default "/etc/keystone/domains" }}

{{- range $k, $v := .Values.conf.ks_domains }}

filename=${path}/keystone.{{ $k }}.json
python /tmp/domain-manage.py \
    $endpt \
    $(openstack token issue -f value -c id) \
    $(openstack domain show {{ $k }} -f value -c id) \
    {{ $k }} $filename

{{- end }}
