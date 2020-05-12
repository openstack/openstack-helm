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

# Appends annotations for configuring prometheus scrape jobs via pod
# annotations. The required annotations are:
# * `prometheus.io/scrape`: Only scrape pods that have a value of `true`
# * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
# * `prometheus.io/port`: Scrape the pod on the indicated port instead of the
# pod's declared ports (default is a port-free target if none are declared).

{{- define "helm-toolkit.snippets.prometheus_pod_annotations" -}}
{{- $config := index . 0 -}}
{{- if $config.scrape }}
prometheus.io/scrape: {{ $config.scrape | quote }}
{{- end }}
{{- if $config.path }}
prometheus.io/path: {{ $config.path | quote }}
{{- end }}
{{- if $config.port }}
prometheus.io/port: {{ $config.port | quote }}
{{- end }}
{{- end -}}
