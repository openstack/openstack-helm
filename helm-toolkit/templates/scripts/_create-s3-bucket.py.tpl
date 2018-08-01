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
#!/usr/bin/env python

import os
import sys
import logging
import rgwadmin
import rgwadmin.exceptions

# Create logger, console handler and formatter
logger = logging.getLogger('OpenStack-Helm S3 Bucket')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get S3 admin user's access key
if "S3_ADMIN_ACCESS_KEY" in os.environ:
  access_key = os.environ['S3_ADMIN_ACCESS_KEY']
  logger.info('Found S3 admin access key')
else:
  logger.critical('S3 admin access key environment variable not set')
  sys.exit(1)

# Get S3 admin user's secret key
if "S3_ADMIN_SECRET_KEY" in os.environ:
  secret_key = os.environ['S3_ADMIN_SECRET_KEY']
  logger.info('Found S3 admin secret key')
else:
  logger.critical('S3 admin secret key environment variable not set')
  sys.exit(1)

# Get RGW S3 host endpoint
if "RGW_HOST" in os.environ:
  server = os.environ['RGW_HOST']
  logger.info('Found RGW S3 host endpoint')
else:
  logger.critical('RGW S3 host endpoint environment variable not set')
  sys.exit(1)

# Get name of S3 user to link to bucket
if "S3_USERNAME" in os.environ:
  s3_user = os.environ['S3_USERNAME']
  logger.info('Found S3 user name')
else:
  logger.critical('S3 user name environment variable not set')
  sys.exit(1)

# Get name of bucket to create for user link
if "S3_BUCKET" in os.environ:
  s3_bucket = os.environ['S3_BUCKET']
  logger.info('Found S3 bucket name')
else:
  logger.critical('S3 bucket name environment variable not set')
  sys.exit(1)

try:
  rgw_admin = rgwadmin.RGWAdmin(access_key, secret_key, server, secure=False)
  try:
    rgw_admin.get_bucket(bucket=s3_bucket,uid=s3_user)
  except (rgwadmin.exceptions.NoSuchBucket, rgwadmin.exceptions.NoSuchKey), e:
    rgw_admin.create_bucket(bucket=s3_bucket)
    bucket = rgw_admin.get_bucket(bucket=s3_bucket)
    bucket_id = bucket['id']
    rgw_admin.link_bucket(bucket=s3_bucket, bucket_id=bucket_id, uid=s3_user)
    logger.info("Created bucket {} and linked it to user {}".format(s3_bucket, s3_user))
    sys.exit(0)
  else:
    logger.info("The bucket {} exists for user {}! Exiting without creating a new bucket!".format(s3_bucket, s3_user))
except rgwadmin.exceptions.InvalidArgument:
  logger.critical("Invalid arguments supplied for rgwadmin connection. Please check your s3 keys and endpoint")
  sys.exit(1)

{{- end }}
