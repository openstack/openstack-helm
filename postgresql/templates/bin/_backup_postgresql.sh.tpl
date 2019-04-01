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
export PGPASSFILE=/etc/postgresql/admin_user.conf
PG_DUMPALL_OPTIONS=$POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS
BACKUPS_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/current
ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive
POSTGRESQL_HOST=$(cat /etc/postgresql/admin_user.conf | cut -d: -f 1)
PG_DUMPALL="pg_dumpall -U $POSTGRESQL_BACKUP_USER -h $POSTGRESQL_HOST"

#Delete files
delete_files() {
  files_to_delete=("$@")
  for f in "${files_to_delete[@]}"
  do
    if [ -f $f ]
    then
      echo "Deleting file $f."
      rm -rf $f
    fi
  done
}

#Get the day delta since the archive file backup
days_difference() {
  archive_date=$( date --date="$1" +%s )
  if [ "$?" -ne 0 ]
  then
    day_delta=0
  fi
  current_date=$( date +%s )
  date_delta=$(($current_date-$archive_date))
  if [ "$date_delta" -lt 0 ]
  then
    day_delta=0
  else
    day_delta=$(($date_delta/86400))
  fi
  echo $day_delta
}

#Create backups directory if it does not exists.
mkdir -p $BACKUPS_DIR $ARCHIVE_DIR

#Dump all databases
DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")
pg_dumpall $POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS -U $POSTGRESQL_BACKUP_USER \
   -h  $POSTGRESQL_HOST --file=$BACKUPS_DIR/postgres.all.sql 2>dberror.log
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
  cat dberror.log
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
          if [ "$(days_difference $archive_date)" -gt "$POSTGRESQL_BACKUP_DAYS_TO_KEEP" ]
          then
            rm -rf $archive_file
          fi
        done
      fi
    fi
fi
