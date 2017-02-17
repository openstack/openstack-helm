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

[global]
rgw_thread_pool_size = 1024
rgw_num_rados_handles = 100
{{- if .Values.ceph.monitors }}
[mon]
{{ range .Values.ceph.monitors }}
    [mon.{{ . }}]
      host = {{ . }}
      mon_addr = {{ . }}
{{ end }}
{{- else }}
mon_host = ceph-mon.ceph
{{- end }}
[client]
  rbd_cache_enabled = true
  rbd_cache_writethrough_until_flush = true
