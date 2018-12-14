{{/*
Copyright 2017-2018 The Openstack-Helm Authors.

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
  Renders securityContext for a Kubernetes pod.
values: |
  pod:
    user:
      myApp:
        uid: 34356
    security_context:
      myApp:
        seLinuxOptions:
          level: "s0:c123,c456"
usage: |
  {{ dict "envAll" . "application" "myApp" | include "helm-toolkit.snippets.kubernetes_pod_security_context" }}
return: |
  securityContext:
    runAsUser: 34356
    seLinuxOptions:
      level: "s0:c123,c456"
*/}}

{{- define "helm-toolkit.snippets.kubernetes_pod_security_context" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
securityContext:
  runAsUser: {{ index $envAll.Values.pod.user $application "uid" }}
{{- if hasKey (index $envAll.Values.pod $application) "security_context" }}
{{ toYaml (index $envAll.Values.pod $application "security_context") | indent 2 }}
{{- end }}
{{- end -}}
