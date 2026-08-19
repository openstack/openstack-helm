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
  awk -F'[//:]' '{print $5}' | \
  sed 's/%/\\x/g' | \
  xargs -0 printf "%b")

# Extract User creadential
RABBITMQ_USERNAME=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $4}')
RABBITMQ_PASSWORD=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $1}' | \
  awk -F'[//:]' '{print $5}' | \
  sed 's/%/\\x/g' | \
  xargs -0 printf "%b")

# Extract User vHost
RABBITMQ_VHOST=$(echo "${RABBITMQ_USER_CONNECTION}" | \
  awk -F'[@]' '{print $2}' | \
  awk -F'[:/]' '{print $3}')
# Resolve vHost to / if no value is set
RABBITMQ_VHOST="${RABBITMQ_VHOST:-/}"

# rabbitmqadmin v2, shipped by the RabbitMQ 4.x management image, is a different
# program from the python v1 tool the 3.x images carry. The grammar changed from
# "declare <noun> key=value" to "<noun> <verb> --flag value", the TLS flags were
# renamed, and were renamed again for TLS. Neither
# version is present in the other's image, so which one to speak is decided by
# which one is installed.
#
# Detection looks at what the program *is*, not at what it prints. Probing the
# grammar with "users --help" does not work: v1 parses options with python's
# option parser, which handles --help globally and exits 0 even for a
# subcommand it does not have, so v1 would be taken for v2. v1 is a python
# script and v2 is a compiled binary, which a shebang distinguishes reliably.
RABBITMQADMIN_PATH="$(command -v rabbitmqadmin || true)"
if [ -n "${RABBITMQADMIN_PATH}" ] && \
   [ "$(head -c 2 "${RABBITMQADMIN_PATH}" 2>/dev/null)" = '#!' ]
then
  RABBITMQADMIN_MAJOR=1
else
  RABBITMQADMIN_MAJOR=2
fi
echo "Detected rabbitmqadmin v${RABBITMQADMIN_MAJOR}"

function rabbitmqadmin_cli () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    if [ -n "$RABBITMQ_X509" ]
    then
      rabbitmqadmin \
        --use-tls \
        --tls-ca-cert-file="${USER_CERT_PATH}/ca.crt" \
        --tls-cert-file="${USER_CERT_PATH}/tls.crt" \
        --tls-key-file="${USER_CERT_PATH}/tls.key" \
        --host="${RABBIT_HOSTNAME}" \
        --port="${RABBIT_PORT}" \
        --username="${RABBITMQ_ADMIN_USERNAME}" \
        --password="${RABBITMQ_ADMIN_PASSWORD}" \
        --non-interactive \
        "$@"
    else
      rabbitmqadmin \
        --host="${RABBIT_HOSTNAME}" \
        --port="${RABBIT_PORT}" \
        --username="${RABBITMQ_ADMIN_USERNAME}" \
        --password="${RABBITMQ_ADMIN_PASSWORD}" \
        --non-interactive \
        "$@"
    fi
  else
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
        "$@"
    else
      rabbitmqadmin \
        --host="${RABBIT_HOSTNAME}" \
        --port="${RABBIT_PORT}" \
        --username="${RABBITMQ_ADMIN_USERNAME}" \
        --password="${RABBITMQ_ADMIN_PASSWORD}" \
        "$@"
    fi
  fi
}

function declare_user () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_cli users declare \
      --name="${1}" --password="${2}" --tags="user"
  else
    rabbitmqadmin_cli declare user \
      name="${1}" password="${2}" tags="user"
  fi
}

function delete_user () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_cli users delete --name="${1}"
  else
    rabbitmqadmin_cli delete user name="${1}"
  fi
}

function declare_vhost () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_cli vhosts declare --name="${1}"
  else
    rabbitmqadmin_cli declare vhost name="${1}"
  fi
}

# In v2 the vhost a permission applies to is the global --vhost flag rather than
# a key of the command.
function declare_permission () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_cli --vhost="${1}" permissions declare \
      --user="${2}" --configure=".*" --write=".*" --read=".*"
  else
    rabbitmqadmin_cli declare permission \
      vhost="${1}" user="${2}" configure=".*" write=".*" read=".*"
  fi
}

function import_definitions () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_cli definitions import --file "${1}"
  else
    rabbitmqadmin_cli import "${1}"
  fi
}

echo "Managing: User: ${RABBITMQ_USERNAME}"
declare_user "${RABBITMQ_USERNAME}" "${RABBITMQ_PASSWORD}"

echo "Deleting Guest User"
delete_user "guest" || true

if [ "${RABBITMQ_VHOST}" != "/" ]
then
  echo "Managing: vHost: ${RABBITMQ_VHOST}"
  declare_vhost "${RABBITMQ_VHOST}"
else
  echo "Skipping root vHost declaration: vHost: ${RABBITMQ_VHOST}"
fi

echo "Managing: Permissions: ${RABBITMQ_USERNAME} on ${RABBITMQ_VHOST}"
declare_permission "${RABBITMQ_VHOST}" "${RABBITMQ_USERNAME}"

if [ ! -z "$RABBITMQ_AUXILIARY_CONFIGURATION" ]
then
  echo "Applying additional configuration"
  echo "${RABBITMQ_AUXILIARY_CONFIGURATION}" > /tmp/rmq_definitions.json
  import_definitions /tmp/rmq_definitions.json
fi

{{- end }}
