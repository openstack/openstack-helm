#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Lint and package chart
make fluentd
: ${OSH_INFRA_EXTRA_HELM_ARGS_FLUENTD:="$(./tools/deployment/common/get-values-overrides.sh fluentd)"}

tee /tmp/fluentd.yaml << EOF
pod:
  env:
    fluentd:
      vars:
        MY_TEST_VAR: FOO
      secrets:
        MY_TEST_SECRET: BAR
conf:
  fluentd:
    conf:
      # These fields are rendered as helm templates
      input: |
        <source>
          @type prometheus
          port {{ tuple "fluentd" "internal" "metrics" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
        </source>

        <source>
          @type prometheus_monitor
        </source>

        <source>
          @type prometheus_output_monitor
        </source>

        <source>
          @type prometheus_tail_monitor
        </source>

        <source>
          bind 0.0.0.0
          port "#{ENV['FLUENTD_PORT']}"
          @type forward
        </source>

        <source>
          <parse>
            time_format %Y-%m-%dT%H:%M:%S.%NZ
            @type json
          </parse>
          path /var/log/containers/*.log
          read_from_head true
          tag kubernetes.*
          @type tail
        </source>

        <source>
          @type tail
          tag libvirt.*
          path /var/log/libvirt/**.log
          read_from_head true
          <parse>
            @type none
          </parse>
        </source>

        <source>
          @type systemd
          tag auth
          path /var/log/journal
          matches [{ "SYSLOG_FACILITY":"10" }]
          read_from_head true

          <entry>
            fields_strip_underscores true
            fields_lowercase true
          </entry>
        </source>

        <source>
          @type systemd
          tag journal.*
          path /var/log/journal
          matches [{ "_SYSTEMD_UNIT": "docker.service" }]
          read_from_head true

          <entry>
            fields_strip_underscores true
            fields_lowercase true
          </entry>
        </source>

        <source>
          @type systemd
          tag journal.*
          path /var/log/journal
          matches [{ "_SYSTEMD_UNIT": "kubelet.service" }]
          read_from_head true

          <entry>
            fields_strip_underscores true
            fields_lowercase true
          </entry>
        </source>

        <source>
          @type systemd
          tag kernel
          path /var/log/journal
          matches [{ "_TRANSPORT": "kernel" }]
          read_from_head true

          <entry>
            fields_strip_underscores true
            fields_lowercase true
          </entry>
        </source>

        <match **>
          @type relabel
          @label @filter
        </match>

      filter: |
        <label @filter>
          <filter kubernetes.**>
            @type kubernetes_metadata
          </filter>

          <filter libvirt.**>
            @type record_transformer
            <record>
              hostname "#{ENV['NODE_NAME']}"
              fluentd_pod "#{ENV['POD_NAME']}"
            </record>
          </filter>
          <match **>
            @type relabel
            @label @output
          </match>
        </label>
      output: |
        <label @output>
          <match fluent.**>
            @type null
          </match>

          <match **>
            <buffer>
              chunk_limit_size 512K
              flush_interval 5s
              flush_thread_count 8
              queue_limit_length 32
              retry_forever false
              retry_max_interval 30
            </buffer>
            host "#{ENV['ELASTICSEARCH_HOST']}"
            reload_connections false
            reconnect_on_error true
            reload_on_failure true
            include_tag_key true
            logstash_format true
            password "#{ENV['ELASTICSEARCH_PASSWORD']}"
            port "#{ENV['ELASTICSEARCH_PORT']}"
            @type elasticsearch
            user "#{ENV['ELASTICSEARCH_USERNAME']}"
          </match>
        </label>
EOF
helm upgrade --install fluentd ./fluentd \
    --namespace=osh-infra \
    --values=/tmp/fluentd.yaml \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_FLUENTD}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
