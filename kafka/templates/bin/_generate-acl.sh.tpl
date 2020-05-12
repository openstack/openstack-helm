#!/bin/sh
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */}}

{{- $envAll := . }}

{{- if .Values.monitoring.prometheus.enabled }}
{{- $credentials := .Values.endpoints.kafka_exporter.auth }}
/opt/kafka/bin/kafka-acls.sh \
    --authorizer kafka.security.auth.SimpleAclAuthorizer \
    --authorizer-properties zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT \
    --add \
    --allow-principal User:{{ $credentials.username }} \
    --operation DESCRIBE \
    --topic "*" \
    --group "*" \
    --cluster
{{ end }}

{{ $producers := .Values.conf.kafka.jaas.producers }}
{{- range $producer, $properties := $producers }}
/opt/kafka/bin/kafka-acls.sh \
    --authorizer kafka.security.auth.SimpleAclAuthorizer \
    --authorizer-properties zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT \
    --add \
    --allow-principal User:{{ $properties.username }} \
    --producer \
    --topic {{ $properties.topic | quote }}
{{- end }}

{{ $consumers := .Values.conf.kafka.jaas.consumers }}
{{- range $consumer, $properties := $consumers }}
/opt/kafka/bin/kafka-acls.sh \
    --authorizer kafka.security.auth.SimpleAclAuthorizer \
    --authorizer-properties zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT \
    --add \
    --allow-principal User:{{ $properties.username }} \
    --consumer \
    --topic {{ $properties.topic | quote }} \
    --group {{ $properties.group | quote }}
{{- end }}
