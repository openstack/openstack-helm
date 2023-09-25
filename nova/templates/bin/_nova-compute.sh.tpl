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

exec nova-compute \
      --config-file /etc/nova/nova.conf \
{{- if .Values.console.address_search_enabled }}
      --config-file /tmp/pod-shared/nova-console.conf \
{{- end }}
{{- if .Values.conf.libvirt.address_search_enabled }}
      --config-file /tmp/pod-shared/nova-libvirt.conf \
{{- end }}
{{- if and ( empty .Values.conf.nova.DEFAULT.host ) ( .Values.pod.use_fqdn.compute ) }}
      --config-file /tmp/pod-shared/nova-compute-fqdn.conf \
{{- end }}
{{- if .Values.conf.hypervisor.address_search_enabled }}
      --config-file /tmp/pod-shared/nova-hypervisor.conf
{{- end }}
