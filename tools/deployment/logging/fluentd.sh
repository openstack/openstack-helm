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

: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_INFRA_EXTRA_HELM_ARGS_FLUENTD:="$(helm osh get-values-overrides -p ${OSH_INFRA_PATH} -c fluentd ${FEATURES})"}

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
          @type tail
          @id in_tail_container_logs
          path "/var/log/containers/*.log"
          pos_file "/var/log/fluentd-containers.log.pos"
          tag kubernetes.*
          read_from_head true
          emit_unmatched_lines true
          <parse>
            @type "multi_format"
            <pattern>
              format json
              time_key "time"
              time_type string
              time_format "%Y-%m-%dT%H:%M:%S.%NZ"
              keep_time_key false
            </pattern>
            <pattern>
              format regexp
              expression /^(?<time>.+) (?<stream>stdout|stderr)( (.))? (?<log>.*)$/
              time_format "%Y-%m-%dT%H:%M:%S.%NZ"
              keep_time_key false
            </pattern>
          </parse>
        </source>

        <source>
          @type tail
          tag libvirt.*
          path /var/log/libvirt/**.log
          pos_file "/var/log/fluentd-libvirt.log.pos"
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

          <storage>
            @type local
            path /var/log/fluentd-systemd-auth.json
          </storage>

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

          <storage>
            @type local
            path /var/log/fluentd-systemd-docker.json
          </storage>

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

          <storage>
            @type local
            path /var/log/fluentd-systemd-kubelet.json
          </storage>

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

          <storage>
            @type local
            path /var/log/fluentd-systemd-kernel.json
          </storage>

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
        <label @FLUENT_LOG>
          <match **>
            @type null
            @id ignore_fluent_logs
          </match>
        </label>

        <label @filter>
          <match kubernetes.var.log.containers.fluentd**>
            @type relabel
            @label @FLUENT_LOG
          </match>

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
              chunk_limit_size 2M
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
helm upgrade --install fluentd ${OSH_INFRA_HELM_REPO}/fluentd \
    --namespace=osh-infra \
    --values=/tmp/fluentd.yaml \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_FLUENTD}

#NOTE: Wait for deploy
helm osh wait-for-pods osh-infra
