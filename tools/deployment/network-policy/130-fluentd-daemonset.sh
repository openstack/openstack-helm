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

tee /tmp/fluentd-daemonset.yaml << EOF
endpoints:
  fluentd:
    hosts:
      default: fluentd-daemonset
  prometheus_fluentd_exporter:
    hosts:
      default: fluentd-daemonset-exporter
monitoring:
  prometheus:
    enabled: true
pod:
  env:
    fluentd:
      vars:
        MY_TEST_VAR: FOO
      secrets:
        MY_TEST_SECRET: BAR
  security_context:
    fluentd:
      pod:
        runAsUser: 0
deployment:
  type: DaemonSet
conf:
  fluentd:
    template: |
      <source>
        bind 0.0.0.0
        port 24220
        @type monitor_agent
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
        tag ceph.*
        path /var/log/ceph/*/*.log
        read_from_head true
        <parse>
          @type none
        </parse>
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
        @type tail
        tag kernel
        path /var/log/kern.log
        read_from_head true
        <parse>
          @type none
        </parse>
      </source>

      <source>
        @type tail
        tag auth
        path /var/log/auth.log
        read_from_head true
        <parse>
          @type none
        </parse>
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

      <filter kubernetes.**>
        @type kubernetes_metadata
      </filter>

      <filter ceph.**>
        @type record_transformer
        <record>
          hostname "#{ENV['NODE_NAME']}"
          fluentd_pod "#{ENV['POD_NAME']}"
        </record>
      </filter>

      <filter libvirt.**>
        @type record_transformer
        <record>
          hostname "#{ENV['NODE_NAME']}"
          fluentd_pod "#{ENV['POD_NAME']}"
        </record>
      </filter>

      <filter kernel>
        @type record_transformer
        <record>
          hostname "#{ENV['NODE_NAME']}"
          fluentd_pod "#{ENV['POD_NAME']}"
        </record>
      </filter>

      <filter auth>
        @type record_transformer
        <record>
          hostname "#{ENV['NODE_NAME']}"
          fluentd_pod "#{ENV['POD_NAME']}"
        </record>
      </filter>

      <match fluent.**>
        @type null
      </match>

      <match libvirt.**>
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
        logstash_prefix libvirt
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match ceph.**>
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
        logstash_prefix ceph
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match kernel>
        <buffer>
          chunk_limit_size 512K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 32
          retry_forever false
          disable_chunk_backup true
        </buffer>
        host "#{ENV['ELASTICSEARCH_HOST']}"
        reload_connections false
        reconnect_on_error true
        reload_on_failure true
        include_tag_key true
        logstash_format true
        logstash_prefix kernel
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match auth>
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
        logstash_prefix auth
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match journal.**>
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
        logstash_prefix journal
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
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
EOF
helm upgrade --install fluentd-daemonset ./fluentd \
    --namespace=osh-infra \
    --values=/tmp/fluentd-daemonset.yaml \
    --set manifests.network_policy=true \
    --set manifests.monitoring.prometheus.network_policy_exporter=true

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
