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

cluster:
  name: {{ .Values.conf.elasticsearch.cluster.name }}

node:
  master: ${NODE_MASTER}
  data: ${NODE_DATA}
  name: ${NODE_NAME}
  max_local_storage_nodes: {{ .Values.pod.replicas.data }}

network.host: {{ .Values.conf.elasticsearch.network.host }}

path:
  data: {{ .Values.conf.elasticsearch.path.data }}
  logs: {{ .Values.conf.elasticsearch.path.logs }}

bootstrap:
  memory_lock: {{ .Values.conf.elasticsearch.bootstrap.memory_lock }}

http:
  enabled: ${HTTP_ENABLE}
  compression: true

discovery:
  zen:
    ping.unicast.hosts: ${DISCOVERY_SERVICE}
    minimum_master_nodes: {{ .Values.conf.elasticsearch.zen.min_masters }}
