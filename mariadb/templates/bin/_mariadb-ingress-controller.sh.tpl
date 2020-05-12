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
  find /tmp/ -maxdepth 1 -writable | grep -v "^/tmp/$" | xargs -L1 -r rm -rfv
  exec /usr/bin/dumb-init \
      /nginx-ingress-controller \
      --force-namespace-isolation \
      --watch-namespace ${POD_NAMESPACE} \
      --election-id=${RELEASE_NAME} \
      --ingress-class=${INGRESS_CLASS} \
      --default-backend-service=${POD_NAMESPACE}/${ERROR_PAGE_SERVICE} \
      --configmap=${POD_NAMESPACE}/mariadb-ingress-conf \
      --enable-ssl-chain-completion=false \
      --tcp-services-configmap=${POD_NAMESPACE}/mariadb-services-tcp
}


function stop () {
  kill -TERM 1
}

$COMMAND
