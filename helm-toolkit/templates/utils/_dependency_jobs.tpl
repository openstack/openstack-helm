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
Filter dependency jobs when the corresponding manifests.job_* flag is disabled.
The manifest key is derived from the dependency job name by dropping the chart
prefix up to the first dash and converting the remainder from kebab-case to
snake_case. If no matching manifest key exists, the job is kept.
*/}}
{{- define "helm-toolkit.utils.dependency_jobs_filter" -}}
{{- $envAll := index . "envAll" -}}
{{- $deps := index . "deps" -}}
{{- if and $deps (hasKey $deps "jobs") $deps.jobs -}}
{{- if kindIs "string" (index $deps.jobs 0) -}}
{{- $jobs := list -}}
{{- range $job := $deps.jobs -}}
{{- $jobParts := splitList "-" $job -}}
{{- if gt (len $jobParts) 1 -}}
{{- $manifestKey := printf "job_%s" (join "_" (rest $jobParts)) -}}
{{- if or (not (hasKey $envAll.Values.manifests $manifestKey)) (index $envAll.Values.manifests $manifestKey) -}}
{{- $jobs = append $jobs $job -}}
{{- end -}}
{{- else -}}
{{- $jobs = append $jobs $job -}}
{{- end -}}
{{- end -}}
{{- $_ := set $deps "jobs" $jobs -}}
{{- end -}}
{{- end -}}
{{ $deps | toYaml }}
{{- end -}}
