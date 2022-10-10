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

{{- define "helm-toolkit.scripts.rabbit_init" }}
#!/bin/bash
set -e
# Extract connection details
RABBIT_HOSTNAME=$(echo "${RABBITMQ_ADMIN_CONNECTION}" | \
  awk -F'[@]' '{print $2}' | \
  awk -F'[:/]' '{print $1}')
RABBIT_PORT=$(echo "${RABBITMQ_ADMIN_CONNECTION}" | \
  awk -F'[@]' '{print $2}' | \
  awk -F'[:/]' '{print $2}')

# Extract Admin User creadential
RABBITMQ_ADMIN_USERNAME=$(echo "${RABBITMQ_ADMIN_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $4}')
RABBITMQ_ADMIN_PASSWORD=$(echo "${RABBITMQ_ADMIN_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $5}')

# Extract User creadential
RABBITMQ_USERNAME=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $4}')
RABBITMQ_PASSWORD=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $5}')

# Extract User vHost
RABBITMQ_VHOST=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $2}' | \
  awk -F'[:/]' '{print $3}')
# Resolve vHost to / if no value is set
RABBITMQ_VHOST="${RABBITMQ_VHOST:-/}"

function rabbitmqadmin_cli () {
  if [ -n "$RABBITMQ_X509" ]
  then
    rabbitmqadmin \
      --ssl \
      --ssl-disable-hostname-verification \
      --ssl-ca-cert-file="${USER_CERT_PATH}/ca.crt" \
      --ssl-cert-file="${USER_CERT_PATH}/tls.crt" \
      --ssl-key-file="${USER_CERT_PATH}/tls.key" \
      --host="${RABBIT_HOSTNAME}" \
      --port="${RABBIT_PORT}" \
      --username="${RABBITMQ_ADMIN_USERNAME}" \
      --password="${RABBITMQ_ADMIN_PASSWORD}" \
      ${@}
  else
    rabbitmqadmin \
      --host="${RABBIT_HOSTNAME}" \
      --port="${RABBIT_PORT}" \
      --username="${RABBITMQ_ADMIN_USERNAME}" \
      --password="${RABBITMQ_ADMIN_PASSWORD}" \
      ${@}
  fi
}

echo "Managing: User: ${RABBITMQ_USERNAME}"
rabbitmqadmin_cli \
  declare user \
  name="${RABBITMQ_USERNAME}" \
  password="${RABBITMQ_PASSWORD}" \
  tags="user"

echo "Deleting Guest User"
rabbitmqadmin_cli \
  delete user \
  name="guest" || true

if [ "${RABBITMQ_VHOST}" != "/" ]
then
  echo "Managing: vHost: ${RABBITMQ_VHOST}"
  rabbitmqadmin_cli \
    declare vhost \
    name="${RABBITMQ_VHOST}"
else
  echo "Skipping root vHost declaration: vHost: ${RABBITMQ_VHOST}"
fi

echo "Managing: Permissions: ${RABBITMQ_USERNAME} on ${RABBITMQ_VHOST}"
rabbitmqadmin_cli \
  declare permission \
  vhost="${RABBITMQ_VHOST}" \
  user="${RABBITMQ_USERNAME}" \
  configure=".*" \
  write=".*" \
  read=".*"

if [ ! -z "$RABBITMQ_AUXILIARY_CONFIGURATION" ]
then
  echo "Applying additional configuration"
  echo "${RABBITMQ_AUXILIARY_CONFIGURATION}" > /tmp/rmq_definitions.json
  rabbitmqadmin_cli import /tmp/rmq_definitions.json
fi

{{- end }}
