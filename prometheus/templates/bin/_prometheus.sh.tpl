#!/bin/sh

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

# Two ways how to launch init process in container: by default and custom (defined in override values).
{{ $deflaunch := .Values.proc_launch.prometheus.default }}
if [ "{{ $deflaunch }}" = true ]
then
  COMMAND="${@:-start}"

  function start () {
  {{ $flags := include "prometheus.utils.command_line_flags" .Values.conf.prometheus.command_line_flags }}
    exec /bin/prometheus --config.file=/etc/config/prometheus.yml {{ $flags }}
  }

  function stop () {
    kill -TERM 1
  }

  $COMMAND
else
  {{ tpl (.Values.proc_launch.prometheus.custom_launch) . }}
fi
