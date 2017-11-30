{{/*
Copyright 2017 The Openstack-Helm Authors.

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

# Appends annotations for configuring prometheus scrape endpoints via
# annotations. The required annotations are:
# * `prometheus.io/scrape`: Only scrape services that have a value of `true`
# * `prometheus.io/scheme`: If the metrics endpoint is secured then you will need
# to set this to `https` & most likely set the `tls_config` of the scrape config.
# * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
# * `prometheus.io/port`: If the metrics are exposed on a different port to the
# service then set this appropriately.

{{- define "helm-toolkit.snippets.prometheus_service_annotations" -}}
{{- $endpoint := index . 0 -}}
{{- $context := index . 1 -}}
prometheus.io/scrape: {{ $endpoint.scrape | quote }}
prometheus.io/scheme: {{ $endpoint.scheme.default | quote }}
prometheus.io/path: {{ $endpoint.path.default | quote }}
prometheus.io/port: {{ $endpoint.scrape_port | quote }}
{{- end -}}

# Appends annotations for configuring prometheus scrape jobs via pod
# annotations. The required annotations are:
# * `prometheus.io/scrape`: Only scrape pods that have a value of `true`
# * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
# * `prometheus.io/port`: Scrape the pod on the indicated port instead of the
# pod's declared ports (default is a port-free target if none are declared).

{{- define "helm-toolkit.snippets.prometheus_pod_annotations" -}}
{{- $pod := index . 0 -}}
{{- $context := index . 1 -}}
prometheus.io/scrape: {{ $pod.scrape | quote }}
prometheus.io/path: {{ $pod.path.default | quote }}
prometheus.io/port: {{ $pod.scrape_port | quote }}
{{- end -}}
