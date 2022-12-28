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

echo "Attempting to update Grafana admin user password"
grafana-cli --homepath "/usr/share/grafana" --config /etc/grafana/grafana.ini admin reset-admin-password ${GF_SECURITY_ADMIN_PASSWORD}

if [ "$?" == 1 ]; then
  echo "The Grafana admin user does not exist yet, so no need to update password"
  exit 0;
else
  exit 0;
fi
