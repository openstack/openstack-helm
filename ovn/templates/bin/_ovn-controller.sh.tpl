#!/bin/bash -xe

# Copyright 2023 VEXXHOST, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COMMAND="${@:-start}"

function start () {
  /usr/share/ovn/scripts/ovn-ctl start_controller \
    --ovn-manage-ovsdb=no

  tail --follow=name /var/log/ovn/ovn-controller.log
}

function stop () {
  /usr/share/ovn/scripts/ovn-ctl stop_controller
  pkill tail
}

function liveness () {
  ovs-appctl -t /var/run/ovn/ovn-controller.$(cat /var/run/ovn/ovn-controller.pid).ctl status
}

function readiness () {
  ovs-appctl -t /var/run/ovn/ovn-controller.$(cat /var/run/ovn/ovn-controller.pid).ctl status
}

$COMMAND
