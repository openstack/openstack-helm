[global]
fsid = {{ uuidv4 | default .Values.conf.ceph.config.global.uuid | quote }}
cephx = {{ .Values.conf.ceph.config.global.cephx | default "true" | quote }}
cephx_require_signatures = {{ .Values.conf.ceph.config.global.cephx_require_signatures | default "false" | quote }}
cephx_cluster_require_signatures = {{ .Values.conf.ceph.config.global.cephx_cluster_require_signatures | default "true" | quote }}
cephx_service_require_signatures = {{ .Values.conf.ceph.config.global.cephx_service_require_signatures | default "false" | quote }}

# auth
max_open_files = {{ .Values.conf.ceph.config.global.max_open_files | default "131072" | quote }}

osd_pool_default_pg_num = {{ .Values.conf.ceph.config.global.osd_pool_default_pg_num | default "128" | quote }}
osd_pool_default_pgp_num = {{ .Values.conf.ceph.config.global.osd_pool_default_pgp_num | default "128" | quote }}
osd_pool_default_size = {{ .Values.conf.ceph.config.global.osd_pool_default_size | default "3" | quote }}
osd_pool_default_min_size = {{ .Values.conf.ceph.config.global.osd_pool_default_min_size | default "1" | quote }}

mon_osd_full_ratio = {{ .Values.conf.ceph.config.global.mon_osd_full_ratio | default ".95" | quote }}
mon_osd_nearfull_ratio = {{ .Values.conf.ceph.config.global.mon_osd_nearfull_ratio | default ".85" | quote }}
mon_host = {{ .Values.conf.ceph.config.global.mon_host | quote }}

rgw_thread_pool_size = {{ .Values.conf.ceph.config.global.rgw_thread_pool_size | default "1024" | quote }}
rgw_num_rados_handles = {{ .Values.conf.ceph.config.global.rgw_num_rados_handles | default "100" | quote }}

[mon]
mon_osd_down_out_interval = {{ .Values.conf.ceph.config.mon.mon_osd_down_out_interval | default "600" | quote }}
mon_osd_min_down_reporters = {{ .Values.conf.ceph.config.mon.mon_osd_min_down_reporters | default "4" | quote }}
mon_clock_drift_allowed = {{ .Values.conf.ceph.config.mon.mon_clock_drift_allowed | default "0.15" | quote }}
mon_clock_drift_warn_backoff = {{ .Values.conf.ceph.config.mon.mon_clock_drift_warn_backoff | default "30" | quote }}
mon_osd_report_timeout = {{ .Values.conf.ceph.config.mon.mon_osd_report_timeout | default "300" | quote }}

[osd]
# network
cluster_network = {{ .Values.network.cluster | default "192.168.0.0/16" | quote }}
public_network = {{ .Values.network.public | default "192.168.0.0/16" | quote }}
osd_mon_heartbeat_interval = {{ .Values.conf.ceph.config.osd.osd_mon_heartbeat_interval | default "30" | quote }}

# ports
ms_bind_port_min = {{ .Values.conf.ceph.config.osd.ms_bind_port_min | default "6800" | quote }}
ms_bind_port_max = {{ .Values.conf.ceph.config.osd.ms_bind_port_max | default "7100" | quote }}

# journal
journal_size = {{ .Values.conf.ceph.config.osd.journal_size | default "100" | quote }}

# filesystem
osd_mkfs_type = {{ .Values.conf.ceph.config.osd.osd_mkfs_type | default "xfs" | quote }}
osd_mkfs_options_xfs = {{ .Values.conf.ceph.config.osd.osd_mkfs_options_xfs | default "-f -i size=2048" | quote }}
osd_max_object_name_len = {{ .Values.conf.ceph.config.osd.osd_max_object_name_len | default "256" | quote }}

# crush
osd_pool_default_crush_rule = {{ .Values.conf.ceph.config.osd.osd_pool_default_crush_rule | default "0" | quote }}
osd_crush_update_on_start = {{ .Values.conf.ceph.config.osd.osd_crush_update_on_start | default "true" | quote }}
osd_crush_chooseleaf_type = {{ .Values.conf.ceph.config.osd.osd_crush_chooseleaf_type | default "1" | quote }}

# backend
osd_objectstore = {{ .Values.conf.ceph.config.osd.osd_objectstore | default "filestore" | quote }}

# performance tuning
filestore_merge_threshold = {{ .Values.conf.ceph.config.osd.filestore_merge_threshold | default "40" | quote }}
filestore_split_multiple = {{ .Values.conf.ceph.config.osd.filestore_split_multiple | default "8" | quote }}
osd_op_threads = {{ .Values.conf.ceph.config.osd.osd_op_threads | default "8" | quote }}
filestore_op_threads = {{ .Values.conf.ceph.config.osd.filestore_op_threads | default "8" | quote }}
filestore_max_sync_interval = {{ .Values.conf.ceph.config.osd.filestore_max_sync_interval | default "5" | quote }}
osd_max_scrubs = {{ .Values.conf.ceph.config.osd.osd_max_scrubs | default "1" | quote }}

# recovery tuning
osd_recovery_max_active = {{ .Values.conf.ceph.config.osd.osd_recovery_max_active | default "5" | quote }}
osd_max_backfills = {{ .Values.conf.ceph.config.osd.osd_max_backfills | default "2" | quote }}
osd_recovery_op_priority = {{ .Values.conf.ceph.config.osd.osd_recovery_op_priority | default "2" | quote }}
osd_client_op_priority = {{ .Values.conf.ceph.config.osd.osd_client_op_priority | default "63" | quote }}
osd_recovery_max_chunk = {{ .Values.conf.ceph.config.osd.osd_client_op_priority | default "osd_recovery_max_chunk" | quote }}
osd_recovery_threads = {{ .Values.conf.ceph.config.osd.osd_recovery_threads | default "1" | quote }}

[client]
rbd_cache_enabled = {{ .Values.conf.ceph.config.client.rbd_cache_enabled | default "true" | quote }}
rbd_cache_writethrough_until_flush = {{ .Values.conf.ceph.config.client.rbd_cache_writethrough_until_flush | default "true" | quote }}
rbd_default_features = {{ .Values.conf.ceph.config.client.rbd_default_features | default "1" | quote }}

[mds]
mds_cache_size = {{ .Values.conf.ceph.config.client.mds_mds_cache_size | default "100000" | quote }}
