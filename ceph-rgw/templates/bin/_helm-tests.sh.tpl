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

  echo "--> list containers"
  openstack container list

  bucket_stat=$(openstack container list | grep "openstack_test_container")
  if [[ -z ${bucket_stat} ]]; then
    echo "--> container openstack_test_container not found"
    exit 1
  else
    echo "--> container openstack_test_container found"
    echo "Hello world!" | tee /tmp/hello.txt

    echo "--> file uploaded to openstack_test_container container"
    openstack object create --name hello openstack_test_container /tmp/hello.txt

    echo "--> list contents of openstack_test_container container"
    openstack object list openstack_test_container

    echo "--> download object from openstack_test_container container"
    openstack object save --file /tmp/output.txt openstack_test_container hello
    if [ $? -ne 0 ]; then
      echo "Error during openstack CLI execution"
      exit 1
    else
      echo "File downloaded from container"
    fi

    content=$(cat /tmp/output.txt)
    if [ "Hello world!" == "${content}" ]; then
      echo "Content matches from downloaded file using openstack CLI"
    else
      echo "Content is mismatched from downloaded file using openstack CLI"
      exit 1
    fi

    echo "--> deleting object from openstack_test_container container"
    openstack object delete openstack_test_container hello
    if [ $? -ne 0 ]; then
      echo "Error during openstack CLI execution"
      exit 1
    else
      echo "File from container is deleted"
    fi

    echo "--> deleting openstack_test_container container"
    openstack container delete openstack_test_container

    echo "--> bucket list after deleting container"
    openstack container list
  fi
}

#NOTE: This function tests s3 based auto. It uses ceph_rgw container image which has
# s3cmd util install
function rgw_s3_bucket_validation ()
{
  echo "function: rgw_s3_bucket_validation"

  bucket=s3://rgw-test-bucket
  create_bucket_output=$(s3cmd mb $bucket --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl)

  if [ $? -eq 0 ]; then
    echo "Bucket $bucket created"
    echo "Hello world!" | tee /tmp/hello.txt

    s3cmd put /tmp/hello.txt $bucket --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File uploaded to bucket"
    fi

    s3cmd get s3://rgw-test-bucket/hello.txt -> /tmp/output.txt --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File downloaded from bucket"
    fi

    content=$(cat /tmp/output.txt)
    if [ "Hello world!" == "${content}" ]; then
      echo "Content matches from downloaded file using s3cmd"
    else
      echo "Content is mismatched from downloaded file using s3cmd"
      exit 1
    fi

    s3cmd ls $bucket --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    fi

    s3cmd del s3://rgw-test-bucket/hello.txt --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl
    if [ $? -ne 0 ]; then
      echo "Error during s3cmd execution"
      exit 1
    else
      echo "File from bucket is deleted"
    fi

    s3cmd del --recursive --force $bucket --host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl
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

if [ "$RGW_TEST_TYPE" == RGW_KS ];
then
  echo "--> Keystone is enabled. Calling function to test keystone based auth "
  rgw_keystone_bucket_validation
fi

if [ "$RGW_TEST_TYPE" == RGW_S3 ];
then
  echo "--> S3 is enabled. Calling function to test S3 based auth "
  rgw_s3_bucket_validation
fi
