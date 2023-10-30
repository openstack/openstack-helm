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
COMMAND="${@:-start}"

OVS_SOCKET=/run/openvswitch/db.sock
OVS_PID=/run/openvswitch/ovs-vswitchd.pid

# Create vhostuser directory and grant nova user (default UID 42424) access
# permissions.
{{- if .Values.conf.ovs_dpdk.enabled }}
mkdir -p /run/openvswitch/{{ .Values.conf.ovs_dpdk.vhostuser_socket_dir }}
chown {{ .Values.pod.user.nova.uid }}.{{ .Values.pod.user.nova.uid }} /run/openvswitch/{{ .Values.conf.ovs_dpdk.vhostuser_socket_dir }}
{{- end }}

function start () {
  t=0
  while [ ! -e "${OVS_SOCKET}" ] ; do
      echo "waiting for ovs socket $sock"
      sleep 1
      t=$(($t+1))
      if [ $t -ge 10 ] ; then
          echo "no ovs socket, giving up"
          exit 1
      fi
  done

  ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait show
{{- if .Values.conf.ovs_hw_offload.enabled }}
  ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:hw-offload={{ .Values.conf.ovs_hw_offload.enabled }}
{{- end }}
{{- if .Values.conf.ovs_other_config.handler_threads }}
  ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:n-handler-threads={{ .Values.conf.ovs_other_config.handler_threads }}
{{- end }}
{{- if .Values.conf.ovs_other_config.revalidator_threads }}
  ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:n-revalidator-threads={{ .Values.conf.ovs_other_config.revalidator_threads }}
{{- end }}

{{- if .Values.conf.ovs_dpdk.enabled }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-hugepage-dir={{ .Values.conf.ovs_dpdk.hugepages_mountpath | quote }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-socket-mem={{ .Values.conf.ovs_dpdk.socket_memory | quote }}

{{- if .Values.conf.ovs_dpdk.mem_channels }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-mem-channels={{ .Values.conf.ovs_dpdk.mem_channels | quote }}
{{- end }}

{{- if hasKey .Values.conf.ovs_dpdk "pmd_cpu_mask" }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:pmd-cpu-mask={{ .Values.conf.ovs_dpdk.pmd_cpu_mask | quote }}
    PMD_CPU_MASK={{ .Values.conf.ovs_dpdk.pmd_cpu_mask | quote }}
{{- end }}

{{- if hasKey .Values.conf.ovs_dpdk "lcore_mask" }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask={{ .Values.conf.ovs_dpdk.lcore_mask | quote }}
    LCORE_MASK={{ .Values.conf.ovs_dpdk.lcore_mask | quote }}
{{- end }}

{{- if hasKey .Values.conf.ovs_dpdk "vhost_iommu_support" }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:vhost-iommu-support={{ .Values.conf.ovs_dpdk.vhost_iommu_support }}
{{- end }}

    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:vhost-sock-dir={{ .Values.conf.ovs_dpdk.vhostuser_socket_dir | quote }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-init=true

  # No need to create the cgroup if lcore_mask or pmd_cpu_mask is not set.
  if [[ -n ${PMD_CPU_MASK} || -n ${LCORE_MASK} ]]; then
      if [ "$(stat -fc %T /sys/fs/cgroup/)" = "cgroup2fs" ]; then
          # Setup Cgroups to use when breaking out of Kubernetes defined groups
          mkdir -p /sys/fs/cgroup/osh-openvswitch
          target_mems="/sys/fs/cgroup/osh-openvswitch/cpuset.mems"
          target_cpus="/sys/fs/cgroup/osh-openvswitch/cpuset.cpus"
          touch $target_mems
          touch $target_cpus

          # Ensure the write target for the for cpuset.mem for the pod exists
          if [[ -f "$target_mems" && -f "$target_cpus" ]]; then
            # Write cpuset.mem and cpuset.cpus for new cgroup and add current task to new cgroup
            cat /sys/fs/cgroup/cpuset.mems.effective > "$target_mems"
            cat /sys/fs/cgroup/cpuset.cpus.effective > "$target_cpus"
            echo $$ > /sys/fs/cgroup/osh-openvswitch/cgroup.procs
          else
            echo "ERROR: Could not find write target for either cpuset.mems: $target_mems or cpuset.cpus: $target_cpus"
          fi
      else
          # Setup Cgroups to use when breaking out of Kubernetes defined groups
          mkdir -p /sys/fs/cgroup/cpuset/osh-openvswitch
          target_mems="/sys/fs/cgroup/cpuset/osh-openvswitch/cpuset.mems"
          target_cpus="/sys/fs/cgroup/cpuset/osh-openvswitch/cpuset.cpus"

          # Ensure the write target for the for cpuset.mem for the pod exists
          if [[ -f "$target_mems" && -f "$target_cpus" ]]; then
            # Write cpuset.mem and cpuset.cpus for new cgroup and add current task to new cgroup
            cat /sys/fs/cgroup/cpuset/cpuset.mems > "$target_mems"
            cat /sys/fs/cgroup/cpuset/cpuset.cpus > "$target_cpus"
            echo $$ > /sys/fs/cgroup/cpuset/osh-openvswitch/tasks
          else
            echo "ERROR: Could not find write target for either cpuset.mems: $target_mems or cpuset.cpus: $target_cpus"
          fi
      fi
  fi
{{- end }}

  exec /usr/sbin/ovs-vswitchd unix:${OVS_SOCKET} \
          -vconsole:emer \
          -vconsole:err \
          -vconsole:info \
          --pidfile=${OVS_PID} \
          --mlockall
}

function stop () {
  PID=$(cat $OVS_PID)
  ovs-appctl -T1 -t /run/openvswitch/ovs-vswitchd.${PID}.ctl exit
}

find_latest_ctl_file() {
    latest_file=""
    latest_file=$(ls -lt /run/openvswitch/*.ctl | awk 'NR==1 {if ($3 == "{{ .Values.conf.poststart.rootUser }}") print $NF}')

    echo "$latest_file"
}

function poststart () {
  # This enables the usage of 'ovs-appctl' from neutron-ovs-agent pod.

  # Wait for potential new ctl file before continuing
  timeout={{ .Values.conf.poststart.timeout }}
  start_time=$(date +%s)
  while true; do
      latest_ctl_file=$(find_latest_ctl_file)
      if [ -n "$latest_ctl_file" ]; then
          break
      fi
      current_time=$(date +%s)
      if (( current_time - start_time >= timeout )); then
          break
      fi
      sleep 1
  done

  until [ -f $OVS_PID ]
  do
      echo "Waiting for file $OVS_PID"
      sleep 1
  done

  PID=$(cat $OVS_PID)
  OVS_CTL=/run/openvswitch/ovs-vswitchd.${PID}.ctl

  until [ -S $OVS_CTL ]
  do
      echo "Waiting for file $OVS_CTL"
      sleep 1
  done
  chown {{ .Values.pod.user.nova.uid }}.{{ .Values.pod.user.nova.uid }} ${OVS_CTL}

{{- if .Values.conf.poststart.extraCommand }}
{{ .Values.conf.poststart.extraCommand | indent 2 }}
{{- end }}

}

$COMMAND
