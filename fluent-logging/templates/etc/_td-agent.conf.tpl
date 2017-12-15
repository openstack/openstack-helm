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

<source>
  @type forward
  port {{ tuple "aggregator" "internal" "service" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
  bind 0.0.0.0
</source>

<filter kube.**>
  type kubernetes_metadata
</filter>

<match ** >
{{ if .Values.conf.fluentd.kafka.enabled }}
  @type copy

  <store>
    @type kafka_buffered

    # list of seed brokers
    brokers {{ tuple "kafka" "public"  . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}:{{ tuple "kafka" "public" "service" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}

    # buffer settings
    buffer_type file
    buffer_path /var/log/td-agent/buffer/td
    flush_interval {{ .Values.conf.fluentd.kafka.flush_interval }}

    # topic settings
    default_topic  {{ .Values.conf.fluentd.kafka.topic_name }}

    # data type settings
    output_data_type {{ .Values.conf.fluentd.kafka.output_data_type }}
    compression_codec gzip

    # producer settings
    max_send_retries 1
    required_acks -1
  </store>

  <store>
{{- end }}
    @type elasticsearch
    include_tag_key true
    host {{ tuple "elasticsearch" "internal"  . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
    port {{ tuple "elasticsearch" "internal"  "client" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
    logstash_format {{ .Values.conf.fluentd.elasticsearch.logstash }}

    # Set the chunk limit the same as for fluentd-gcp.
    buffer_chunk_limit {{ .Values.conf.fluentd.elasticsearch.buffer_chunk_limit }}

    # Cap buffer memory usage to 2MiB/chunk * 32 chunks = 64 MiB
    buffer_queue_limit {{ .Values.conf.fluentd.elasticsearch.buffer_queue_limit }}

    # Flush buffer every 30s to write to Elasticsearch
    flush_interval {{ .Values.conf.fluentd.elasticsearch.flush_interval }}

    # Never wait longer than 5 minutes between retries.
    max_retry_wait {{ .Values.conf.fluentd.elasticsearch.max_retry_wait }}

{{- if .Values.conf.fluentd.elasticsearch.disable_retry_limit }}

    # Disable the limit on the number of retries (retry forever).
    disable_retry_limit
{{- end }}

    # Use multiple threads for processing.
    num_threads {{ .Values.conf.fluentd.elasticsearch.num_threads }}
{{ if .Values.conf.fluentd.kafka.enabled }}
  </store>
{{- end }}

</match>
