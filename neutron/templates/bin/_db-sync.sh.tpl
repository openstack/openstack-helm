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

set -ex

neutron-db-manage \
  --config-file /etc/neutron/neutron.conf \
{{- if ( has "tungstenfabric" .Values.network.backend ) }}
  --config-file /etc/neutron/plugins/tungstenfabric/tf_plugin.ini \
{{- else }}
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini \
{{- end }}
  upgrade head

{{- if .Values.conf.plugins.taas.taas.enabled }}
neutron-db-manage \
  --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini \
  --subproject tap-as-a-service \
  upgrade head
{{- end }}

{{- if .Values.conf.fwaas_driver }}
neutron-db-manage \
  --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini \
  --subproject neutron-fwaas \
  upgrade head
{{- end }}

{{- if .Values.conf.neutron_vpnaas }}
neutron-db-manage \
  --config-file /etc/neutron/neutron.conf \
  --subproject neutron-vpnaas \
  upgrade head
{{- end }}
