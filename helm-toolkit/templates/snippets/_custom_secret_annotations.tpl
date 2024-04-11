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
  Adds custom annotations to the secret spec of a component.
examples:
  - values: |
      annotations:
        secret:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          identity:
            admin:
              another.tld/foo: "bar"
    usage: |
      {{ tuple "identity" "admin" . | include "helm-toolkit.snippets.custom_secret_annotations" }}
    return: |
      another.tld/foo: bar
  - values: |
      annotations:
        secret:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          identity:
            admin:
              another.tld/foo: "bar"
    usage: |
      {{ tuple "oslo_db" "admin" . | include "helm-toolkit.snippets.custom_secret_annotations" }}
    return: |
      custom.tld/key: "value"
      custom.tld/key2: "value2"
  - values: |
      annotations:
        secret:
          default:
            custom.tld/key: "value"
            custom.tld/key2: "value2"
          identity:
            admin:
              another.tld/foo: "bar"
          oslo_db:
            admin:
    usage: |
      {{ tuple "oslo_db" "admin" . | include "helm-toolkit.snippets.custom_secret_annotations" }}
    return: |
      custom.tld/key: "value"
      custom.tld/key2: "value2"
*/}}

{{- define "helm-toolkit.snippets.custom_secret_annotations" -}}
{{- $secretType := index . 0 -}}
{{- $userClass := index . 1 | replace "-" "_" -}}
{{- $envAll := index . 2 -}}
{{- if (hasKey $envAll.Values "annotations") -}}
{{- if (hasKey $envAll.Values.annotations "secret") -}}
{{- $annotationsMap := index $envAll.Values.annotations.secret $secretType | default dict -}}
{{- $defaultAnnotations := dict -}}
{{- if (hasKey $envAll.Values.annotations.secret "default" ) -}}
{{- $defaultAnnotations = $envAll.Values.annotations.secret.default -}}
{{- end -}}
{{- $annotations := index $annotationsMap $userClass | default $defaultAnnotations -}}
{{- if (not (empty $annotations)) -}}
{{- toYaml $annotations -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
