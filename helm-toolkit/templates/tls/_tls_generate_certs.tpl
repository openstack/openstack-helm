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
  Produces a certificate from a certificate authority. If the "encode" parameter
  is true, base64 encode the values for inclusion in a Kubernetes secret.
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
    # Use ca.crt and ca.key to build a customized ca, if they are provided.
    # Use hosts.names[0] and life to auto-generate a ca, if ca is not provided.
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
{{- $encode := index . "encode" | default false -}}
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

{{- if hasKey $params "ca" }}
{{- if and (hasKey $params.ca "crt") (hasKey $params.ca "key") }}
{{- $ca := buildCustomCert ($params.ca.crt | b64enc ) ($params.ca.key | b64enc ) }}
{{- $_ := set $local "ca" $ca }}
{{- end }}
{{- else }}
{{- $ca := genCA (first $local.certHosts) (int $params.life) }}
{{- $_ := set $local "ca" $ca }}
{{- end }}

{{- $expDate := date_in_zone "2006-01-02T15:04:05Z07:00" ( date_modify (printf "+%sh" (mul $params.life 24 |toString)) now ) "UTC" }}
{{- $rawCert := genSignedCert (first $local.certHosts) ($local.certIps) ($local.certHosts) (int $params.life) $local.ca }}
{{- $certificate := dict -}}
{{- if $encode -}}
{{- $_ := b64enc $rawCert.Cert | set $certificate "crt" -}}
{{- $_ := b64enc $rawCert.Key | set $certificate "key" -}}
{{- $_ := b64enc $local.ca.Cert | set $certificate "ca" -}}
{{- $_ := b64enc $local.ca.Key | set $certificate "caKey" -}}
{{- $_ := b64enc $expDate | set $certificate "exp" -}}
{{- else -}}
{{- $_ := set $certificate "crt" $rawCert.Cert -}}
{{- $_ := set $certificate "key" $rawCert.Key -}}
{{- $_ := set $certificate "ca" $local.ca.Cert -}}
{{- $_ := set $certificate "caKey" $local.ca.Key -}}
{{- $_ := set $certificate "exp" $expDate -}}
{{- end -}}
{{- $certificate | toYaml }}
{{- end -}}
