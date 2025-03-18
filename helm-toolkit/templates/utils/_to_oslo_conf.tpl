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
  Returns OSLO.conf formatted output from yaml input
values: |
  conf:
    keystone:
      DEFAULT: # Keys at this level are used for section headings
        max_token_size: 255
      oslo_messaging_notifications:
        driver: # An example of a multistring option's syntax
          type: multistring
          values:
            - messagingv2
            - log
      oslo_messaging_notifications_stein:
        driver: # An example of a csv option's syntax
          type: csv
          values:
            - messagingv2
            - log
      security_compliance:
        password_expires_ignore_user_ids:
        # Values in a list will be converted to a comma separated key
          - "123"
          - "456"
usage: |
  {{ include "helm-toolkit.utils.to_oslo_conf" .Values.conf.keystone }}
return: |
  [DEFAULT]
  max_token_size = 255
  [oslo_messaging_notifications]
  driver = messagingv2
  driver = log
  [oslo_messaging_notifications_stein]
  driver = messagingv2,log
  [security_compliance]
  password_expires_ignore_user_ids = 123,456
*/}}

{{- define "helm-toolkit.utils.to_oslo_conf" -}}
{{- range $section, $values := . -}}
{{- if kindIs "map" $values -}}
[{{ $section }}]
{{ range $key, $value := $values -}}
{{- if kindIs "slice" $value -}}
{{ $key }} = {{ include "helm-toolkit.utils.joinListWithComma" $value }}
{{ else if kindIs "map" $value -}}
{{- if eq $value.type "multistring" }}
{{- range $k, $multistringValue := $value.values -}}
{{ $key }} = {{ $multistringValue }}
{{ end -}}
{{ else if eq $value.type "csv" -}}
{{ $key }} = {{ include "helm-toolkit.utils.joinListWithComma" $value.values }}
{{ end -}}
{{- else -}}
{{ $key }} = {{ $value }}
{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
