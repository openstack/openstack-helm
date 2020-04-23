#!/bin/bash

# Copyright 2018 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -x

RESTORE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/restore
ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive

source /tmp/common_backup_restore.sh

# Keep processing requests for the life of the pod.
while true
do
  # Wait until a restore request file is present on the disk
  echo "Waiting for a restore request..."
  NO_TIMEOUT=true
  wait_for_file $RESTORE_DIR/*_request $NO_TIMEOUT

  echo "Done waiting. Request received"

  CONTAINER_NAME={{ .Values.conf.backup.remote_backup.container_name }}

  if [[ -e $RESTORE_DIR/archive_listing_request ]]
  then
    # We've finished consuming the request, so delete the request file.
    rm -rf $RESTORE_DIR/*_request

    openstack container show $CONTAINER_NAME
    if [[ $? -eq 0 ]]
    then
      # Get the list, ensureing that we only pick up postgres backups from the
      # requested namespace
      openstack object list $CONTAINER_NAME | grep postgres | grep $POSTGRESQL_POD_NAMESPACE | awk '{print $2}' > $RESTORE_DIR/archive_list_response
      if [[ $? != 0 ]]
      then
        echo "Container object listing could not be obtained." >> $RESTORE_DIR/archive_list_error
      else
        echo "Archive listing successfully retrieved."
      fi
    else
      echo "Container $CONTAINER_NAME does not exist." >> $RESTORE_DIR/archive_list_error
    fi
  elif [[ -e $RESTORE_DIR/get_archive_request ]]
  then
    ARCHIVE=`cat $RESTORE_DIR/get_archive_request`

    echo "Request for archive $ARCHIVE received."

    # We've finished consuming the request, so delete the request file.
    rm -rf $RESTORE_DIR/*_request

    openstack object save --file $RESTORE_DIR/$ARCHIVE $CONTAINER_NAME $ARCHIVE
    if [[ $? != 0 ]]
    then
      echo "Archive $ARCHIVE could not be retrieved." >> $RESTORE_DIR/archive_error
    else
      echo "Archive $ARCHIVE successfully retrieved."
    fi

    # Signal to the other container that the archive is available.
    touch $RESTORE_DIR/archive_response
  else
    rm -rf $RESTORE_DIR/*_request
    echo "Invalid request received."
  fi

  sleep 5
done
