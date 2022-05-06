#!/bin/sh

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A liveness check for ceph OSDs: exit 0 if
# all OSDs on this host are in the "active" state
# per their admin sockets.

SOCKDIR=${CEPH_SOCKET_DIR:-/run/ceph}
SBASE=${CEPH_OSD_SOCKET_BASE:-ceph-osd}
SSUFFIX=${CEPH_SOCKET_SUFFIX:-asok}

# default: no sockets, not live
cond=1
for sock in $SOCKDIR/$SBASE.*.$SSUFFIX; do
 if [ -S $sock ]; then
  OSD_ID=$(echo $sock | awk -F. '{print $2}')
  OSD_STATE=$(ceph -f json --connect-timeout 1 --admin-daemon "${sock}" status|jq -r '.state')
  echo "OSD ${OSD_ID} ${OSD_STATE}";
  # Succeed if the OSD state is active (running) or preboot (starting)
  if [ "${OSD_STATE}" = "active" ] || [ "${OSD_STATE}" = "preboot" ]; then
   cond=0
  else
   # Any other state is unexpected and the probe fails
   exit 1
  fi
 else
  echo "No daemon sockets found in $SOCKDIR"
 fi
done
exit $cond
