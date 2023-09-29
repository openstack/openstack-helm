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
  find /tmp -maxdepth 1 \! -path /tmp -perm /222 -exec rm -rfv {} \;

  declare -A desired_opts
  desired_opts["--stream-port"]="${PORT_STREAM}"
  desired_opts["--profiler-port"]="${PORT_PROFILER}"

  possible_opts=$(/nginx-ingress-controller --help 2>&1 | awk '/^      --/ { print $1 }')

  extra_opts=()
  for k in "${!desired_opts[@]}"; do
    if echo "$possible_opts" | grep -q -- ^${k}$; then
      extra_opts+=($k=${desired_opts[$k]})
    fi
  done

  exec /usr/bin/dumb-init \
      /nginx-ingress-controller \
      {{- if eq .Values.deployment.mode "namespace" }}
      --watch-namespace ${POD_NAMESPACE} \
      {{- end }}
      --http-port=${PORT_HTTP} \
      --https-port=${PORT_HTTPS} \
      --healthz-port=${PORT_HEALTHZ} \
      --status-port=${PORT_STATUS} \
      --default-server-port=${DEFAULT_SERVER_PORT} \
      --election-id=${RELEASE_NAME} \
      --controller-class=${CONTROLLER_CLASS} \
      --ingress-class=${INGRESS_CLASS} \
      {{- if .Values.deployment.cluster.ingressClassByName }}
      --ingress-class-by-name=${INGRESS_CLASS_BY_NAME} \
        {{- end }}
      --default-backend-service=${POD_NAMESPACE}/${ERROR_PAGE_SERVICE} \
      {{- if .Values.conf.default_ssl_certificate.enabled }}
      {{- $ns := .Values.conf.default_ssl_certificate.namespace | default .Release.Namespace }}
      {{- $secret := .Values.conf.default_ssl_certificate.name | default .Values.secrets.tls.ingress.api.public }}
      --default-ssl-certificate={{ $ns }}/{{ $secret }} \
      {{- end }}
      --configmap=${POD_NAMESPACE}/ingress-conf \
      --tcp-services-configmap=${POD_NAMESPACE}/ingress-services-tcp \
      --udp-services-configmap=${POD_NAMESPACE}/ingress-services-udp \
      "${extra_opts[@]}"
}

function stop () {
  sleep 5
  kill -TERM 1
}

$COMMAND
