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
  SITE_PACKAGES_ROOT=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
  rm -f ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py
  ln -s /etc/openstack-dashboard/local_settings ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py

  # wsgi/horizon-http needs open files here, including secret_key_store
  chown -R horizon ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/

  a2enmod rewrite

  if [ -f /etc/apache2/envvars ]; then
     # Loading Apache2 ENV variables
     source /etc/apache2/envvars
  fi
  rm -rf /var/run/apache2/*
  APACHE_DIR="apache2"

  # If the image has support for it, compile the translations
  if type -p gettext >/dev/null 2>/dev/null; then
    cd ${SITE_PACKAGES_ROOT}/openstack_dashboard; /tmp/manage.py compilemessages
  fi

  # Compress Horizon's assets.
  /tmp/manage.py collectstatic --noinput
  /tmp/manage.py compress --force
  rm -rf /tmp/_tmp_.secret_key_store.lock /tmp/.secret_key_store

  exec apache2 -DFOREGROUND
}

function stop () {
  apachectl -k graceful-stop
}

$COMMAND
