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

set -ev

COMMAND="${@:-start}"

function start () {

  if [ -f /etc/apache2/envvars ]; then
     # Loading Apache2 ENV variables
     source /etc/httpd/apache2/envvars
  fi
  # Apache gets grumpy about PID files pre-existing
  rm -f /etc/httpd/logs/httpd.pid

  if [ -f /usr/local/apache2/conf/.htpasswd ]; then
    htpasswd -b /usr/local/apache2/conf/.htpasswd "$NAGIOSADMIN_USER" "$NAGIOSADMIN_PASS"
  else
    htpasswd -cb /usr/local/apache2/conf/.htpasswd "$NAGIOSADMIN_USER" "$NAGIOSADMIN_PASS"
  fi

  #Launch Apache on Foreground
  exec httpd -DFOREGROUND
}

function stop () {
  apachectl -k graceful-stop
}

$COMMAND
