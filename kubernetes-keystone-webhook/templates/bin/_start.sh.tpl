#!/bin/sh

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

set -xe

exec /bin/k8s-keystone-auth \
  --tls-cert-file /opt/kubernetes-keystone-webhook/pki/tls.crt \
  --tls-private-key-file /opt/kubernetes-keystone-webhook/pki/tls.key \
  --keystone-policy-file /etc/kubernetes-keystone-webhook/policy.json \
  --keystone-url {{ tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
