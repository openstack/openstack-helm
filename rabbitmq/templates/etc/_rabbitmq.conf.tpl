# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

listeners.tcp.other_ip   = 0.0.0.0:{{ .Values.network.port.public }}

default_user = {{ .Values.auth.default_user }}
default_pass = {{ .Values.auth.default_pass }}

loopback_users.guest = false

autocluster.peer_discovery_backend = rabbit_peer_discovery_dns
autocluster.dns.hostname           = rabbitmq-discovery.{{ .Release.Namespace }}.svc.cluster.local
autocluster.node_type = disc

cluster_keepalive_interval = 30000
cluster_partition_handling = ignore

queue_master_locator = random
