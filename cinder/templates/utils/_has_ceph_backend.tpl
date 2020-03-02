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

{{- define "cinder.utils.has_ceph_backend" -}}
  {{- $has_ceph := false -}}
  {{- range $_, $backend := .Values.conf.backends -}}
    {{- if kindIs "map" $backend -}}
      {{- $has_ceph = or $has_ceph (eq $backend.volume_driver "cinder.volume.drivers.rbd.RBDDriver") -}}
    {{- end -}}
  {{- end -}}
  {{- $has_ceph -}}
{{- end -}}
