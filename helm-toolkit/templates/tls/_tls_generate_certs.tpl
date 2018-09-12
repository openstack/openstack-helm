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
  Produces a certificate from a certificate authority.
values: |
  test:
    hosts:
      names:
        - barbican.openstackhelm.example
        - barbican.openstack.svc.cluster.local
      ips:
        - 127.0.0.1
        - 192.168.0.1
    life: 3
    ca:
      crt: |
        <CA CRT>
      key: |
        <CA PRIVATE KEY>
usage: |
  {{ include "helm-toolkit.utils.tls_generate_certs" (dict "params" .Values.test) }}
return: |
  ca: |
    <CA CRT>
  crt: |
    <CRT>
  exp: 2018-09-01T10:56:07.895392915-00:00
  key: |
    <CRT PRIVATE KEY>
*/}}

{{- define "helm-toolkit.utils.tls_generate_certs" -}}
{{- $params := index . "params" -}}
{{- $local := dict -}}

{{- $_hosts := $params.hosts.names | default list }}
{{- if kindIs "string" $params.hosts.names }}
{{- $_ := set $local "certHosts" (list $params.hosts.names) }}
{{- else }}
{{- $_ := set $local "certHosts" $_hosts }}
{{- end }}

{{- $_ips := $params.hosts.ips | default list }}
{{- if kindIs "string" $params.hosts.ips }}
{{- $_ := set $local "certIps" (list $params.hosts.ips) }}
{{- else }}
{{- $_ := set $local "certIps" $_ips }}
{{- end }}

{{- $ca := buildCustomCert ($params.ca.crt | b64enc ) ($params.ca.key | b64enc ) }}
{{- $expDate := date_in_zone "2006-01-02T15:04:05Z07:00" ( date_modify (printf "+%sh" (mul $params.life 24 |toString)) now ) "UTC" }}
{{- $rawCert := genSignedCert (first $local.certHosts) ($local.certIps) $local.certHosts (int $params.life) $ca }}
{{- $certificate := dict "crt" $rawCert.Cert "key" $rawCert.Key "ca" $params.ca.crt "exp" $expDate "" }}
{{- $certificate | toYaml }}
{{- end -}}
