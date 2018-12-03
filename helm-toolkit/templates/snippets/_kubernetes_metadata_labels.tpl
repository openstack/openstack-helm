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

{{/*
abstract: |
  Renders a set of standardised labels as per:
    https://docs.helm.sh/chart_best_practices/#standard-labels
values: |
  release_group: null
usage: |
  {{ tuple . "foo" "bar" | include "helm-toolkit.snippets.kubernetes_metadata_labels" }}
return: |
  helm.sh/chart: "CHART-NAME-CHART-VERSION"
  app.kubernetes.io/managed-by: "Tiller"
  app.kubernetes.io/instance: "RELEASE-NAME"
  app.kubernetes.io/version: "APP-VERSION"
  app.kubernetes.io/name: "foo"
  app.kubernetes.io/component: "bar"
  release_group: "RELEASE-NAME"
  application: "foo"
  component: "bar"
*/}}

{{/* TODO: Remove old deprecated labels after an appropriate migration period */}}
{{- define "helm-toolkit.snippets.kubernetes_metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $chart := print $envAll.Chart.Name "-" $envAll.Chart.Version | replace "+" "_" | quote -}}
{{- $_application := index . 1 -}}
{{- $partOf := $envAll.Values.part_of | default $_application | quote -}}
{{- $application := $_application | quote -}}
{{- $component := index . 2 | quote -}}
{{- $instance := $envAll.Values.release_group | default $envAll.Release.Name | quote -}}
{{- $version := $envAll.Chart.AppVersion -}}
{{- $managedBy := $envAll.Release.Service | quote -}}
helm.sh/chart: {{ $chart }}
app.kubernetes.io/managed-by: {{ $managedBy }}
app.kubernetes.io/instance: {{ $instance }}
{{- if $version }}
app.kubernetes.io/version: {{ $version }}
{{- end }}
app.kubernetes.io/name: {{ $application }}
app.kubernetes.io/component: {{ $component }}
app.kubernetes.io/part-of: {{ $partOf }}
release_group: {{ $instance }}
application: {{ $application }}
component: {{ $component }}
{{- end -}}
