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

{{- /*
    Return string with all ceph backends separated by comma. The list
    is either empty or it starts with a comma. Assuming "a", "b" and
    "c" are ceph backends then ceph_backend_list returns ",a,b,c".
    This means the first element in the returned list representation
    can always be skipped.

    Usage:
        range $name := rest (splitList include "cinder.utils.ceph_backend_list" $)
*/ -}}
{{- define "cinder.utils.ceph_backend_list" -}}
  {{- range $name, $backend := .Values.conf.backends -}}
    {{- if kindIs "map" $backend }}
      {{- if (eq $backend.volume_driver "cinder.volume.drivers.rbd.RBDDriver") -}}
        {{- "," -}}
        {{- $name -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
