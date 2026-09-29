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
  Renders the ovn-neutron-init init container, which writes the OVN NB and SB
  connection strings to /tmp/pod-shared/ovn.ini for the main container to pick
  up as an extra config file. Every neutron pod that talks to OVN needs it, so
  it is rendered from here rather than copied into each template.
values: |
  pod:
    security_context:
      myApplication:
        container:
          ovn_neutron_init:
            readOnlyRootFilesystem: true
usage: |
  {{ dict "envAll" $envAll "application" "neutron_server" "image" "neutron_server" "resources" $envAll.Values.pod.resources.server | include "neutron.snippets.ovn_neutron_init_container" | indent 8 }}
params: |
  envAll: the root context
  application: pod.security_context key the container security context is read from
  image: images.tags key to run
  resources: the pod.resources subtree to size the container from
*/}}
{{- define "neutron.snippets.ovn_neutron_init_container" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
{{- $image := index . "image" -}}
{{- $resources := index . "resources" -}}
- name: ovn-neutron-init
{{ tuple $envAll $image | include "helm-toolkit.snippets.image" | indent 2 }}
{{ tuple $envAll $resources | include "helm-toolkit.snippets.kubernetes_resources" | indent 2 }}
{{ dict "envAll" $envAll "application" $application "container" "ovn_neutron_init" | include "helm-toolkit.snippets.kubernetes_container_security_context" | indent 2 }}
  command:
    - /tmp/neutron-ovn-init.sh
  volumeMounts:
    - name: pod-shared
      mountPath: /tmp/pod-shared
    - name: neutron-bin
      mountPath: /tmp/neutron-ovn-init.sh
      subPath: neutron-ovn-init.sh
      readOnly: true
{{- end -}}
