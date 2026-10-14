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
output="$(grafana-cli --homepath "/usr/share/grafana" --config /etc/grafana/grafana.ini admin reset-admin-password "${GF_SECURITY_ADMIN_PASSWORD}" 2>&1)"
rc=$?
echo "${output}"

# grafana-cli exits 0 on some failures, so judge by its output.
if [ "${rc}" -eq 0 ] && grep -q "Admin password changed successfully" <<< "${output}"; then
  exit 0
fi
# Expected before grafana first starts; printed before a listing that may fail.
if grep -q "Admin user cannot be found" <<< "${output}"; then
  echo "The Grafana admin user does not exist yet, so no need to update password"
  exit 0
fi
echo "ERROR: the Grafana admin password was NOT updated (exit status ${rc})" >&2
exit 1
