[rbd1]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
rbd_pool = {{ .Values.backends.rbd1.pool }}
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
rbd_user = {{ .Values.backends.rbd1.user }}
rbd_secret_uuid = {{ .Values.backends.rbd1.secret }}
report_discard_supported = True
