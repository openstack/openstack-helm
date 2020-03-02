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

SITE_PACKAGES_ROOT=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
rm -f ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py
ln -s /etc/openstack-dashboard/local_settings ${SITE_PACKAGES_ROOT}/openstack_dashboard/local/local_settings.py

exec /tmp/manage.py migrate --noinput
