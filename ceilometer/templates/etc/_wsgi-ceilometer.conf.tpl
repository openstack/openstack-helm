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

Listen 0.0.0.0:{{ tuple "metering" "internal" "api" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}

LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

<VirtualHost *:{{ tuple "metering" "internal" "api" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}>
    LogLevel info
    WSGIDaemonProcess ceilometer-api processes=2 threads=1 user=ceilometer group=ceilometer display-name=%{GROUP} python-path=/var/lib/kolla/venv/lib/python2.7/site-packages
    WSGIProcessGroup ceilometer-api

    WSGIScriptReloading On
    WSGIScriptAlias / /var/lib/kolla/venv/lib/python2.7/site-packages/ceilometer/api/app.wsgi

    WSGIApplicationGroup %{GLOBAL}

    <Directory "/var/lib/kolla/venv/lib/python2.7/site-packages/ceilometer/api">
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
    ErrorLog /dev/stdout
    CustomLog /dev/stdout combined
</VirtualHost>
