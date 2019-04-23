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

# Note: not using set -e because more elaborate error handling is required.
set -x

BACKUPS_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/current

# Create the working backups directory if the other container didn't already,
# and if this container creates it first, ensure that permissions are writable
# for the other container (running as "postgres" user) in the same "postgres"
# group.
mkdir -p $BACKUPS_DIR || log_backup_error_exit "Cannot create directory ${BACKUPS_DIR}!" 1
chmod 775 $BACKUPS_DIR

source /tmp/common_backup_restore.sh

#Send backup file to storage
send_to_storage() {
  FILEPATH=$1
  FILE=$2

  CONTAINER_NAME={{ .Values.conf.backup.remote_backup.container_name }}

  # Grab the list of containers on the remote site
  RESULT=$(openstack container list 2>&1)

  if [[ $? == 0 ]]
  then
    echo $RESULT | grep $CONTAINER_NAME
    if [[ $? != 0 ]]
    then
      # Create the container
      openstack container create $CONTAINER_NAME || log ERROR postgresql_backup "Cannot create container ${CONTAINER_NAME}!"
      openstack container show $CONTAINER_NAME
      if [[ $? != 0 ]]
      then
        log ERROR postgresql_backup "Error retrieving container $CONTAINER_NAME after creation."
        return 1
      fi
    fi
  else
    echo $RESULT | grep "HTTP 401"
    if [[ $? == 0 ]]
    then
      log ERROR postgresql_backup "Could not access keystone: HTTP 401"
      return 1
    else
      echo $RESULT | grep "ConnectionError"
      if [[ $? == 0 ]]
      then
        log ERROR postgresql_backup "Could not access keystone: ConnectionError"
        # In this case, keystone or the site/node may be temporarily down.
        # Return slightly different error code so the calling code can retry
        return 2
      else
        log ERROR postgresql_backup "Could not get container list: ${RESULT}"
        return 1
      fi
    fi
  fi

  # Create an object to store the file
  openstack object create --name $FILE $CONTAINER_NAME $FILEPATH/$FILE || log ERROR postgresql_backup "Cannot create container object ${FILE}!"
  openstack object show $CONTAINER_NAME $FILE
  if [[ $? != 0 ]]
  then
    log ERROR postgresql_backup "Error retrieving container object $FILE after creation."
    return 1
  fi

  log INFO postgresql_backup "Created file $FILE in container $CONTAINER_NAME successfully."
  return 0
}

if {{ .Values.conf.backup.remote_backup.enabled }}
then
  WAIT_FOR_BACKUP_TIMEOUT=1800
  WAIT_FOR_RGW_AVAIL_TIMEOUT=1800

  # Wait until a backup file is ready to ship to RGW, or until we time out.
  DONE=false
  TIMEOUT_EXP=$(( $(date +%s) + $WAIT_FOR_BACKUP_TIMEOUT ))
  while [[ $DONE == "false" ]]
  do
    log INFO postgresql_backup "Waiting for a backup file to be written to the disk."
    sleep 5
    DELTA=$(( TIMEOUT_EXP - $(date +%s) ))
    ls -l ${BACKUPS_DIR}/backup_completed
    if [[ $? -eq 0 ]]
    then
      DONE=true
    elif [[ $DELTA -lt 0 ]]
    then
      DONE=true
    fi
  done

  log INFO postgresql_backup "Done waiting."
  FILE_TO_SEND=$(ls $BACKUPS_DIR/*.tar.gz)

  ERROR_SEEN=false

  if [[ $FILE_TO_SEND != "" ]]
  then
    if [[ $(echo $FILE_TO_SEND | wc -w) -gt 1 ]]
    then
      # There should only be one backup file to send - this is an error
      log_backup_error_exit "More than one backup file found (${FILE_TO_SEND}) - can only handle 1!" 1
    fi

    # Get just the filename from the file (strip the path)
    FILE=$(basename $FILE_TO_SEND)

    log INFO postgresql_backup "Backup file ${BACKUPS_DIR}/${FILE} found."

    DONE=false
    TIMEOUT_EXP=$(( $(date +%s) + $WAIT_FOR_RGW_AVAIL_TIMEOUT ))
    while [[ $DONE == "false" ]]
    do
      # Store the new archive to the remote backup storage facility.
      send_to_storage $BACKUPS_DIR $FILE

      # Check if successful
      if [[ $? -eq 0 ]]
      then
        log INFO postgresql_backup "Backup file ${BACKUPS_DIR}/${FILE} successfully sent to RGW. Deleting from current backup directory."
        DONE=true
      elif [[ $? -eq 2 ]]
      then
        # Temporary failure occurred. We need to retry if we haven't timed out
        log WARN postgresql_backup "Backup file ${BACKUPS_DIR}/${FILE} could not be sent to RGW due to connection issue."
        DELTA=$(( TIMEOUT_EXP - $(date +%s) ))
        if [[ $DELTA -lt 0 ]]
        then
          DONE=true
          log ERROR postgresql_backup "Timed out waiting for RGW to become available."
          ERROR_SEEN=true
        else
          log INFO postgresql_backup "Sleeping 30 seconds waiting for RGW to become available..."
          sleep 30
          log INFO postgresql_backup "Retrying..."
        fi
      else
        log ERROR postgresql_backup "Backup file ${BACKUPS_DIR}/${FILE} could not be sent to the RGW."
        ERROR_SEEN=true
        DONE=true
      fi
    done
  else
    log ERROR postgresql_backup "No backup file found in $BACKUPS_DIR."
    ERROR_SEEN=true
  fi

  if [[ $ERROR_SEEN == "true" ]]
  then
    log ERROR postgresql_backup "Errors encountered. Exiting."
    exit 1
  fi

  # At this point, we should remove the files in current dir.
  # If an error occurred, then we need the file to remain there for future
  # container restarts, and maybe it will eventually succeed.
  rm -rf $BACKUPS_DIR/*

  #Only delete an old archive after a successful archive
  if [ "${POSTGRESQL_BACKUP_DAYS_TO_KEEP}" -gt 0 ]
  then
    log INFO postgresql_backup "Deleting backups older than ${POSTGRESQL_BACKUP_DAYS_TO_KEEP} days"
    BACKUP_FILES=/tmp/backup_files
    PG_BACKUP_FILES=/tmp/pg_backup_files

    openstack object list $CONTAINER_NAME > $BACKUP_FILES
    if [[ $? != 0 ]]
    then
      log_backup_error_exit "Could not obtain a list of current backup files in the RGW" 1
    fi

    # Filter out other types of files like mariadb, etcd backupes etc..
    cat $BACKUP_FILES | grep postgres | grep $POSTGRESQL_POD_NAMESPACE | awk '{print $2}' > $PG_BACKUP_FILES

    for ARCHIVE_FILE in $(cat $PG_BACKUP_FILES)
    do
      ARCHIVE_DATE=$( echo $ARCHIVE_FILE | awk -F/ '{print $NF}' | cut -d'.' -f 4)
      if [ "$(seconds_difference ${ARCHIVE_DATE})" -gt "$((${POSTGRESQL_BACKUP_DAYS_TO_KEEP}*86400))" ]
      then
        log INFO postgresql_backup "Deleting file ${ARCHIVE_FILE} from the RGW"
        openstack object delete $CONTAINER_NAME $ARCHIVE_FILE || log_backup_error_exit "Cannot delete container object ${ARCHIVE_FILE}!" 1
      fi
    done
  fi
else
  log INFO postgresql_backup "Remote backup is not enabled"
  exit 0
fi
