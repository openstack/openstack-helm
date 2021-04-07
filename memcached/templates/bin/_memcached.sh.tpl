#!/bin/sh

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

memcached --version
exec memcached -v \
  -p ${MEMCACHED_PORT} \
  -U 0 \
{{- if not .Values.conf.memcached.stats_cachedump.enabled }}
  -X \
{{- end }}
  -c ${MEMCACHED_MAX_CONNECTIONS} \
  -m ${MEMCACHED_MEMORY}
