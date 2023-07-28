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

{{- define "helm-toolkit.utils.dependency_resolver" }}
{{- $envAll := index . "envAll" -}}
{{- $dependencyMixinParam := index . "dependencyMixinParam" -}}
{{- $dependencyKey := index . "dependencyKey" -}}
{{- if $dependencyMixinParam -}}
{{- $_ := set $envAll.Values "pod_dependency" dict -}}
{{- if kindIs "string" $dependencyMixinParam }}
{{- if ( index $envAll.Values.dependencies.dynamic.targeted $dependencyMixinParam ) }}
{{- $_ := include "helm-toolkit.utils.merge" (tuple $envAll.Values.pod_dependency ( index $envAll.Values.dependencies.static $dependencyKey ) ( index $envAll.Values.dependencies.dynamic.targeted $dependencyMixinParam $dependencyKey ) ) -}}
{{- else }}
{{- $_ := set $envAll.Values "pod_dependency" ( index $envAll.Values.dependencies.static $dependencyKey ) }}
{{- end }}
{{- else if kindIs "slice" $dependencyMixinParam }}
{{- $_ := set $envAll.Values "__deps" ( index $envAll.Values.dependencies.static $dependencyKey ) }}
{{- range $k, $v := $dependencyMixinParam -}}
{{- if ( index $envAll.Values.dependencies.dynamic.targeted $v ) }}
{{- $_ := include "helm-toolkit.utils.merge" (tuple $envAll.Values.pod_dependency $envAll.Values.__deps ( index $envAll.Values.dependencies.dynamic.targeted $v $dependencyKey ) ) -}}
{{- $_ := set $envAll.Values "__deps" $envAll.Values.pod_dependency -}}
{{- end }}
{{- end }}
{{- end }}
{{- else -}}
{{- $_ := set $envAll.Values "pod_dependency" ( index $envAll.Values.dependencies.static $dependencyKey ) -}}
{{- end -}}
{{ $envAll.Values.pod_dependency | toYaml }}
{{- end }}
