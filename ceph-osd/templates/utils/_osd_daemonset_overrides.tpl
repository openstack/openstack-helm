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

{{- define "ceph.utils.match_exprs_hash" }}
  {{- $match_exprs := index . 0 }}
  {{- $context := index . 1 }}
  {{- $_ := set $context.Values "__match_exprs_hash_content" "" }}
  {{- range $match_expr := $match_exprs }}
    {{- $_ := set $context.Values "__match_exprs_hash_content" (print $context.Values.__match_exprs_hash_content $match_expr.key $match_expr.operator ($match_expr.values | quote)) }}
  {{- end }}
  {{- $context.Values.__match_exprs_hash_content | sha256sum | trunc 8 }}
  {{- $_ := unset $context.Values "__match_exprs_hash_content" }}
{{- end }}

{{- define "ceph.utils.osd_daemonset_overrides" }}
  {{- $daemonset := index . 0 }}
  {{- $daemonset_yaml := index . 1 }}
  {{- $configmap_include := index . 2 }}
  {{- $configmap_name := index . 3 }}
  {{- $context := index . 4 }}
  {{- $_ := unset $context ".Files" }}
  {{- $_ := set $context.Values "__daemonset_yaml" $daemonset_yaml }}
  {{- $daemonset_root_name := printf "ceph_%s" $daemonset }}
  {{- $_ := set $context.Values "__daemonset_list" list }}
  {{- $_ := set $context.Values "__default" dict }}
  {{- if hasKey $context.Values.conf "overrides" }}
    {{- range $key, $val := $context.Values.conf.overrides }}

      {{- if eq $key $daemonset_root_name }}
        {{- range $type, $type_data := . }}

          {{- if eq $type "hosts" }}
            {{- range $host_data := . }}
              {{/* dictionary that will contain all info needed to generate this
              iteration of the daemonset */}}
              {{- $current_dict := dict }}

              {{/* set daemonset name */}}
              {{- $_ := set $current_dict "name" $host_data.name }}

              {{/* apply overrides */}}
              {{- $override_conf_copy := $host_data.conf }}
              {{/* Deep copy to prevent https://storyboard.openstack.org/#!/story/2005936 */}}
              {{- $root_conf_copy := omit ($context.Values.conf | toYaml | fromYaml) "overrides" }}
              {{- $merged_dict := mergeOverwrite $root_conf_copy $override_conf_copy }}
              {{- $root_conf_copy2 := dict "conf" $merged_dict }}
              {{- $context_values := omit (omit ($context.Values | toYaml | fromYaml) "conf") "__daemonset_list" }}
              {{- $root_conf_copy3 := mergeOverwrite $context_values $root_conf_copy2 }}
              {{- $root_conf_copy4 := dict "Values" $root_conf_copy3 }}
              {{- $_ := set $current_dict "nodeData" $root_conf_copy4 }}

              {{/* Schedule to this host explicitly. */}}
              {{- $nodeSelector_dict := dict }}

              {{- $_ := set $nodeSelector_dict "key" "kubernetes.io/hostname" }}
              {{- $_ := set $nodeSelector_dict "operator" "In" }}

              {{- $values_list := list $host_data.name }}
              {{- $_ := set $nodeSelector_dict "values" $values_list }}

              {{- $list_aggregate := list $nodeSelector_dict }}
              {{- $_ := set $current_dict "matchExpressions" $list_aggregate }}

              {{/* store completed daemonset entry/info into global list */}}
              {{- $list_aggregate := append $context.Values.__daemonset_list $current_dict }}
              {{- $_ := set $context.Values "__daemonset_list" $list_aggregate }}

            {{- end }}
          {{- end }}

          {{- if eq $type "labels" }}
            {{- $_ := set $context.Values "__label_list" . }}
            {{- range $label_data := . }}
              {{/* dictionary that will contain all info needed to generate this
              iteration of the daemonset. */}}
              {{- $_ := set $context.Values "__current_label" dict }}

              {{/* set daemonset name */}}
              {{- $_ := set $context.Values.__current_label "name" $label_data.label.key }}

              {{/* apply overrides */}}
              {{- $override_conf_copy := $label_data.conf }}
              {{/* Deep copy to prevent https://storyboard.openstack.org/#!/story/2005936 */}}
              {{- $root_conf_copy := omit ($context.Values.conf | toYaml | fromYaml) "overrides" }}
              {{- $merged_dict := mergeOverwrite $root_conf_copy $override_conf_copy }}
              {{- $root_conf_copy2 := dict "conf" $merged_dict }}
              {{- $context_values := omit (omit ($context.Values | toYaml | fromYaml) "conf") "__daemonset_list" }}
              {{- $root_conf_copy3 := mergeOverwrite $context_values $root_conf_copy2 }}
              {{- $root_conf_copy4 := dict "Values" $root_conf_copy3 }}
              {{- $_ := set $context.Values.__current_label "nodeData" $root_conf_copy4 }}

              {{/* Schedule to the provided label value(s) */}}
              {{- $label_dict := omit $label_data.label "NULL" }}
              {{- $_ := set $label_dict "operator" "In" }}
              {{- $list_aggregate := list $label_dict }}
              {{- $_ := set $context.Values.__current_label "matchExpressions" $list_aggregate }}

              {{/* Do not schedule to other specified labels, with higher
              precedence as the list position increases. Last defined label
              is highest priority. */}}
              {{- $other_labels := without $context.Values.__label_list $label_data }}
              {{- range $label_data2 := $other_labels }}
                {{- $label_dict := omit $label_data2.label "NULL" }}

                {{- $_ := set $label_dict "operator" "NotIn" }}

                {{- $list_aggregate := append $context.Values.__current_label.matchExpressions $label_dict }}
                {{- $_ := set $context.Values.__current_label "matchExpressions" $list_aggregate }}
              {{- end }}
              {{- $_ := set $context.Values "__label_list" $other_labels }}

              {{/* Do not schedule to any other specified hosts */}}
              {{- range $type, $type_data := $val }}
                {{- if eq $type "hosts" }}
                  {{- range $host_data := . }}
                    {{- $label_dict := dict }}

                    {{- $_ := set $label_dict "key" "kubernetes.io/hostname" }}
                    {{- $_ := set $label_dict "operator" "NotIn" }}

                    {{- $values_list := list $host_data.name }}
                    {{- $_ := set $label_dict "values" $values_list }}

                    {{- $list_aggregate := append $context.Values.__current_label.matchExpressions $label_dict }}
                    {{- $_ := set $context.Values.__current_label "matchExpressions" $list_aggregate }}
                  {{- end }}
                {{- end }}
              {{- end }}

              {{/* store completed daemonset entry/info into global list */}}
              {{- $list_aggregate := append $context.Values.__daemonset_list $context.Values.__current_label }}
              {{- $_ := set $context.Values "__daemonset_list" $list_aggregate }}
              {{- $_ := unset $context.Values "__current_label" }}

            {{- end }}
          {{- end }}
        {{- end }}

        {{/* scheduler exceptions for the default daemonset */}}
        {{- $_ := set $context.Values.__default "matchExpressions" list }}

        {{- range $type, $type_data := . }}
          {{/* Do not schedule to other specified labels */}}
          {{- if eq $type "labels" }}
            {{- range $label_data := . }}
              {{- $default_dict := omit $label_data.label "NULL" }}

              {{- $_ := set $default_dict "operator" "NotIn" }}

              {{- $list_aggregate := append $context.Values.__default.matchExpressions $default_dict }}
              {{- $_ := set $context.Values.__default "matchExpressions" $list_aggregate }}
            {{- end }}
          {{- end }}
          {{/* Do not schedule to other specified hosts */}}
          {{- if eq $type "hosts" }}
            {{- range $host_data := . }}
              {{- $default_dict := dict }}

              {{- $_ := set $default_dict "key" "kubernetes.io/hostname" }}
              {{- $_ := set $default_dict "operator" "NotIn" }}

              {{- $values_list := list $host_data.name }}
              {{- $_ := set $default_dict "values" $values_list }}

              {{- $list_aggregate := append $context.Values.__default.matchExpressions $default_dict }}
              {{- $_ := set $context.Values.__default "matchExpressions" $list_aggregate }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{/* generate the default daemonset */}}

  {{/* set name */}}
  {{- $_ := set $context.Values.__default "name" "default" }}

  {{/* no overrides apply, so copy as-is */}}
  {{- $root_conf_copy1 := omit $context.Values.conf "overrides" }}
  {{- $root_conf_copy2 := dict "conf" $root_conf_copy1 }}
  {{- $context_values := omit $context.Values "conf" }}
  {{- $root_conf_copy3 := mergeOverwrite $context_values $root_conf_copy2 }}
  {{- $root_conf_copy4 := dict "Values" $root_conf_copy3 }}
  {{- $_ := set $context.Values.__default "nodeData" $root_conf_copy4 }}

  {{/* add to global list */}}
  {{- $list_aggregate := append $context.Values.__daemonset_list $context.Values.__default }}
  {{- $_ := set $context.Values "__daemonset_list" $list_aggregate }}

  {{- $_ := set $context.Values "__last_configmap_name" $configmap_name }}
  {{- range $current_dict := $context.Values.__daemonset_list }}

    {{- $context_novalues := omit $context "Values" }}
    {{- $merged_dict := mergeOverwrite $context_novalues $current_dict.nodeData }}
    {{- $_ := set $current_dict "nodeData" $merged_dict }}

    {{/* name needs to be a DNS-1123 compliant name. Ensure lower case */}}
    {{- $name_format1 := printf (print $daemonset_root_name "-" $current_dict.name) | lower }}
    {{/* labels may contain underscores which would be invalid here, so we replace them with dashes
    there may be other valid label names which would make for an invalid DNS-1123 name
    but these will be easier to handle in future with sprig regex* functions
    (not availabile in helm 2.5.1) */}}
    {{- $name_format2 := $name_format1 | replace "_" "-" | replace "." "-" }}
    {{/* To account for the case where the same label is defined multiple times in overrides
    (but with different label values), we add a sha of the scheduling data to ensure
    name uniqueness */}}
    {{- $_ := set $current_dict "dns_1123_name" dict }}
    {{- if hasKey $current_dict "matchExpressions" }}
      {{- $_ := set $current_dict "dns_1123_name" (printf (print $name_format2 "-" (list $current_dict.matchExpressions $context | include "ceph.utils.match_exprs_hash"))) }}
    {{- else }}
      {{- $_ := set $current_dict "dns_1123_name" $name_format2 }}
    {{- end }}

    {{/* set daemonset metadata name */}}
    {{- if not $context.Values.__daemonset_yaml.metadata }}{{- $_ := set $context.Values.__daemonset_yaml "metadata" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.metadata.name }}{{- $_ := set $context.Values.__daemonset_yaml.metadata "name" dict }}{{- end }}
    {{- $_ := set $context.Values.__daemonset_yaml.metadata "name" $current_dict.dns_1123_name }}

    {{/* cross-reference configmap name to container volume definitions */}}
    {{- $_ := set $context.Values "__volume_list" list }}
    {{- range $current_volume := $context.Values.__daemonset_yaml.spec.template.spec.volumes }}
      {{- $_ := set $context.Values "__volume" $current_volume }}
      {{- if hasKey $context.Values.__volume "configMap" }}
        {{- if eq $context.Values.__volume.configMap.name $context.Values.__last_configmap_name }}
          {{- $_ := set $context.Values.__volume.configMap "name" $current_dict.dns_1123_name }}
        {{- end }}
      {{- end }}
      {{- $updated_list := append $context.Values.__volume_list $context.Values.__volume }}
      {{- $_ := set $context.Values "__volume_list" $updated_list }}
    {{- end }}
    {{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec "volumes" $context.Values.__volume_list }}

    {{/* populate scheduling restrictions */}}
    {{- if hasKey $current_dict "matchExpressions" }}
      {{- if not $context.Values.__daemonset_yaml.spec.template.spec }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template "spec" dict }}{{- end }}
      {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec "affinity" dict }}{{- end }}
      {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity "nodeAffinity" dict }}{{- end }}
      {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity "requiredDuringSchedulingIgnoredDuringExecution" dict }}{{- end }}
      {{- $match_exprs := dict }}
      {{- $_ := set $match_exprs "matchExpressions" $current_dict.matchExpressions }}
      {{- $appended_match_expr := list $match_exprs }}
      {{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution "nodeSelectorTerms" $appended_match_expr }}
    {{- end }}

    {{/* input value hash for current set of values overrides */}}
    {{- if not $context.Values.__daemonset_yaml.spec }}{{- $_ := set $context.Values.__daemonset_yaml "spec" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template }}{{- $_ := set $context.Values.__daemonset_yaml.spec "template" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template.metadata }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template "metadata" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template.metadata.annotations }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.metadata "annotations" dict }}{{- end }}
    {{- $cmap := list $current_dict.dns_1123_name $current_dict.nodeData | include $configmap_include }}
    {{- $values_hash := $cmap | quote | sha256sum }}
    {{- $_ := set $context.Values.__daemonset_yaml.spec.template.metadata.annotations "configmap-etc-hash" $values_hash }}

    {{/* generate configmap */}}
