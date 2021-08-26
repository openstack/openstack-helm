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
if [[ $(openstack volume type list -f value -c Name | grep -w {{ $name }}) ]]; then
  if [[ ! $(openstack volume type show {{ $name }} | grep volume_backend_name) ]]; then
    openstack volume type set \
      {{- range $key, $value := $properties }}
      --property {{ $key }}={{ $value }} \
      {{- end }}
      {{ $name }}
  fi
else
  openstack volume type create \
    --public \
      {{- range $key, $value := $properties }}
    --property {{ $key }}={{ $value }} \
      {{- end }}
    {{ $name }}
fi
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

  {{- /* Create and associate volume QoS if defined */}}
  {{- if .Values.bootstrap.volume_qos}}
    {{- range $qos_name, $qos_properties := .Values.bootstrap.volume_qos }}
type_defined=true
      {{- /* If the volume type to associate with is not defined, skip the qos */}}
      {{- range $qos_properties.associates }}
if ! openstack volume type show {{ . }}; then
  type_defined=false
fi
      {{- end }}
if $type_defined; then
  openstack volume qos show {{ $qos_name }} || \
    openstack volume qos create \
      --consumer {{ $qos_properties.consumer }} \
      {{- range $key, $value := $qos_properties.properties }}
      --property {{ $key }}={{ $value }} \
      {{- end }}
      {{ $qos_name }}
      {{- range $qos_properties.associates }}
  openstack volume qos associate {{ $qos_name }} {{ . }}
      {{- end }}
fi
    {{- end }}
  {{- end }}

{{- /* Check volume type and properties were added */}}
openstack volume type list --long
openstack volume qos list

{{- end }}

exit 0
