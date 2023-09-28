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

{{- if and ( empty .Values.conf.manila.generic.service_network_host ) ( .Values.pod.use_fqdn.share ) }}
tee > /tmp/pod-shared/manila-share-fqdn.conf << EOF
[generic]
service_network_host = $(hostname --fqdn)
EOF
{{- end }}
