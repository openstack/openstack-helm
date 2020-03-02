#!/bin/bash

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

export PGPASSWORD=$(cat /etc/postgresql/admin_user.conf \
                    | grep postgres | awk -F: '{print $5}')

# Note: not using set -e in this script because more elaborate error handling
# is needed.
set -x

PG_DUMPALL_OPTIONS=$POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS
TMP_DIR=/tmp/pg_backup
BACKUPS_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/current
ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive
LOG_FILE=/tmp/dberror.log
PG_DUMPALL="pg_dumpall \
              $POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS \
              -U $POSTGRESQL_BACKUP_USER \
              -h $POSTGRESQL_SERVICE_HOST"

source /tmp/common_backup_restore.sh

# Create necessary directories if they do not exist.
mkdir -p $BACKUPS_DIR || log_backup_error_exit "Cannot create directory ${BACKUPS_DIR}!"
mkdir -p $ARCHIVE_DIR || log_backup_error_exit "Cannot create directory ${ARCHIVE_DIR}!"
mkdir -p $TMP_DIR || log_backup_error_exit "Cannot create directory ${TMP_DIR}!"

# Remove temporary directory contents.
rm -rf $BACKUPS_DIR/* || log_backup_error_exit "Cannot clear ${BACKUPS_DIR} directory contents!"
rm -rf $TMP_DIR/* || log_backup_error_exit "Cannot clear ${TMP_DIR} directory contents!"

NOW=$(date +"%Y-%m-%dT%H:%M:%SZ")
SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all
TARBALL_FILE=${SQL_FILE}.${NOW}.tar.gz

cd $TMP_DIR || log_backup_error_exit "Cannot change to directory $TMP_DIR"

rm -f $LOG_FILE

#Dump all databases
$PG_DUMPALL --file=${TMP_DIR}/${SQL_FILE}.sql 2>>$LOG_FILE
if [[ $? -eq 0 && -s "${TMP_DIR}/${SQL_FILE}.sql" ]]
then
  log INFO postgresql_backup "Databases dumped successfully. Creating tarball..."

  #Archive the current database files
  tar zcvf $ARCHIVE_DIR/$TARBALL_FILE *
  if [[ $? -ne 0 ]]
  then
    log_backup_error_exit "Backup tarball could not be created."
  fi

  log INFO postgresql_backup "Tarball $TARBALL_FILE created successfully."

  # Remove the sql files as they are no longer needed.
  rm -rf $TMP_DIR/*

  if {{ .Values.conf.backup.remote_backup.enabled }}
  then
    # Copy the tarball back to the BACKUPS_DIR so that the other container
    # can access it for sending it to remote storage.
    cp $ARCHIVE_DIR/$TARBALL_FILE $BACKUPS_DIR/$TARBALL_FILE

    if [[ $? -ne 0 ]]
    then
      log_backup_error_exit "Backup tarball could not be copied to backup directory ${BACKUPS_DIR}."
    fi

    # Sleep for a few seconds to allow the file system to get caught up...also to
    # help prevent race condition where the other container grabs the backup_completed
    # token and the backup file hasn't completed writing to disk.
    sleep 30

    # Note: this next line is the trigger that tells the other container to
    # start sending to remote storage. After this backup is sent to remote
    # storage, the other container will delete the "current" backup.
    touch $BACKUPS_DIR/backup_completed
  else
    # Remote backup is not enabled. This is ok; at least we have a local backup.
    log INFO postgresql_backup "Skipping remote backup, as it is not enabled."
  fi
else
  cat $LOG_FILE
  rm $LOG_FILE
  log_backup_error_exit "Backup of the postgresql database failed and needs attention."
fi

#Only delete the old archive after a successful archive
if [ "$POSTGRESQL_BACKUP_DAYS_TO_KEEP" -gt 0 ]
then
  log INFO postgresql_backup "Deleting backups older than ${POSTGRESQL_BACKUP_DAYS_TO_KEEP} days"
  if [ -d $ARCHIVE_DIR ]
  then
    for ARCHIVE_FILE in $(ls -1 $ARCHIVE_DIR/*.gz)
    do
      ARCHIVE_DATE=$( echo $ARCHIVE_FILE | awk -F/ '{print $NF}' | cut -d'.' -f 4)
      if [ "$(seconds_difference $ARCHIVE_DATE)" -gt "$(($POSTGRESQL_BACKUP_DAYS_TO_KEEP*86400))" ]
      then
        log INFO postgresql_backup "Deleting file $ARCHIVE_FILE."
        rm -rf $ARCHIVE_FILE
        if [[ $? -ne 0 ]]
        fhen
          rm -rf $BACKUPS_DIR/*
          log_backup_error_exit "Cannot remove ${ARCHIVE_FILE}"
        fi
      else
        log INFO postgresql_backup "Keeping file ${ARCHIVE_FILE}."
      fi
    done
  fi
fi

# Turn off trace just for a clearer printout of backup status - for manual backups, mainly.
set +x
echo "=================================================================="
echo "Backup successful!"
echo "Backup archive name: $TARBALL_FILE"
echo "=================================================================="
