#!/bin/sh

# Copyright 2017 The Openstack-Helm Authors.
#
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

# A readiness check for ceph monitors: exit 0 iff the monitor appears to be at least
# alive (but not necessarily in a quorum).
CEPH=${CEPH_CMD:-/usr/bin/ceph}
SOCKDIR=${CEPH_SOCKET_DIR:-/run/ceph}
SBASE=${CEPH_OSD_SOCKET_BASE:-ceph-mon}
SSUFFIX=${CEPH_SOCKET_SUFFIX:-asok}

mon_live_state="leader peon"

monid=`ps auwwx | grep ceph-mon | grep -v "$1" | grep -v grep | sed 's/.*-i\ *//;s/\ *-.*//'|awk '{print $1}'`

if [ -z "${monid}" ]; then
    # not really a sensible fallback, but it'll do.
    monid=`hostname`
fi

if [ -S "${SOCKDIR}/${SBASE}.${monid}.${SSUFFIX}" ]; then
 state=`${CEPH} -f json-pretty --connect-timeout 1 --admin-daemon "${sock}" mon_status|grep state|sed 's/.*://;s/[^a-z]//g'`
 echo "MON $monid $state";
 # this might be a stricter check than we actually want.  what are the
 # other values for the "state" field?
 for S in ${mon_live_state}; do
  if [ "x${state}x" = "x${S}x" ]; then
   exit 0
  fi
 done
fi
exit 1
