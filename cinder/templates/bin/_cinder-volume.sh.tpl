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

{{- if empty .Values.conf.cinder.DEFAULT.host }}
# When no static host is configured, derive it from the pod hostname.
# Combined with a StatefulSet this gives each replica a stable, unique
# host value (cinder-volume-0, cinder-volume-1, ...).
cat > /tmp/cinder-volume-host.conf << EOF
[DEFAULT]
host = ${HOSTNAME}
EOF
{{- end }}

exec cinder-volume \
     --config-file /etc/cinder/cinder.conf \
     --config-file /etc/cinder/conf/backends.conf \
     --config-file /tmp/pod-shared/internal_tenant.conf \
{{- if empty .Values.conf.cinder.DEFAULT.host }}
     --config-file /tmp/cinder-volume-host.conf \
{{- end }}
     --config-dir /etc/cinder/cinder.conf.d
