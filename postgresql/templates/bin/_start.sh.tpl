#!/usr/bin/env bash

{{/*
Copyright 2019 The Openstack-Helm Authors.

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

function patroni_started() {
  HOST=$1
  PORT=$2
  STATUS=$(timeout 10 bash -c "exec 3<>/dev/tcp/${HOST}/${PORT};
    echo -e \"GET / HTTP/1.1\r\nConnection: close\r\n\" >&3;
    cat <&3 | tail -n1 | grep -o \"running\"")

  [[ x${STATUS} == "xrunning" ]]
}
SVC_FQDN='{{ tuple "postgresql-restapi" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}'
SVC_PORT='{{ tuple "postgresql-restapi" "internal" "restapi" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}'

# This is required because the declarative values.yaml config doesn't
# know the dynamic podIP.  TODO: something more elegant.
sed "s/POD_IP_PATTERN/${PATRONI_KUBERNETES_POD_IP}/g" \
    /tmp/patroni-templated.yaml > \
    /tmp/patroni.yaml

FILE_MADE_BY_PATRONI=${PGDATA}/patroni.dynamic.json
if [[ ! $POD_NAME -eq "postgresql-0" ]]; then

  echo "I am not postgresql pod zero: disabling liveness probe temporarily"
  # disable liveness probe as it may take some time for the pod to come online
  touch /tmp/postgres-disable-liveness-probe

  # During normal upgrades, we just need to turn liveness probes off temporarily
  # for the sake of password rotation - need to bounce all pods at once
  # (overriding RollingUpdate) to avoid deadlock.  This accounts for that.
  sleep 60

  # During initial bootstrapping, we need to sequence 0,1,2
  if [[ ! -e "${FILE_MADE_BY_PATRONI}" ]]; then
    echo "patroni has not been initialized on this node"
    # NOTE: this boolean forces a second check after a delay.  This accounts for a
    # scenario during initial vanilla postgres -> patroni conversion, where
    # a temporary master is brought up, killed off, and then restarted.
    # This can be safely removed in the future, once all clusters are converted.
    WAITED_EXTRA="false"

    while [ ${WAITED_EXTRA} = "false" ]; do
      while ! patroni_started "${SVC_FQDN}" "${SVC_PORT}"; do
        echo "Waiting until a Leader is elected..."
        sleep 5
      done
      # See note above: this code can be removed once all clusters are Patroni.
      if [ ${WAITED_EXTRA} = "false" ]; then
        echo "Leader is up; sleeping to ensure it gets through restarts..."
        sleep 10
        WAITED_EXTRA="true"
      fi
    done
  fi

  rm -fv /tmp/postgres-disable-liveness-probe
fi

exec /usr/bin/python3 /usr/local/bin/patroni /tmp/patroni.yaml
