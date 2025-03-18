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

#!/bin/bash

set -e

function check_rgw_s3_bucket () {
  echo "Checking if bucket exists"
  s3cmd $CONNECTION_ARGS $USER_AUTH_ARGS ls s3://$S3_BUCKET
}

function create_rgw_s3_bucket () {
  echo "Creating bucket"
  s3cmd $CONNECTION_ARGS $S3_BUCKET_OPTS $USER_AUTH_ARGS mb s3://$S3_BUCKET
}

function modify_bucket_acl () {
  echo "Updating bucket ACL"
  s3cmd $CONNECTION_ARGS $USER_AUTH_ARGS setacl s3://$S3_BUCKET --acl-grant=read:$S3_USERNAME --acl-grant=write:$S3_USERNAME
}

ADMIN_AUTH_ARGS=" --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY"

{{- $envAll := . }}
{{- range $bucket := .Values.storage.s3.buckets }}

S3_BUCKET={{ $bucket.name }}
S3_BUCKET_OPTS={{ $bucket.options | default nil | include "helm-toolkit.utils.joinListWithSpace" }}
S3_SSL_OPT={{ $bucket.ssl_connection_option | default "" }}

S3_USERNAME=${{ printf "%s_S3_USERNAME" ( $bucket.client | replace "-" "_" | upper) }}
S3_ACCESS_KEY=${{ printf "%s_S3_ACCESS_KEY" ( $bucket.client | replace "-" "_" | upper) }}
S3_SECRET_KEY=${{ printf "%s_S3_SECRET_KEY" ( $bucket.client | replace "-" "_" | upper) }}

{{- with $client := index $envAll.Values.storage.s3.clients $bucket.client }}

RGW_HOST={{ $client.settings.endpoint | default (tuple "ceph_object_store" "internal" "api" $envAll | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup")  }}
RGW_PROTO={{ $client.settings.protocol | default (tuple "ceph_object_store" "internal" "api" $envAll | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup")   }}

{{- end }}

CONNECTION_ARGS="--host=$RGW_HOST --host-bucket=$RGW_HOST"
if [ "$RGW_PROTO" = "http" ]; then
  CONNECTION_ARGS+=" --no-ssl"
else
  CONNECTION_ARGS+=" $S3_SSL_OPT"
fi

USER_AUTH_ARGS=" --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY"

echo "Creating Bucket $S3_BUCKET at $RGW_HOST"
check_rgw_s3_bucket || ( create_rgw_s3_bucket && modify_bucket_acl )

{{- end }}
