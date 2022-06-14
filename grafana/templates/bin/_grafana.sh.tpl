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

set -exo pipefail
COMMAND="${@:-start}"
PORT={{ tuple "grafana" "internal" "grafana" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
PIDFILE=/tmp/pid

function start () {
  exec /usr/share/grafana/bin/grafana-server -homepath=/usr/share/grafana -config=/etc/grafana/grafana.ini --pidfile="$PIDFILE"
}

function run_migrator () {
  start &
  timeout 60 bash -c "until timeout 5 bash -c '</dev/tcp/127.0.0.1/${PORT}'; do sleep 1; done"
  stop
}

function stop () {
  if [ -f "$PIDFILE" ]; then
    echo -e "Found pidfile, killing running grafana-server"
    kill -9 `cat $PIDFILE`
    rm $PIDFILE
  else
    kill -TERM 1
  fi
}

$COMMAND
