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

barbican-db-manage upgrade

{{- $kek := (index (index .Values.conf.barbican "simple_crypto_plugin" | default dict) "kek") | default "" }}
{{- $old_kek := index .Values.conf.simple_crypto_kek_rewrap "old_kek" | default ""}}
{{- if and (not (empty $old_kek)) (not (empty $kek)) }}
set +x
echo "Ensuring that project KEKs are wrapped with the target global KEK"
/tmp/simple_crypto_kek_rewrap.py --old-kek="$(cat /tmp/old_kek)"
{{- end }}
