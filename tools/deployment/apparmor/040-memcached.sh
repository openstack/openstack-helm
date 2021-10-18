#!/bin/bash

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
: ${OSH_INFRA_EXTRA_HELM_ARGS_MEMCACHED:="$(./tools/deployment/common/get-values-overrides.sh memcached)"}

# NOTE: Lint and package chart
make memcached

tee /tmp/memcached.yaml <<EOF
images:
  tags:
    apparmor_loader: google/apparmor-loader:latest
pod:
  mandatory_access_control:
    type: apparmor
    memcached:
      memcached: runtime/default
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

# Run a test. Note: the simple "cat /proc/1/attr/current" verification method
# will not work, as memcached has multiple processes running, so we have to
# find out which one is the memcached application process.
pod=$(kubectl -n $namespace get pod | grep memcached | awk '{print $1}')
unsorted_process_file="/tmp/unsorted_proc_list"
sorted_process_file="/tmp/proc_list"
expected_profile="docker-default (enforce)"

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
