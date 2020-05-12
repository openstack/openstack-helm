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

{{/*
abstract: |
  Reneders an attonation key and value for a release
values: |
  release_uuid: null
usage: |
  {{ tuple . | include "helm-toolkit.snippets.release_uuid" }}
return: |
  "openstackhelm.openstack.org/release_uuid": ""
*/}}

{{- define "helm-toolkit.snippets.release_uuid" -}}
{{- $envAll := index . 0 -}}
"openstackhelm.openstack.org/release_uuid": {{ $envAll.Values.release_uuid | default "" | quote }}
{{- end -}}
