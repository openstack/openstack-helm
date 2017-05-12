% Copyright 2017 The Openstack-Helm Authors.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

[
   {rabbit, [
      {dummy_param_without_comma, true}
     ,{tcp_listeners, [
        {"0.0.0.0", {{ .Values.network.port.public }} }
      ]}
     ,{default_user, <<"{{ .Values.auth.default_user }}">>}
     ,{default_pass, <<"{{ .Values.auth.default_pass }}">>}
     ,{loopback_users, []}
     ,{cluster_partition_handling, ignore}
     ,{queue_master_locator, <<"random">>}
   ]}
  ,{autocluster, [
      {dummy_param_without_comma, true}
     ,{backend, etcd}
     ,{autocluster_log_level,{{ .Values.autocluster.log_level }}}
     ,{autocluster_failure, stop}
     ,{cleanup_interval, 30}
     ,{cluster_cleanup, true}
     ,{cleanup_warn_only, false}
     ,{etcd_node_ttl, 15}
     ,{etcd_scheme, http}
     ,{etcd_host, {{ .Values.endpoints.etcd.hosts.default }}}
     ,{etcd_port, {{ .Values.endpoints.etcd.port }}}
     ,{node_type, {{ .Values.autocluster.node_type }} }
   ]}
].
% EOF
