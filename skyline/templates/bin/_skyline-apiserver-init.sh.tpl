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

GENERATOR_ARGS="--output-file /etc/nginx/nginx.conf"
skyline-nginx-generator ${GENERATOR_ARGS}

{{- if .Values.conf.nginx.worker_processes }}
# Override nginx worker_processes. skyline-apiserver generates nginx.conf with
# "worker_processes auto;", which spawns one worker per visible host CPU. Inside
# a container/Kubernetes the cgroup CPU limit is not respected, so "auto" can
# spawn far more workers than intended and drive the pod into the OOMKiller.
sed -i 's/^worker_processes .*;/worker_processes {{ .Values.conf.nginx.worker_processes }};/' /etc/nginx/nginx.conf
{{- end }}

{{- if .Values.conf.nginx.default_language }}
# Set default language via cookie so the SPA doesn't fall back to Chinese.
# The skyline-console JS checks: localStorage -> URL -> cookie -> navigator.language,
# and defaults to zh-cn if none match exactly. Chrome's navigator.language returns
# "en-US" which doesn't match the expected "en", so we set a cookie as a fallback.
sed -i '/add_header Cache-Control "public";/a\            add_header Set-Cookie "lang={{ .Values.conf.nginx.default_language }}; Path=/; SameSite=Lax";' /etc/nginx/nginx.conf
{{- end }}
