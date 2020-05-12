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
  Resolves endpoint string suitible for use with oslo.messaging transport url
  See: https://docs.openstack.org/oslo.messaging/latest/reference/transport.html#oslo_messaging.TransportURL
examples:
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_messaging:
          auth:
            cinder:
              username: cinder
              password: password
          statefulset:
            replicas: 2
            name: rabbitmq-rabbitmq
          hosts:
            default: rabbitmq
          host_fqdn_override:
            default: null
          path: /cinder
          scheme: rabbit
          port:
            amqp:
              default: 5672
    usage: |
      {{ tuple "oslo_messaging" "internal" "cinder" "amqp" . | include "helm-toolkit.endpoints.authenticated_transport_endpoint_uri_lookup" }}
    return: |
      rabbit://cinder:password@rabbitmq-rabbitmq-0.rabbitmq.default.svc.cluster.local:5672,cinder:password@rabbitmq-rabbitmq-1.rabbitmq.default.svc.cluster.local:5672/cinder
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_messaging:
          auth:
            cinder:
              username: cinder
              password: password
          statefulset: null
          hosts:
            default: rabbitmq
          host_fqdn_override:
            default: null
          path: /cinder
          scheme: rabbit
          port:
            amqp:
              default: 5672
    usage: |
      {{ tuple "oslo_messaging" "internal" "cinder" "amqp" . | include "helm-toolkit.endpoints.authenticated_transport_endpoint_uri_lookup" }}
    return: |
      rabbit://cinder:password@rabbitmq.default.svc.cluster.local:5672/cinder
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_messaging:
          auth:
            cinder:
              username: cinder
              password: password
          statefulset:
            replicas: 2
            name: rabbitmq-rabbitmq
          hosts:
            default: rabbitmq
          host_fqdn_override:
            default: rabbitmq.openstackhelm.org
          path: /cinder
          scheme: rabbit
          port:
            amqp:
              default: 5672
    usage: |
      {{ tuple "oslo_messaging" "internal" "cinder" "amqp" . | include "helm-toolkit.endpoints.authenticated_transport_endpoint_uri_lookup" }}
    return: |
      rabbit://cinder:password@rabbitmq.openstackhelm.org:5672/cinder
*/}}

{{- define "helm-toolkit.endpoints.authenticated_transport_endpoint_uri_lookup" -}}
{{-   $type := index . 0 -}}
{{-   $endpoint := index . 1 -}}
{{-   $userclass := index . 2 -}}
{{-   $port := index . 3 -}}
{{-   $context := index . 4 -}}
{{-   $endpointScheme := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
{{-   $userMap := index $context.Values.endpoints ( $type | replace "-" "_" ) "auth" $userclass }}
{{-   $ssMap := index $context.Values.endpoints ( $type | replace "-" "_" ) "statefulset" | default false}}
{{-   $hostFqdnOverride := index $context.Values.endpoints ( $type | replace "-" "_" ) "host_fqdn_override" }}
{{-   $endpointUser := index $userMap "username" }}
{{-   $endpointPass := index $userMap "password" }}
{{-   $endpointHostSuffix := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{-   $endpointPort := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{-   $local := dict "endpointCredsAndHosts" list -}}
{{-   if not (or (index $hostFqdnOverride $endpoint | default ( index $hostFqdnOverride "default" ) ) ( not $ssMap ) ) }}
{{-     $endpointHostPrefix := $ssMap.name }}
{{-     range $podInt := until ( atoi (print $ssMap.replicas ) ) }}
{{-       $endpointCredAndHost := printf "%s:%s@%s-%d.%s:%s" $endpointUser $endpointPass $endpointHostPrefix $podInt $endpointHostSuffix $endpointPort }}
{{-       $_ := set $local "endpointCredsAndHosts" ( append $local.endpointCredsAndHosts $endpointCredAndHost ) }}
{{-     end }}
{{-   else }}
{{-     $endpointHost := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{-     $endpointCredAndHost := printf "%s:%s@%s:%s" $endpointUser $endpointPass $endpointHost $endpointPort }}
{{-     $_ := set $local "endpointCredsAndHosts" ( append $local.endpointCredsAndHosts $endpointCredAndHost ) }}
{{-   end }}
{{-   $endpointCredsAndHosts := include "helm-toolkit.utils.joinListWithComma" $local.endpointCredsAndHosts }}
{{-   $endpointPath := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_path_lookup" }}
{{-   printf "%s://%s%s" $endpointScheme $endpointCredsAndHosts $endpointPath }}
{{- end -}}
