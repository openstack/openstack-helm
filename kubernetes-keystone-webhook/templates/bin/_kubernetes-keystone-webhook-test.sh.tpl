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

TOKEN="$(openstack token issue -f value -c id)"
cat << EOF | curl -kvs -XPOST -d @- "${WEBHOOK_URL}" | python -mjson.tool
{
    "apiVersion": "authentication.k8s.io/v1beta1",
    "kind": "TokenReview",
    "metadata": {
        "creationTimestamp": null
    },
    "spec": {
        "token": "$TOKEN"
    }
}
EOF
