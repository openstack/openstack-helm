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
export HOME=/tmp

{{- if .Values.bootstrap.enabled | default "echo 'Not Enabled'" }}

  {{- /* Create volume types defined in Values.bootstrap */}}
  {{- /* Types can only be created for backends defined in Values.conf */}}
  {{- $volumeTypes := .Values.bootstrap.volume_types }}
  {{- range $backend_name, $backend_properties := .Values.conf.backends }}
    {{- if $backend_properties }}
      {{- range $name, $properties := $volumeTypes }}
        {{- if $properties.volume_backend_name }}
          {{- if (eq $properties.volume_backend_name $backend_properties.volume_backend_name) }}
openstack volume type show {{ $name }} || \
  openstack volume type create \
    --public \
      {{- range $key, $value := $properties }}
    --property {{ $key }}={{ $value }} \
      {{- end }}
    {{ $name }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- /* Create volumes defined in Values.conf.backends */}}
  {{- if .Values.bootstrap.bootstrap_conf_backends }}
    {{- range $name, $properties := .Values.conf.backends }}
      {{- if $properties }}
openstack volume type show {{ $name }} || \
  openstack volume type create \
    --public \
    --property volume_backend_name={{ $properties.volume_backend_name }} \
    {{ $name }}
      {{- end }}
    {{- end }}
  {{- end }}

{{- /* Check volume type and properties were added */}}
openstack volume type list --long

{{- end }}

exit 0
