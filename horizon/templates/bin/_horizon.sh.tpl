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
COMMAND="${@:-start}"

function start () {
  SITE_PACKAGES_ROOT=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
  rm -f ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py
  ln -s /etc/openstack-dashboard/local_settings ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py
  ln -s  ${SITE_PACKAGES_ROOT}/openstack_dashboard/conf/default_policies  /etc/openstack-dashboard/default_policies
  {{- range $key, $value := .Values.conf.horizon.local_settings_d }}
  ln -s /etc/openstack-dashboard/local_settings.d/{{ $key }}.py ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.d/{{ $key }}.py
  {{- end }}
  {{- range $key, $value := .Values.conf.horizon.custom_panels }}
  ln -s /etc/openstack-dashboard/custom_panels/{{ $key }}.py ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/enabled/{{ $key }}.py
  {{- end }}
  # wsgi/horizon-http needs open files here, including secret_key_store
  chown -R horizon ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/

  {{- if .Values.conf.software.apache2.a2enmod }}
    {{- range .Values.conf.software.apache2.a2enmod }}
  a2enmod {{ . }}
    {{- end }}
  {{- end }}

  {{- if .Values.conf.software.apache2.a2dismod }}
    {{- range .Values.conf.software.apache2.a2dismod }}
  a2dismod {{ . }}
    {{- end }}
  {{- end }}

  if [ -f /etc/apache2/envvars ]; then
     # Loading Apache2 ENV variables
     source /etc/apache2/envvars
     # The directory below has to be created due to the fact that
     # libapache2-mod-wsgi-py3 doesn't create it in contrary by libapache2-mod-wsgi
     if [ ! -d ${APACHE_RUN_DIR} ]; then
        mkdir -p ${APACHE_RUN_DIR}
     fi
  fi
  rm -rf /var/run/apache2/*
  APACHE_DIR="apache2"

  # Add extra panels if available
  {{- range .Values.conf.horizon.extra_panels }}
  PANEL_DIR="${SITE_PACKAGES_ROOT}/{{ . }}/enabled"
  if [ -d ${PANEL_DIR} ];then
    for panel in `ls -1 ${PANEL_DIR}/_[1-9]*.py`
    do
      ln -s ${panel} ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/enabled/$(basename ${panel})
    done
  fi
  unset PANEL_DIR
  PANEL_DIR="${SITE_PACKAGES_ROOT}/{{ . }}/local/enabled"
  if [ -d ${PANEL_DIR} ];then
    for panel in `ls -1 ${PANEL_DIR}/_[1-9]*.py`
    do
      ln -s ${panel} ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/enabled/$(basename ${panel})
    done
  fi
  unset PANEL_DIR
  {{- end }}

  # If the image has support for it, compile the translations
  if type -p gettext >/dev/null 2>/dev/null; then
    cd ${SITE_PACKAGES_ROOT}/openstack_dashboard; /tmp/manage.py compilemessages
    # if there are extra panels and the image has support for it, compile the translations
    {{- range .Values.conf.horizon.extra_panels }}
    PANEL_DIR="${SITE_PACKAGES_ROOT}/{{ . }}"
    if [ -d ${PANEL_DIR} ]; then
      cd ${PANEL_DIR}; /tmp/manage.py compilemessages
    fi
    {{- end }}
    unset PANEL_DIR
  fi

  # Copy custom logo images
  {{- if .Values.manifests.configmap_logo }}
  cp /tmp/favicon.ico ${SITE_PACKAGES_ROOT}/openstack_dashboard/static/dashboard/img/favicon.ico
  cp /tmp/logo.svg ${SITE_PACKAGES_ROOT}/openstack_dashboard/static/dashboard/img/logo.svg
  cp /tmp/logo-splash.svg ${SITE_PACKAGES_ROOT}/openstack_dashboard/static/dashboard/img/logo-splash.svg
  {{- end }}

  # Compress Horizon's assets.
  /tmp/manage.py collectstatic --noinput
  /tmp/manage.py compress --force
  rm -rf /tmp/_tmp_.secret_key_store.lock /tmp/.secret_key_store
  chmod +x ${SITE_PACKAGES_ROOT}/django/core/wsgi.py
  exec {{ .Values.conf.software.apache2.binary }} {{ .Values.conf.software.apache2.start_parameters }}
}

function stop () {
  {{ .Values.conf.software.apache2.binary }} -k graceful-stop
}

$COMMAND
