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

tee /tmp/fluentd-daemonset.yaml <<EOF
deployment:
  type: DaemonSet
pod:
  security_context:
    fluentd:
      pod:
        runAsUser: 0
  mandatory_access_control:
    type: apparmor
    fluentd:
      fluentd: runtime/default
conf:
  fluentd:
    template: |
      <source>
        bind 0.0.0.0
        port 24220
        @type monitor_agent
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

      <filter kubernetes.**>
        @type kubernetes_metadata
      </filter>

      <source>
        bind 0.0.0.0
        port "#{ENV['FLUENTD_PORT']}"
        @type forward
      </source>

      <match fluent.**>
        @type null
      </match>

      <match libvirt>
        <buffer>
          chunk_limit_size 500K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 16
          retry_forever false
          retry_max_interval 30
        </buffer>
        host "#{ENV['ELASTICSEARCH_HOST']}"
        include_tag_key true
        logstash_format true
        logstash_prefix libvirt
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match qemu>
        <buffer>
          chunk_limit_size 500K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 16
          retry_forever false
          retry_max_interval 30
        </buffer>
        host "#{ENV['ELASTICSEARCH_HOST']}"
        include_tag_key true
        logstash_format true
        logstash_prefix qemu
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match journal.**>
        <buffer>
          chunk_limit_size 500K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 16
          retry_forever false
          retry_max_interval 30
        </buffer>
        host "#{ENV['ELASTICSEARCH_HOST']}"
        include_tag_key true
        logstash_format true
        logstash_prefix journal
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match kernel>
        <buffer>
          chunk_limit_size 500K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 16
          retry_forever false
          retry_max_interval 30
        </buffer>
        host "#{ENV['ELASTICSEARCH_HOST']}"
        include_tag_key true
        logstash_format true
        logstash_prefix kernel
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>

      <match **>
        <buffer>
          chunk_limit_size 500K
          flush_interval 5s
          flush_thread_count 8
          queue_limit_length 16
          retry_forever false
          retry_max_interval 30
        </buffer>
        flush_interval 15s
        host "#{ENV['ELASTICSEARCH_HOST']}"
        include_tag_key true
        logstash_format true
        password "#{ENV['ELASTICSEARCH_PASSWORD']}"
        port "#{ENV['ELASTICSEARCH_PORT']}"
        @type elasticsearch
        type_name fluent
        user "#{ENV['ELASTICSEARCH_USERNAME']}"
      </match>
EOF

#NOTE: Deploy command
helm upgrade --install fluentd-daemonset ./fluentd \
    --namespace=osh-infra \
    --values=/tmp/fluentd-daemonset.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=fluentd,release_group=fluentd-daemonset,component=test --namespace=osh-infra --ignore-not-found
helm test fluentd-daemonset --namespace osh-infra
