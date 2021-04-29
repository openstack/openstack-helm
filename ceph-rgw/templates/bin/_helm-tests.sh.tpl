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

tmpdir=$(mktemp -d)
declare -a objects_list
total_objects=10

#NOTE: This function tests keystone based auth. It uses ceph_config_helper
#container image that has openstack and ceph installed
function rgw_keystone_bucket_validation ()
{
  echo "function: rgw_keystone_bucket_validation"
  openstack service list

  bucket_stat="$(openstack container list | grep openstack_test_container || true)"
  if [[ -n "${bucket_stat}" ]]; then
    echo "--> deleting openstack_test_container container"
    openstack container delete --recursive openstack_test_container
  fi

  echo "--> creating openstack_test_container container"
  openstack container create 'openstack_test_container'

  echo "--> list containers"
  openstack container list

  bucket_stat="$(openstack container list | grep openstack_test_container || true)"
  if [[ -z "${bucket_stat}" ]]; then
    echo "--> container openstack_test_container not found"
    exit 1
  else
    echo "--> container openstack_test_container found"

    for i in $(seq $total_objects); do
      openstack object create --name "${objects_list[$i]}" openstack_test_container "${objects_list[$i]}"
      echo "--> file ${objects_list[$i]} uploaded to openstack_test_container container"
    done

    echo "--> list contents of openstack_test_container container"
    openstack object list openstack_test_container

    for i in $(seq $total_objects); do
      echo "--> downloading ${objects_list[$i]} object from openstack_test_container container to ${objects_list[$i]}_object${i} file"
      openstack object save --file "${objects_list[$i]}_object${i}" openstack_test_container "${objects_list[$i]}"
      check_result $? "Error during openstack CLI execution" "The object downloaded successfully"

      echo "--> comparing files: ${objects_list[$i]} and ${objects_list[$i]}_object${i}"
      cmp "${objects_list[$i]}" "${objects_list[$i]}_object${i}"
      check_result $? "The files are not equal" "The files are equal"

      echo "--> deleting ${objects_list[$i]} object from openstack_test_container container"
      openstack object delete openstack_test_container "${objects_list[$i]}"
      check_result $? "Error during openstack CLI execution" "The object deleted successfully"
    done

    echo "--> deleting openstack_test_container container"
    openstack container delete --recursive openstack_test_container

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
{{- if .Values.manifests.certificates }}
  params="--host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --ca-certs=/etc/tls/ca.crt"
{{- else }}
  params="--host=$RGW_HOST --host-bucket=$RGW_HOST --access_key=$S3_ADMIN_ACCESS_KEY --secret_key=$S3_ADMIN_SECRET_KEY --no-ssl"
{{- end }}

  bucket_stat="$(s3cmd ls $params | grep ${bucket} || true)"
  if [[ -n "${bucket_stat}" ]]; then
    s3cmd del --recursive --force $bucket $params
    check_result $? "Error during s3cmd execution" "Bucket is deleted"
  fi

  s3cmd mb $bucket $params
  if [ $? -eq 0 ]; then
    echo "Bucket $bucket created"

    for i in $(seq $total_objects); do
      s3cmd put "${objects_list[$i]}" $bucket $params
      check_result $? "Error during s3cmd execution" "File ${objects_list[$i]##*/} uploaded to bucket"
    done

    s3cmd ls $bucket $params
    check_result $? "Error during s3cmd execution" "Got list of objects"

    for i in $(seq $total_objects); do
      s3cmd get "${bucket}/${objects_list[$i]##*/}" -> "${objects_list[$i]}_s3_object${i}" $params
      check_result $? "Error during s3cmd execution" "File ${objects_list[$i]##*/} downloaded from bucket"

      echo "Comparing files: ${objects_list[$i]} and ${objects_list[$i]}_s3_object${i}"
      cmp "${objects_list[$i]}" "${objects_list[$i]}_s3_object${i}"
      check_result $? "The files are not equal" "The files are equal"

      s3cmd del "${bucket}/${objects_list[$i]##*/}" $params
      check_result $? "Error during s3cmd execution" "File from bucket is deleted"
    done

    s3cmd del --recursive --force $bucket $params
    check_result $? "Error during s3cmd execution" "Bucket is deleted"

  else
    echo "Error during s3cmd execution"
    exit 1
  fi
}

function check_result ()
{
  red='\033[0;31m'
  green='\033[0;32m'
  bw='\033[0m'
  if [ "$1" -ne 0 ]; then
    echo -e "${red}$2${bw}"
    exit 1
  else
    echo -e "${green}$3${bw}"
  fi
}

function prepare_objects ()
{
  echo "Preparing ${total_objects} files for test"
  for i in $(seq $total_objects); do
    objects_list[$i]="$(mktemp -p "$tmpdir")"
    echo "${objects_list[$i]}"
    dd if=/dev/urandom of="${objects_list[$i]}" bs=1M count=8
  done
}

prepare_objects

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
