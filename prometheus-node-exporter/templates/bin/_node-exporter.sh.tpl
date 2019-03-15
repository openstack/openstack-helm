#!/bin/sh
{{/*
Copyright 2017 The Openstack-Helm Authors.

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

exec /bin/node_exporter \
  {{ tuple "--collector." .Values.conf.collectors.enable | include "helm-toolkit.utils.joinListWithPrefix" }} \
  {{ tuple "--no-collector." .Values.conf.collectors.disable | include "helm-toolkit.utils.joinListWithPrefix" }} \
  {{ if .Values.conf.collectors.textfile.directory }} \
  --collector.textfile.directory={{.Values.conf.collectors.textfile.directory }} \
  {{- end }}
  --collector.ntp.server={{ .Values.conf.ntp_server_ip }}
