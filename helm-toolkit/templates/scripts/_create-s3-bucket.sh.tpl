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
{{- define "helm-toolkit.scripts.create_s3_bucket" }}
#!/bin/bash
set -e
CONNECTION_ARGS="--host=$RGW_HOST --host-bucket=$RGW_HOST"
if [ "$RGW_PROTO" = "http" ]; then
  CONNECTION_ARGS+=" --no-ssl"
else
  CONNECTION_ARGS+=" --no-check-certificate"
fi
ADMIN_AUTH_ARGS=" --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY"
USER_AUTH_ARGS=" --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY"
function check_rgw_s3_bucket () {
  s3cmd $CONNECTION_ARGS $USER_AUTH_ARGS ls s3://$S3_BUCKET
}
function create_rgw_s3_bucket () {
  s3cmd $CONNECTION_ARGS $ADMIN_AUTH_ARGS mb s3://$S3_BUCKET
}
function modify_bucket_acl () {
  s3cmd $CONNECTION_ARGS $ADMIN_AUTH_ARGS setacl s3://$S3_BUCKET --acl-grant=read:$S3_USERNAME --acl-grant=write:$S3_USERNAME
}
check_rgw_s3_bucket || ( create_rgw_s3_bucket && modify_bucket_acl )
{{- end }}