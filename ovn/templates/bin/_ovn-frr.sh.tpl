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

if [ -r "/lib/lsb/init-functions" ]; then
        . /lib/lsb/init-functions
else
        log_success_msg() {
                echo "$@"
        }
        log_warning_msg() {
                echo "$@" >&2
        }
        log_failure_msg() {
                echo "$@" >&2
        }
fi

source /usr/lib/frr/frrcommon.sh
exec /usr/lib/frr/watchfrr $(daemon_list)
