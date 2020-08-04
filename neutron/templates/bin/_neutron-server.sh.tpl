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
COMMAND="${@:-start}"

function start () {
{{- if .Values.manifests.certificates }}
  add_config="neutron.conf;"
{{- if ( has "tungstenfabric" .Values.network.backend ) }}
  add_config+='plugins/tungstenfabric/tf_plugin.ini;'
{{- else }}
  add_config+='plugins/ml2/ml2_conf.ini;'
{{- end }}
{{- if .Values.conf.plugins.taas.taas.enabled }}
  add_config+='taas_plugin.ini;'
{{- end }}
{{- if ( has "sriov" .Values.network.backend ) }}
  add_config+='plugins/ml2/sriov_agent.ini;'
{{- end }}
{{- if .Values.conf.plugins.l2gateway }}
  add_config+='l2gw_plugin.ini;'
{{- end }}

  export OS_NEUTRON_CONFIG_FILES=${add_config}

  for WSGI_SCRIPT in neutron-api; do
    cp -a $(type -p ${WSGI_SCRIPT}) /var/www/cgi-bin/neutron/
  done

  if [ -f /etc/apache2/envvars ]; then
    # Loading Apache2 ENV variables
    source /etc/apache2/envvars
    mkdir -p ${APACHE_RUN_DIR}
  fi

{{- if .Values.conf.software.apache2.a2enmod }}
  {{- range .Values.conf.software.apache2.a2enmod }}
  a2enmod {{ . }}
  {{- end }}
{{- end }}

{{- if .Values.conf.software.apache2.a2ensite }}
  {{- range .Values.conf.software.apache2.a2ensite }}
  a2ensite {{ . }}
  {{- end }}
{{- end }}

{{- if .Values.conf.software.apache2.a2dismod }}
  {{- range .Values.conf.software.apache2.a2dismod }}
  a2dismod {{ . }}
  {{- end }}
{{- end }}

  if [ -f /var/run/apache2/apache2.pid ]; then
    # Remove the stale pid for debian/ubuntu images
    rm -f /var/run/apache2/apache2.pid
  fi
  # Starts Apache2
  exec {{ .Values.conf.software.apache2.binary }} {{ .Values.conf.software.apache2.start_parameters }}
{{- else }}
  exec neutron-server \
        --config-file /etc/neutron/neutron.conf \
{{- if ( has "tungstenfabric" .Values.network.backend ) }}
        --config-file /etc/neutron/plugins/tungstenfabric/tf_plugin.ini
{{- else }}
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini
{{- end }}
{{- if .Values.conf.plugins.taas.taas.enabled }} \
        --config-file /etc/neutron/taas_plugin.ini
{{- end }}
{{- if ( has "sriov" .Values.network.backend ) }} \
        --config-file /etc/neutron/plugins/ml2/sriov_agent.ini
{{- end }}
{{- if .Values.conf.plugins.l2gateway }} \
        --config-file /etc/neutron/l2gw_plugin.ini
{{- end }}
{{- end }}
}

function stop () {
{{- if .Values.manifests.certificates }}
  if [ -f /etc/apache2/envvars ]; then
    source /etc/apache2/envvars
  fi
  {{ .Values.conf.software.apache2.binary }} -k graceful-stop
{{- else }}
  kill -TERM 1
{{- end }}
}

$COMMAND
