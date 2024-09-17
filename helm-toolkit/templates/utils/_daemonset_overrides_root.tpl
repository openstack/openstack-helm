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

The helm-toolkit.utils.daemonset_overrides function have some limitations:

 * it allows to override only conf values specifid in configmap-etc
 * it doesn't allow to override values for daemonsets passed via env variables
   or via damoenset definition. As result it is impossible to have mixed
   deployment when one compute is configured with dpdk while other not.
 * it is impossible to override interface names/other information stored in
   <service>-bin configmap
 * It allows to schedule on both hosts and labels, which adds some
   uncertainty

This implementation is intended to handle those limitations:

 * it allows to schedule only based on labels
 * it creates <service>-bin per daemonset override
 * it allows to override values when rendering daemonsets

 It picks data from the following structure:

  .Values:
    overrides:
      mychart_mydaemonset:
        labels:
          label::value:
            values:
              override_root_option: override_root_value
              conf:
                ovs_dpdk:
                  enabled: true
                neutron:
                  DEFAULT:
                    foo: bar

*/}}

{{- define "helm-toolkit.utils.daemonset_overrides_root" }}
  {{- $daemonset := index . 0 }}
  {{- $daemonSetTemplateName := index . 1 }}
  {{ $serviceAccountName := index . 2 }}
  {{- $configmap_include := index . 3 }}
  {{- $configmap_name := index . 4 }}
  {{- $configbin_include := index . 5 }}
  {{- $configbin_name := index . 6 }}
  {{- $context := index . 7 }}

  {{- $_ := unset $context ".Files" }}
  {{- $daemonset_root_name := printf (print $context.Chart.Name "_" $daemonset) }}
  {{- $_ := set $context.Values "__daemonset_list" list }}
  {{- $_ := set $context.Values "__default" dict }}

  {{- $default_enabled := true }}
  {{- if hasKey $context.Values "overrides" }}
    {{- range $key, $val := $context.Values.overrides }}

      {{- if eq $key $daemonset_root_name }}
        {{- range $type, $type_data := . }}
          {{- if eq $type "overrides_default" }}
            {{- $default_enabled = $type_data }}
          {{- end }}

          {{- if eq $type "labels" }}
            {{- $_ := set $context.Values "__label_dict" . }}
            {{- range $lname, $ldata := . }}
              {{ $label_name := (split "::" $lname)._0 }}
              {{ $label_value := (split "::" $lname)._1 }}
              {{/* dictionary that will contain all info needed to generate this
              iteration of the daemonset. */}}
              {{- $_ := set $context.Values "__current_label" dict }}

              {{/* set daemonset name */}}
              {{- $_ := set $context.Values.__current_label "name" $label_name }}

              {{/* set daemonset metadata annotation */}}
              {{- $_ := set $context.Values.__current_label "daemonset_override" $lname  }}

              {{/* apply overrides */}}


              {{- $override_root_copy := $ldata.values }}
              {{/* Deep copy to prevent https://storyboard.openstack.org/#!/story/2005936 */}}
              {{- $root_copy := omit ($context.Values | toYaml | fromYaml) "overrides" }}
              {{- $merged_dict := mergeOverwrite $root_copy $override_root_copy }}

              {{- $root_conf_copy2 := dict "values" $merged_dict }}
              {{- $context_values := omit (omit ($context.Values | toYaml | fromYaml) "values") "__daemonset_list" }}
              {{- $root_conf_copy3 := mergeOverwrite $context_values $root_conf_copy2.values }}
              {{- $root_conf_copy4 := dict "Values" $root_conf_copy3 }}
              {{- $_ := set $context.Values.__current_label "nodeData" $root_conf_copy4 }}


              {{/* Schedule to the provided label value(s) */}}
              {{- $label_dict := dict "key" $label_name  }}
              {{- $_ := set $label_dict "values" (list $label_value) }}
              {{- $_ := set $label_dict "operator" "In" }}
              {{- $list_aggregate := list $label_dict }}
              {{- $_ := set $context.Values.__current_label "matchExpressions" $list_aggregate }}

              {{/* Do not schedule to other specified labels, with higher
              precedence as the list position increases. Last defined label
              is highest priority. */}}
              {{- $other_labels :=  omit $context.Values.__label_dict $lname }}
              {{- range $lname2, $ldata2 := $other_labels }}
                {{ $label_name2 := (split "::" $lname2)._0 }}
                {{ $label_value2 := (split "::" $lname2)._1 }}

                {{- $label_dict := dict "key" $label_name2  }}
                {{- $_ := set $label_dict "values" (list $label_value2) }}
                {{- $_ := set $label_dict "operator" "NotIn" }}

                {{- $list_aggregate := append $context.Values.__current_label.matchExpressions $label_dict }}
                {{- $_ := set $context.Values.__current_label "matchExpressions" $list_aggregate }}
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
            {{- range $lname, $ldata := . }}
              {{ $label_name := (split "::" $lname)._0 }}
              {{ $label_value := (split "::" $lname)._1 }}

              {{- $default_dict := dict "key" $label_name  }}
              {{- $_ := set $default_dict "values" (list $label_value) }}
              {{- $_ := set $default_dict "operator" "NotIn" }}

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
  {{- if $default_enabled }}
    {{- $list_aggregate := append $context.Values.__daemonset_list $context.Values.__default }}
    {{- $_ := set $context.Values "__daemonset_list" $list_aggregate }}
  {{- end }}

  {{- range $current_dict := $context.Values.__daemonset_list }}

    {{- $context_novalues := omit $context "Values" }}
    {{- $merged_dict := mergeOverwrite $context_novalues $current_dict.nodeData }}
    {{- $_ := set $current_dict "nodeData" $merged_dict }}
    {{/* Deep copy original daemonset_yaml */}}
    {{- $daemonset_yaml := list $daemonset $configmap_name $serviceAccountName $merged_dict | include $daemonSetTemplateName | toString | fromYaml }}
    {{- $_ := set $context.Values "__daemonset_yaml" ($daemonset_yaml | toYaml | fromYaml) }}

    {{/* Use the following name format $daemonset_root_name + sha256summ($current_dict.matchExpressions)
    as labels might be too long and contain wrong characters like / */}}
    {{- $_ := set $current_dict "dns_1123_name" dict }}
    {{- $name_format := "" }}
    {{- if eq $current_dict.name "default" }}
       {{- $name_format = (printf "%s-%s" $daemonset_root_name "default") | replace "_" "-" }}
    {{- else }}
       {{- $name_format = (printf "%s-%s" $daemonset_root_name ($current_dict.matchExpressions | quote | sha256sum | trunc 16)) | replace "_" "-" }}
    {{- end }}
    {{- $_ := set $current_dict "dns_1123_name" $name_format }}

    {{/* set daemonset metadata name */}}
    {{- if not $context.Values.__daemonset_yaml.metadata }}{{- $_ := set $context.Values.__daemonset_yaml "metadata" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.metadata.name }}{{- $_ := set $context.Values.__daemonset_yaml.metadata "name" dict }}{{- end }}
    {{- $_ := set $context.Values.__daemonset_yaml.metadata "name" $current_dict.dns_1123_name }}

    {{/* cross-reference configmap name to container volume definitions */}}
    {{- $_ := set $context.Values "__volume_list" list }}
    {{- range $current_volume := $context.Values.__daemonset_yaml.spec.template.spec.volumes }}
      {{- $_ := set $context.Values "__volume" $current_volume }}
      {{- if hasKey $context.Values.__volume "secret" }}
        {{- if eq $context.Values.__volume.secret.secretName $configmap_name }}
          {{- $_ := set $context.Values.__volume.secret "secretName" (printf "%s-etc" $current_dict.dns_1123_name) }}
        {{- end }}
      {{- end }}
      {{- if hasKey $context.Values.__volume "configMap" }}
        {{- if eq $context.Values.__volume.configMap.name $configbin_name }}
          {{- $_ := set $context.Values.__volume.configMap "name" (printf "%s-bin" $current_dict.dns_1123_name) }}
        {{- end }}
      {{- end }}
      {{- $updated_list := append $context.Values.__volume_list $context.Values.__volume }}
      {{- $_ := set $context.Values "__volume_list" $updated_list }}
    {{- end }}
    {{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec "volumes" $context.Values.__volume_list }}


    {{/* populate scheduling restrictions */}}
    {{- if hasKey $current_dict "matchExpressions" }}
      {{- $length := len $current_dict.matchExpressions }}
      {{- if gt $length 0 }}
        {{- if not $context.Values.__daemonset_yaml.spec.template.spec }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template "spec" dict }}{{- end }}
        {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec "affinity" dict }}{{- end }}
        {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity "nodeAffinity" dict }}{{- end }}
        {{- if not $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity "requiredDuringSchedulingIgnoredDuringExecution" dict }}{{- end }}

        {{- $expressions_modified := list }}
        {{- if hasKey $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution "nodeSelectorTerms" }}
          {{- range $orig_expression := $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms }}
            {{- $match_expressions_modified := list }}
            {{- $match_expressions_modified = concat $match_expressions_modified $current_dict.matchExpressions }}
            {{- if hasKey $orig_expression "matchExpressions" }}
              {{- $match_expressions_modified = concat $match_expressions_modified $orig_expression.matchExpressions }}
              {{- $expressions_modified = append $expressions_modified (dict "matchExpressions" $match_expressions_modified) }}
            {{- end }}
          {{- end }}
        {{- else }}
          {{- $expressions_modified = (list (dict "matchExpressions" $current_dict.matchExpressions)) }}
        {{- end }}
        {{- $_ := set $context.Values.__daemonset_yaml.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution "nodeSelectorTerms" $expressions_modified }}
      {{- end }}
    {{- end }}

    {{/* input value hash for current set of values overrides */}}
    {{- if not $context.Values.__daemonset_yaml.spec }}{{- $_ := set $context.Values.__daemonset_yaml "spec" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template }}{{- $_ := set $context.Values.__daemonset_yaml.spec "template" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template.metadata }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template "metadata" dict }}{{- end }}
    {{- if not $context.Values.__daemonset_yaml.spec.template.metadata.annotations }}{{- $_ := set $context.Values.__daemonset_yaml.spec.template.metadata "annotations" dict }}{{- end }}
    {{- $cmap := list (printf "%s-etc" $current_dict.dns_1123_name) $current_dict.nodeData | include $configmap_include }}
    {{- $cmap_bin := list (printf "%s-bin" $current_dict.dns_1123_name) $current_dict.nodeData | include $configbin_include }}
    {{- $values_cmap_hash := $cmap | quote | sha256sum }}
    {{- $values_cmap_bin_hash := $cmap_bin | quote | sha256sum }}
    {{- $_ := set $context.Values.__daemonset_yaml.spec.template.metadata.annotations "configmap-etc-hash" $values_cmap_hash }}
    {{- $_ := set $context.Values.__daemonset_yaml.spec.template.metadata.annotations "configmap-bin-hash" $values_cmap_bin_hash }}

    {{/* Do not set override for default daemonset */}}
    {{- if $current_dict.daemonset_override }}
        {{- $_ := set $context.Values.__daemonset_yaml.metadata.annotations "daemonset_override" $current_dict.daemonset_override }}
    {{- end }}

{{/* generate configmap */}}
---
{{ $cmap }}
    {{/* generate <service>-bin yaml */}}
---
{{ $cmap_bin }}
    {{/* generate daemonset yaml */}}
---
{{ $context.Values.__daemonset_yaml | toYaml }}
  {{- end }}
{{- end }}
