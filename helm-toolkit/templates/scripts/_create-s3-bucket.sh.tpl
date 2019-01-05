{{/*
Copyright 2017 The Openstack-Helm Authors.

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

function create_rgw_s3_bucket ()
{
  create_bucket=$(s3cmd mb s3://$S3_BUCKET --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate)
  if [ $? -eq 0 ]; then
    echo "Bucket $S3_BUCKET created"
  else
    echo "Error trying to create bucket $S3_BUCKET"
    exit 1
  fi
}

function modify_bucket_acl ()
{
  modify_acl=$(s3cmd setacl s3://$S3_BUCKET --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate --acl-grant=read:$S3_USERNAME --acl-grant=write:$S3_USERNAME)
  if [ $? -eq 0 ]; then
    echo "Bucket $S3_BUCKET ACL updated"
  else
    echo "Error trying to update bucket $S3_BUCKET ACL"
    exit 1
  fi
}

create_rgw_s3_bucket
modify_bucket_acl

{{- end }}
