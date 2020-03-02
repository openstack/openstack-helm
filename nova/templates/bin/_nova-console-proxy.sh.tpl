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

set -x

console_kind="{{- .Values.console.console_kind -}}"
if [ "${console_kind}" == "novnc" ] ; then
    exec nova-novncproxy \
        --config-file /etc/nova/nova.conf \
        --config-file /tmp/pod-shared/nova-vnc.ini
elif [ "${console_kind}" == "spice" ] ; then
    exec nova-spicehtml5proxy\
        --config-file /etc/nova/nova.conf \
        --config-file /tmp/pod-shared/nova-spice.ini
fi