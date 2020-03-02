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
Takes a tuple of values and merges into the first (target) one each subsequent
(source) one in order. If all values to merge are maps, then the tuple can be
passed as is and the target will be the result, otherwise pass a map with a
"values" key containing the tuple of values to merge, and the merge result will
be assigned to the "result" key of the passed map.

When merging maps, for each key in the source, if the target does not define
that key, the source value is assigned. If both define the key, then the key
values are merged using this algorithm (recursively) and the result is assigned
to the target key. Slices are merged by appending them and removing any
duplicates, and when passing a map to this function and including a
"merge_same_named" key set to true, then map items from the slices with the same
value for the "name" key will be merged with each other. Any other values are
merged by simply keeping the source, and throwing away the target.
*/}}

{{- define "helm-toolkit.utils.merge" -}}
  {{- $local := dict -}}
  {{- $_ := set $local "merge_same_named" false -}}
  {{- if kindIs "map" $ -}}
    {{- $_ := set $local "values" $.values -}}
    {{- if hasKey $ "merge_same_named" -}}
      {{- $_ := set $local "merge_same_named" $.merge_same_named -}}
    {{- end -}}
  {{- else -}}
    {{- $_ := set $local "values" $ -}}
  {{- end -}}

  {{- $target := first $local.values -}}
  {{- range $item := rest $local.values -}}
    {{- $call := dict "target" $target "source" . "merge_same_named" $local.merge_same_named -}}
    {{- $_ := include "helm-toolkit.utils._merge" $call -}}
    {{- $_ := set $local "result" $call.result -}}
  {{- end -}}

  {{- if kindIs "map" $ -}}
    {{- $_ := set $ "result" $local.result -}}
  {{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils._merge" -}}
  {{- $local := dict -}}

  {{- $_ := set $ "result" $.source -}}

  {{/*
  TODO: Should we `fail` when trying to merge a collection (map or slice) with
  either a different kind of collection or a scalar?
  */}}

  {{- if and (kindIs "map" $.target) (kindIs "map" $.source) -}}
    {{- range $key, $sourceValue := $.source -}}
      {{- if not (hasKey $.target $key) -}}
        {{- $_ := set $local "newTargetValue" $sourceValue -}}
        {{- if kindIs "map" $sourceValue -}}
          {{- $copy := dict -}}
          {{- $call := dict "target" $copy "source" $sourceValue -}}
          {{- $_ := include "helm-toolkit.utils._merge.shallow" $call -}}
          {{- $_ := set $local "newTargetValue" $copy -}}
        {{- end -}}
      {{- else -}}
        {{- $targetValue := index $.target $key -}}
        {{- $call := dict "target" $targetValue "source" $sourceValue "merge_same_named" $.merge_same_named -}}
        {{- $_ := include "helm-toolkit.utils._merge" $call -}}
        {{- $_ := set $local "newTargetValue" $call.result -}}
      {{- end -}}
      {{- $_ := set $.target $key $local.newTargetValue -}}
    {{- end -}}
    {{- $_ := set $ "result" $.target -}}
  {{- else if and (kindIs "slice" $.target) (kindIs "slice" $.source) -}}
    {{- $call := dict "target" $.target "source" $.source -}}
    {{- $_ := include "helm-toolkit.utils._merge.append_slice" $call -}}
    {{- if $.merge_same_named -}}
      {{- $_ := set $local "result" list -}}
      {{- $_ := set $local "named_items" dict -}}
      {{- range $item := $call.result -}}
      {{- $_ := set $local "has_name_key" false -}}
        {{- if kindIs "map" $item -}}
          {{- if hasKey $item "name" -}}
            {{- $_ := set $local "has_name_key" true -}}
          {{- end -}}
        {{- end -}}

        {{- if $local.has_name_key -}}
          {{- if hasKey $local.named_items $item.name -}}
            {{- $named_item := index $local.named_items $item.name -}}
            {{- $call := dict "target" $named_item "source" $item "merge_same_named" $.merge_same_named -}}
            {{- $_ := include "helm-toolkit.utils._merge" $call -}}
          {{- else -}}
            {{- $copy := dict -}}
            {{- $copy_call := dict "target" $copy "source" $item -}}
            {{- $_ := include "helm-toolkit.utils._merge.shallow" $copy_call -}}
            {{- $_ := set $local.named_items $item.name $copy -}}
            {{- $_ := set $local "result" (append $local.result $copy) -}}
          {{- end -}}
        {{- else -}}
          {{- $_ := set $local "result" (append $local.result $item) -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- $_ := set $local "result" $call.result -}}
    {{- end -}}
    {{- $_ := set $ "result" (uniq $local.result) -}}
  {{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils._merge.shallow" -}}
  {{- range $key, $value := $.source -}}
    {{- $_ := set $.target $key $value -}}
  {{- end -}}
{{- end -}}

{{- define "helm-toolkit.utils._merge.append_slice" -}}
  {{- $local := dict -}}
  {{- $_ := set $local "result" $.target -}}
  {{- range $value := $.source -}}
    {{- $_ := set $local "result" (append $local.result $value) -}}
  {{- end -}}
  {{- $_ := set $ "result" $local.result -}}
{{- end -}}
