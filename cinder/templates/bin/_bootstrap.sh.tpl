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
  {{- /* Generating list of backends listed in .Values.conf.backends */}}
  {{- $backendsList := list}}
  {{- range $backend_name, $backend_properties := .Values.conf.backends }}
    {{- if and $backend_properties $backend_properties.volume_backend_name }}
    {{- $backendsList = append $backendsList $backend_properties.volume_backend_name }}
    {{- end }}
  {{- end }}

  {{- range $name, $properties := $volumeTypes }}
    {{- if and $properties.volume_backend_name (has $properties.volume_backend_name $backendsList) }}
      {{- $access_type := $properties.access_type | default "public"}}
      # Create a volume type if it doesn't exist.
      # Assumption: the volume type name is unique.
      openstack volume type show {{ $name }} || \
      openstack volume type create \
        --{{ $access_type }} \
      {{ $name }}
      {{/*
        We will try to set or update volume type properties.
        To update properties, the volume type MUST NOT BE IN USE,
        and projects and domains with access to the volume type
        MUST EXIST, as well.
      */}}
      is_in_use=$(openstack volume list --long --all-projects -c Type -f value | grep -E "^{{ $name }}\s*$" || true)
      if [[ -z ${is_in_use} ]]; then
        {{- if (eq $access_type "private") }}
        volumeTypeID=$(openstack volume type show {{ $name }} -f value -c id)
        cinder type-update --is-public false ${volumeTypeID}
        {{- end }}

        {{- if and $properties.grant_access (eq $access_type "private") }}
        {{- range $domain, $domainProjects := $properties.grant_access }}
        {{- range $project := $domainProjects }}
        project_id=$(openstack project show --domain {{ $domain }} -c id -f value {{ $project }})
        if [[ -z  $(openstack volume type show {{ $name }} -c access_project_ids -f value | grep ${project_id} || true) ]]; then
          openstack volume type set --project-domain {{ $domain }} --project {{ $project }} {{ $name }}
        fi
        {{- end }}
        {{- end }}
        {{- end }}

        {{- range $key, $value := $properties }}
        {{- if and (ne $key "access_type") (ne $key "grant_access") $value }}
        openstack volume type set --property {{ $key }}={{ $value }} {{ $name }}
        {{- end }}
        {{- end }}
      fi
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
      if [[ ${type_defined} ]]; then
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
