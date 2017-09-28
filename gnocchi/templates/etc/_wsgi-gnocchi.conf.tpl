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

Listen 0.0.0.0:{{ .Values.conf.gnocchi.api.port }}

SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
CustomLog /dev/stdout combined env=!forwarded
CustomLog /dev/stdout proxy env=forwarded

<VirtualHost *:{{ .Values.conf.gnocchi.api.port }}>
    WSGIDaemonProcess gnocchi processes=1 threads=2 user=gnocchi group=gnocchi display-name=%{GROUP}
    WSGIProcessGroup gnocchi
    WSGIScriptAlias / "/var/lib/kolla/venv/lib/python2.7/site-packages/gnocchi/rest/app.wsgi"
    WSGIApplicationGroup %{GLOBAL}

    ErrorLog /dev/stderr
    SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
    CustomLog /dev/stdout combined env=!forwarded
    CustomLog /dev/stdout proxy env=forwarded

    <Directory "/var/lib/kolla/venv/lib/python2.7/site-packages/gnocchi/rest">
          Require all granted
    </Directory>
</VirtualHost>
