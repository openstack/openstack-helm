#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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

namespace="osh-infra"

# NOTE: Lint and package chart
make memcached

tee /tmp/memcached.yaml <<EOF
images:
  tags:
    apparmor_loader: google/apparmor-loader:latest
pod:
  mandatory_access_control:
    type: apparmor
    configmap_apparmor: true
    memcached:
      memcached: localhost/my-apparmor-v1
      apparmor-loader: unconfined
conf:
  apparmor_profiles:
    my-apparmor-v1.profile: |-
      #include <tunables/global>
      profile my-apparmor-v1 flags=(attach_disconnected,mediate_deleted) {
        #include <abstractions/base>
        network inet tcp,
        network inet udp,
        network inet icmp,
        deny network raw,
        deny network packet,
        file,
        umount,
        deny /bin/** wl,
        deny /boot/** wl,
        deny /dev/** wl,
        deny /etc/** wl,
        deny /home/** wl,
        deny /lib/** wl,
        deny /lib64/** wl,
        deny /media/** wl,
        deny /mnt/** wl,
        deny /opt/** wl,
        deny /proc/** wl,
        deny /root/** wl,
        deny /sbin/** wl,
        deny /srv/** wl,
        deny /tmp/** wl,
        deny /sys/** wl,
        deny /usr/** wl,
        audit /** w,
        /var/run/nginx.pid w,
        /usr/sbin/nginx ix,
        deny /bin/dash mrwklx,
        deny /bin/sh mrwklx,
        deny /usr/bin/top mrwklx,
        capability chown,
        capability dac_override,
        capability setuid,
        capability setgid,
        capability net_bind_service,
        deny @{PROC}/{*,**^[0-9*],sys/kernel/shm*} wkx,
        deny @{PROC}/sysrq-trigger rwklx,
        deny @{PROC}/mem rwklx,
        deny @{PROC}/kmem rwklx,
        deny @{PROC}/kcore rwklx,
        deny mount,
        deny /sys/[^f]*/** wklx,
        deny /sys/f[^s]*/** wklx,
        deny /sys/fs/[^c]*/** wklx,
        deny /sys/fs/c[^g]*/** wklx,
        deny /sys/fs/cg[^r]*/** wklx,
        deny /sys/firmware/efi/efivars/** rwklx,
        deny /sys/kernel/security/** rwklx,
      }
EOF

# NOTE: Deploy command
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
helm upgrade --install memcached ./memcached \
    --namespace=$namespace \
    --set pod.replicas.server=1 \
    --values=/tmp/memcached.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_MEMCACHED}

# NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh $namespace

# NOTE: Validate Deployment info
helm status memcached

# Run a test. Note: the simple "cat /proc/1/attr/current" verification method
# will not work, as memcached has multiple processes running, so we have to
# find out which one is the memcached application process.
pod=$(kubectl -n $namespace get pod | grep memcached | awk '{print $1}')
unsorted_process_file="/tmp/unsorted_proc_list"
sorted_process_file="/tmp/proc_list"
expected_profile="my-apparmor-v1 (enforce)"

# Grab the processes (numbered directories) from the /proc directory,
# and then sort them. Highest proc number indicates most recent process.
kubectl -n $namespace exec $pod -- ls -1 /proc | grep -e "^[0-9]*$" > $unsorted_process_file
sort --numeric-sort $unsorted_process_file > $sorted_process_file

# The last/latest process in the list will actually be the "ls" command above,
# which isn't running any more, so remove it.
sed -i '$ d' $sorted_process_file

while IFS='' read -r process || [[ -n "$process" ]]; do
  echo "Process ID: $process"
  proc_name=`kubectl -n $namespace exec $pod -- cat /proc/$process/status | grep "Name:" | awk -F' ' '{print $2}'`
  echo "Process Name: $proc_name"
  profile=`kubectl -n $namespace exec $pod -- cat /proc/$process/attr/current`
  echo "Profile running: $profile"
  if test "$profile" != "$expected_profile"
  then
    if test "$proc_name" == "pause"
    then
      echo "Root process (pause) can run docker-default, it's ok."
    else
      echo "$profile is the WRONG PROFILE!!"
      return 1
    fi
  fi
done < $sorted_process_file
