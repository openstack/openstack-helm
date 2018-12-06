#!/bin/bash

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

set -ex

#NOTE: This function tests keystone based auth. It uses ceph_config_helper
#container image that has openstack and ceph installed
function rgw_keystone_bucket_validation ()
{
  echo "function: rgw_keystone_bucket_validation"
  openstack service list

  echo "--> creating openstack_test_container container"
  openstack container create 'openstack_test_container'

  echo "--> rgw bucket list"
  radosgw-admin bucket list

  all_buckets_stats=$(radosgw-admin bucket stats --format json)
  bucket_stat=$(echo $all_buckets_stats | jq -c '.[] | select(.bucket | contains("openstack_test_container"))')
  if [[ -z ${bucket_stat} ]]; then
    echo "--> rgw bucket openstack_test_container not found"
    exit 1
  else
    echo "--> rgw bucket openstack_test_container found"

    echo "--> deleting openstack_test_container container"
    openstack container delete openstack_test_container

    echo "--> bucket list after deleting container"
    radosgw-admin bucket list
  fi
}

#NOTE: This function tests s3 based auto. It uses ceph_rgw container image which has
# s3cmd util install
function rgw_s3_bucket_validation ()
{
  echo "function: rgw_s3_bucket_validation"

  bucket=s3://rgw-test-bucket
  create_bucket_output=$(s3cmd mb $bucket --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate)

  if [ $? -eq 0 ]; then
    echo "Bucket $bucket created"
    echo "Hello world!" > /tmp/hello.txt

    s3cmd put /tmp/hello.txt $bucket --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File uploaded to bucket"
    fi

    s3cmd get s3://rgw-test-bucket/hello.txt -> /tmp/output.txt --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File downloaded from bucket"
    fi

    content=$(cat /tmp/output.txt)
    echo $content
    if [ "Hello" == "${content}" ]; then
      echo "Content matches from downloaded file using s3cmd"
    fi

    s3cmd ls $bucket --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    fi

    s3cmd del s3://rgw-test-bucket/hello.txt --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File from bucket is deleted"
    fi

    s3cmd del --recursive --force $bucket --host=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-encrypt --no-check-certificate
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "Bucket is deleted"
    fi

  else
    echo "Error during s3cmd execution"
    exit 1
  fi
}

if [ {{ .Values.conf.rgw_ks.enabled }} == true ];
then
  echo "--> Keystone is enabled. Calling function to test keystone based auth "
  rgw_keystone_bucket_validation
fi

if [ {{ .Values.conf.rgw_s3.enabled }} == true ];
then
  echo "--> S3 is enabled. Calling function to test S2 based auth "
  rgw_s3_bucket_validation
fi

