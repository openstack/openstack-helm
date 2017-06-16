#!/bin/bash
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
set -e

function wait_for_ping {
  # Default wait timeout is 180 seconds
  set +x
  PING_CMD="ping -q -c 1 -W 1"
  end=$(date +%s)
  if [ x$2 != "x" ]; then
   end=$((end + $2))
  else
   end=$((end + 180))
  fi
  while true; do
      $PING_CMD $1 > /dev/null && \
          break || true
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Could not ping $1 in time" && exit -1
  done
  set -x
  $PING_CMD $1
}

function openstack_wait_for_vm {
  # Default wait timeout is 180 seconds
  set +x
  end=$(date +%s)
  if [ x$2 != "x" ]; then
   end=$((end + $2))
  else
   end=$((end + 180))
  fi
  while true; do
      STATUS=$($OPENSTACK server show $1 -f value -c status)
      [ $STATUS == "ACTIVE" ] && \
          break || true
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo VM failed to start. && \
          $OPENSTACK server show $1 && exit -1
  done
  set -x
}
