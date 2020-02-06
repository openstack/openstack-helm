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

export PGPASSWORD=$(cat /etc/postgresql/admin_user.conf \
                    | grep postgres | awk -F: '{print $5}')

set -x

PG_DUMPALL_OPTIONS=$POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS
BACKUPS_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/current
ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive
LOG_FILE=/tmp/dberror.log
PG_DUMPALL="pg_dumpall \
              $POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS \
              -U $POSTGRESQL_BACKUP_USER \
              -h $POSTGRESQL_SERVICE_HOST"

#Get the day delta since the archive file backup
seconds_difference() {
  archive_date=$( date --date="$1" +%s )
  if [ "$?" -ne 0 ]
  then
    second_delta=0
  fi
  current_date=$( date +%s )
  second_delta=$(($current_date-$archive_date))
  if [ "$second_delta" -lt 0 ]
  then
    second_delta=0
  fi
  echo $second_delta
}

#Create backups directory if it does not exists.
mkdir -p $BACKUPS_DIR $ARCHIVE_DIR

#Dump all databases
DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")
$PG_DUMPALL --file=$BACKUPS_DIR/postgres.all.sql 2>>$LOG_FILE
if [[ $? -eq 0 && -s "$BACKUPS_DIR/postgres.all.sql" ]]
then
  #Archive the current databases files
  pushd $BACKUPS_DIR 1>/dev/null
  tar zcvf $ARCHIVE_DIR/postgres.all.${DATE}.tar.gz *
  ARCHIVE_RET=$?
  popd 1>/dev/null
  #Remove the current backup
  if [ -d $BACKUPS_DIR ]
  then
    rm -rf $BACKUPS_DIR/*.sql
  fi
else
  #TODO: This can be convert into mail alert of alert send to a monitoring system
  echo "Backup of postgresql failed and need attention."
  cat $LOG_FILE
  exit 1
fi

#Only delete the old archive after a successful archive
if [ $ARCHIVE_RET -eq 0 ]
then
  if [ "$POSTGRESQL_BACKUP_DAYS_TO_KEEP" -gt 0 ]
  then
    echo "Deleting backups older than $POSTGRESQL_BACKUP_DAYS_TO_KEEP days"
    if [ -d $ARCHIVE_DIR ]
    then
      for archive_file in $(ls -1 $ARCHIVE_DIR/*.gz)
      do
        archive_date=$( echo $archive_file | awk -F/ '{print $NF}' | cut -d'.' -f 3)
        if [ "$(seconds_difference $archive_date)" -gt "$(($POSTGRESQL_BACKUP_DAYS_TO_KEEP*86400))" ]
        then
          rm -rf $archive_file
        fi
      done
    fi
  fi
fi

