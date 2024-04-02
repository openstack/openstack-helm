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
  Adds custom annotations to the job spec of a component.
examples:
  - values: |
      annotations:
        job:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          keystone_domain_manage:
            another.tld/foo: "bar"
    usage: |
      {{ tuple "keystone_domain_manage" . | include "helm-toolkit.snippets.custom_job_annotations" }}
    return: |
      another.tld/foo: bar
  - values: |
      annotations:
        job:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          keystone_domain_manage:
            another.tld/foo: "bar"
    usage: |
      {{ tuple "keystone_bootstrap" . | include "helm-toolkit.snippets.custom_job_annotations" }}
    return: |
      custom.tld/key: "value"
      custom.tld/key2: "value2"
  - values: |
      annotations:
        job:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          keystone_domain_manage:
            another.tld/foo: "bar"
          keystone_bootstrap:
    usage: |
      {{ tuple "keystone_bootstrap" . | include "helm-toolkit.snippets.custom_job_annotations" }}
    return: |
      custom.tld/key: "value"
      custom.tld/key2: "value2"
*/}}

{{- define "helm-toolkit.snippets.custom_job_annotations" -}}
{{- $envAll := index . 1 -}}
{{- $component := index . 0 | replace "-" "_" -}}
{{- if (hasKey $envAll.Values "annotations") -}}
{{- if (hasKey $envAll.Values.annotations "job") -}}
{{- $annotationsMap := $envAll.Values.annotations.job -}}
{{- $defaultAnnotations := dict -}}
{{- if (hasKey $annotationsMap "default" ) -}}
{{- $defaultAnnotations = $annotationsMap.default -}}
{{- end -}}
{{- $annotations := index $annotationsMap $component | default $defaultAnnotations -}}
{{- if (not (empty $annotations)) -}}
{{- toYaml $annotations -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
