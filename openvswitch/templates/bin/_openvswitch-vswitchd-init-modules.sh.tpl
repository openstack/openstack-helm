#!/bin/bash

{{/*
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

set -ex
chroot /mnt/host-rootfs modprobe openvswitch
chroot /mnt/host-rootfs modprobe gre
chroot /mnt/host-rootfs modprobe vxlan

{{- if .Values.conf.ovs_dpdk.enabled }}
{{- if hasKey .Values.conf.ovs_dpdk "driver"}}
chroot /mnt/host-rootfs modprobe {{ .Values.conf.ovs_dpdk.driver | quote }}
{{- end }}
{{- end }}
