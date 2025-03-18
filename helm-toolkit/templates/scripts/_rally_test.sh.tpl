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

{{- define "helm-toolkit.scripts.rally_test" -}}
#!/bin/bash
set -ex
{{- $rallyTests := index . 0 }}

: "${RALLY_ENV_NAME:="openstack-helm"}"
: "${OS_INTERFACE:="public"}"
: "${RALLY_CLEANUP:="true"}"

if [ "x$RALLY_CLEANUP" == "xtrue" ]; then
  function rally_cleanup {
    openstack user delete \
        --domain="${SERVICE_OS_USER_DOMAIN_NAME}" \
        "${SERVICE_OS_USERNAME}"
{{ $rallyTests.clean_up | default "" | indent 4 }}
  }
  trap rally_cleanup EXIT
fi

function create_or_update_db () {
  revisionResults=$(rally db revision)
  if [ $revisionResults = "None"  ]
  then
    rally db create
  else
    rally db upgrade
  fi
}

create_or_update_db

cat > /tmp/rally-config.json << EOF
{
    "openstack": {
        "auth_url": "${OS_AUTH_URL}",
        "region_name": "${OS_REGION_NAME}",
        "endpoint_type": "${OS_INTERFACE}",
        "admin": {
            "username": "${OS_USERNAME}",
            "password": "${OS_PASSWORD}",
            "user_domain_name": "${OS_USER_DOMAIN_NAME}",
            "project_name": "${OS_PROJECT_NAME}",
            "project_domain_name": "${OS_PROJECT_DOMAIN_NAME}"
        },
        "users": [
            {
                "username": "${SERVICE_OS_USERNAME}",
                "password": "${SERVICE_OS_PASSWORD}",
                "project_name": "${SERVICE_OS_PROJECT_NAME}",
                "user_domain_name": "${SERVICE_OS_USER_DOMAIN_NAME}",
                "project_domain_name": "${SERVICE_OS_PROJECT_DOMAIN_NAME}"
            }
        ],
        "https_insecure": false,
        "https_cacert": "${OS_CACERT}"
    }
}
EOF
rally deployment create --file /tmp/rally-config.json --name "${RALLY_ENV_NAME}"
rm -f /tmp/rally-config.json
rally deployment use "${RALLY_ENV_NAME}"
rally deployment check
{{- if $rallyTests.run_tempest }}
rally verify create-verifier --name "${RALLY_ENV_NAME}-tempest" --type tempest
SERVICE_TYPE="$(rally deployment check | grep "${RALLY_ENV_NAME}" | awk -F \| '{print $3}' | tr -d ' ' | tr -d '\n')"
rally verify start --pattern "tempest.api.${SERVICE_TYPE}*"
rally verify delete-verifier --id "${RALLY_ENV_NAME}-tempest" --force
{{- end }}
rally task validate /etc/rally/rally_tests.yaml
rally task start /etc/rally/rally_tests.yaml
rally task sla-check
rally env cleanup
rally deployment destroy --deployment "${RALLY_ENV_NAME}"
{{- end }}
