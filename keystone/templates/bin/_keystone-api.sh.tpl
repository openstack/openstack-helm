#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

COMMAND="${@:-start}"

function start () {

  for KEYSTONE_WSGI_SCRIPT in keystone-wsgi-public; do
    cp -a $(type -p ${KEYSTONE_WSGI_SCRIPT}) /var/www/cgi-bin/keystone/
  done

  if [ -f /etc/apache2/envvars ]; then
     # Loading Apache2 ENV variables
     source /etc/apache2/envvars
  fi

  # Start Apache2
  exec apache2 -DFOREGROUND
}

function stop () {
  apachectl -k graceful-stop
}

$COMMAND
