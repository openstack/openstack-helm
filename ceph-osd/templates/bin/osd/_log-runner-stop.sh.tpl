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

source /tmp/utils-resolveLocations.sh

touch /tmp/ceph-log-runner.stop

TAIL_PID="$(cat /tmp/ceph-log-runner.pid)"
while kill -0 ${TAIL_PID} >/dev/null 2>&1;
do
  kill -9 ${TAIL_PID};
  sleep 1;
done

SLEEP_PID="$(cat /tmp/ceph-log-runner-sleep.pid)"
while kill -0 ${SLEEP_PID} >/dev/null 2>&1;
do
  kill -9 ${SLEEP_PID};
  sleep 1;
done
