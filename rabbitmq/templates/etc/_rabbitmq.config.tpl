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
   ]}
].
% EOF