---
{{ $cmap }}

    {{/* generate daemonset yaml */}}
{{ range $k, $v := index $current_dict.nodeData.Values.conf.storage "osd" }}
---
{{- $_ := set $context.Values "__tmpYAML" dict }}

{{ $dsNodeName := index $context.Values.__daemonset_yaml.metadata "name" }}
{{ $localDsNodeName := print (trunc 54 $current_dict.dns_1123_name) "-" (print $dsNodeName $k | quote | sha256sum | trunc 8) }}
{{- if not $context.Values.__tmpYAML.metadata }}{{- $_ := set $context.Values.__tmpYAML "metadata" dict }}{{- end }}
{{- $_ := set $context.Values.__tmpYAML.metadata "name" $localDsNodeName }}

{{ $podDataVols := index $context.Values.__daemonset_yaml.spec.template.spec "volumes" }}
{{- $_ := set $context.Values "__tmpPodVols" $podDataVols }}

  {{ if eq $v.data.type "directory" }}
    {{ $dataDirVolume := dict "hostPath" (dict "path" $v.data.location) "name" "data" }}
    {{ $newPodDataVols := append $context.Values.__tmpPodVols $dataDirVolume }}
    {{- $_ := set $context.Values "__tmpPodVols" $newPodDataVols }}
  {{ else }}
    {{ $dataDirVolume := dict "emptyDir" dict "name" "data" }}
    {{ $newPodDataVols := append $context.Values.__tmpPodVols $dataDirVolume }}
    {{- $_ := set $context.Values "__tmpPodVols" $newPodDataVols }}
  {{ end }}

  {{- if ne $v.data.type "bluestore" }}
  {{ if eq $v.journal.type "directory" }}
    {{ $journalDirVolume := dict "hostPath" (dict "path" $v.journal.location) "name" "journal" }}
    {{ $newPodDataVols := append $context.Values.__tmpPodVols $journalDirVolume }}
    {{- $_ := set $context.Values "__tmpPodVols" $newPodDataVols }}
  {{ else }}
    {{ $dataDirVolume := dict "emptyDir" dict "name" "journal" }}
    {{ $newPodDataVols := append $context.Values.__tmpPodVols $dataDirVolume }}
    {{- $_ := set $context.Values "__tmpPodVols" $newPodDataVols }}
  {{ end }}
  {{ else }}
    {{ $dataDirVolume := dict "emptyDir" dict "name" "journal" }}
    {{ $newPodDataVols := append $context.Values.__tmpPodVols $dataDirVolume }}
    {{- $_ := set $context.Values "__tmpPodVols" $newPodDataVols }}
  {{- end }}

  {{- if not $context.Values.__tmpYAML.spec }}{{- $_ := set $context.Values.__tmpYAML "spec" dict }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template }}{{- $_ := set $context.Values.__tmpYAML.spec "template" dict }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template.spec }}{{- $_ := set $context.Values.__tmpYAML.spec.template "spec" dict }}{{- end }}
  {{- $_ := set $context.Values.__tmpYAML.spec.template.spec "volumes" $context.Values.__tmpPodVols }}

  {{- if not $context.Values.__tmpYAML.spec }}{{- $_ := set $context.Values.__tmpYAML "spec" dict }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template }}{{- $_ := set $context.Values.__tmpYAML.spec "template" dict }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template.spec }}{{- $_ := set $context.Values.__tmpYAML.spec.template "spec" dict }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template.spec.containers }}{{- $_ := set $context.Values.__tmpYAML.spec.template.spec "containers" list }}{{- end }}
  {{- if not $context.Values.__tmpYAML.spec.template.spec.initContainers }}{{- $_ := set $context.Values.__tmpYAML.spec.template.spec "initContainers" list }}{{- end }}

  {{- $_ := set $context.Values "__tmpYAMLcontainers" list }}
  {{- range $podContainer := $context.Values.__daemonset_yaml.spec.template.spec.containers }}
    {{- $_ := set $context.Values "_tmpYAMLcontainer" $podContainer }}
    {{- if empty $context.Values._tmpYAMLcontainer.env }}
    {{- $_ := set $context.Values._tmpYAMLcontainer "env" ( list ) }}
    {{- end }}
    {{- $tmpcontainerEnv := omit $context.Values._tmpYAMLcontainer "env" }}
    {{- if eq $v.data.type "bluestore" }}
    {{- if and $v.block_db $v.block_wal}}
    {{ $containerEnv := prepend (prepend (prepend ( prepend ( prepend ( prepend (index $context.Values._tmpYAMLcontainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_DB" "value" $v.block_db.location)) (dict "name" "BLOCK_DB_SIZE" "value" $v.block_db.size)) (dict "name" "BLOCK_WAL" "value" $v.block_wal.location)) (dict "name" "BLOCK_WAL_SIZE" "value" $v.block_wal.size) }}
    {{- $_ := set $tmpcontainerEnv "env" $containerEnv }}
    {{- else if $v.block_db }}
    {{ $containerEnv := prepend (prepend ( prepend ( prepend (index $context.Values._tmpYAMLcontainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_DB" "value" $v.block_db.location)) (dict "name" "BLOCK_DB_SIZE" "value" $v.block_db.size) }}
    {{- $_ := set $tmpcontainerEnv "env" $containerEnv }}
    {{- else if $v.block_wal }}
    {{ $containerEnv := prepend (prepend ( prepend ( prepend (index $context.Values._tmpYAMLcontainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_WAL" "value" $v.block_wal.location)) (dict "name" "BLOCK_WAL_SIZE" "value" $v.block_wal.size) }}
    {{- $_ := set $tmpcontainerEnv "env" $containerEnv }}
    {{ else }}
    {{ $containerEnv := prepend (prepend (index $context.Values._tmpYAMLcontainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location) }}
    {{- $_ := set $tmpcontainerEnv "env" $containerEnv }}
    {{- end }}
    {{ else }}
    {{ $containerEnv := prepend (prepend (prepend ( prepend (index $context.Values._tmpYAMLcontainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "JOURNAL_TYPE" "value" $v.journal.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "JOURNAL_LOCATION" "value" $v.journal.location) }}
    {{- $_ := set $tmpcontainerEnv "env" $containerEnv }}
    {{- end }}
    {{- $localInitContainerEnv := omit $context.Values._tmpYAMLcontainer "env" }}
    {{- $_ := set $localInitContainerEnv "env" $tmpcontainerEnv.env }}
    {{ $containerList := append $context.Values.__tmpYAMLcontainers $localInitContainerEnv }}
    {{ $_ := set $context.Values "__tmpYAMLcontainers" $containerList }}
  {{ end }}
  {{- $_ := set $context.Values.__tmpYAML.spec.template.spec "containers" $context.Values.__tmpYAMLcontainers }}

  {{- $_ := set $context.Values "__tmpYAMLinitContainers" list }}
  {{- range $podContainer := $context.Values.__daemonset_yaml.spec.template.spec.initContainers }}
    {{- $_ := set $context.Values "_tmpYAMLinitContainer" $podContainer }}
    {{- $tmpinitcontainerEnv := omit $context.Values._tmpYAMLinitContainer "env" }}
    {{- if eq $v.data.type "bluestore" }}
    {{- if and $v.block_db $v.block_wal}}
    {{ $initcontainerEnv := prepend (prepend (prepend ( prepend ( prepend ( prepend (index $context.Values._tmpYAMLinitContainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_DB" "value" $v.block_db.location)) (dict "name" "BLOCK_DB_SIZE" "value" $v.block_db.size)) (dict "name" "BLOCK_WAL" "value" $v.block_wal.location)) (dict "name" "BLOCK_WAL_SIZE" "value" $v.block_wal.size) }}
    {{- $_ := set $tmpinitcontainerEnv "env" $initcontainerEnv }}
    {{- else if $v.block_db }}
    {{ $initcontainerEnv := prepend (prepend ( prepend ( prepend (index $context.Values._tmpYAMLinitContainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_DB" "value" $v.block_db.location)) (dict "name" "BLOCK_DB_SIZE" "value" $v.block_db.size) }}
    {{- $_ := set $tmpinitcontainerEnv "env" $initcontainerEnv }}
    {{- else if $v.block_wal }}
    {{ $initcontainerEnv := prepend (prepend ( prepend ( prepend (index $context.Values._tmpYAMLinitContainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "BLOCK_WAL" "value" $v.block_wal.location)) (dict "name" "BLOCK_WAL_SIZE" "value" $v.block_wal.size) }}
    {{- $_ := set $tmpinitcontainerEnv "env" $initcontainerEnv }}
    {{ else }}
    {{ $initcontainerEnv := prepend (prepend (index $context.Values._tmpYAMLinitContainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location) }}
    {{- $_ := set $tmpinitcontainerEnv "env" $initcontainerEnv }}
    {{- end }}
    {{ else }}
    {{ $initcontainerEnv := prepend (prepend (prepend ( prepend (index $context.Values._tmpYAMLinitContainer "env") (dict "name" "STORAGE_TYPE" "value" $v.data.type)) (dict "name" "JOURNAL_TYPE" "value" $v.journal.type)) (dict "name" "STORAGE_LOCATION" "value" $v.data.location)) (dict "name" "JOURNAL_LOCATION" "value" $v.journal.location) }}
    {{- $_ := set $tmpinitcontainerEnv "env" $initcontainerEnv }}
    {{- end }}
    {{- $localInitContainerEnv := omit $context.Values._tmpYAMLinitContainer "env" }}
    {{- $_ := set $localInitContainerEnv "env" $tmpinitcontainerEnv.env }}
    {{ $initContainerList := append $context.Values.__tmpYAMLinitContainers $localInitContainerEnv }}
    {{ $_ := set $context.Values "__tmpYAMLinitContainers" $initContainerList }}
  {{ end }}
  {{- $_ := set $context.Values.__tmpYAML.spec.template.spec "initContainers" $context.Values.__tmpYAMLinitContainers }}

  {{- $_ := set $context.Values.__tmpYAML.spec.template.spec "volumes" $context.Values.__tmpPodVols }}

{{ merge $context.Values.__tmpYAML $context.Values.__daemonset_yaml | toYaml }}

{{ end }}

---
    {{- $_ := set $context.Values "__last_configmap_name" $current_dict.dns_1123_name }}
  {{- end }}
{{- end }}
