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

# This is needed to get the postgresql admin password
# Turn off tracing so the password doesn't get printed.
set +x
export PGPASSWORD=$(cat /etc/postgresql/admin_user.conf \
                    | grep postgres | awk -F: '{print $5}')

# Note: not using set -e in this script because more elaborate error handling
# is needed.
set -x

source /tmp/backup_main.sh

# Export the variables required by the framework
#  Note: REMOTE_BACKUP_ENABLED and CONTAINER_NAME are already exported
export DB_NAMESPACE=${POSTGRESQL_POD_NAMESPACE}
export DB_NAME="postgres"
export LOCAL_DAYS_TO_KEEP=$POSTGRESQL_LOCAL_BACKUP_DAYS_TO_KEEP
export REMOTE_DAYS_TO_KEEP=$POSTGRESQL_REMOTE_BACKUP_DAYS_TO_KEEP
export ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${DB_NAMESPACE}/${DB_NAME}/archive

# This function dumps all database files to the $TMP_DIR that is being
# used as a staging area for preparing the backup tarball. Log file to
# write to is passed in - the framework will expect that file to have any
# errors that occur if the database dump is unsuccessful, so that it can
# add the file contents to its own logs.
dump_databases_to_directory() {
  TMP_DIR=$1
  LOG_FILE=$2

  PG_DUMPALL_OPTIONS=$(echo $POSTGRESQL_BACKUP_PG_DUMPALL_OPTIONS | sed 's/"//g')
  PG_DUMPALL="pg_dumpall \
                $PG_DUMPALL_OPTIONS \
                -U $POSTGRESQL_ADMIN_USER \
                -h $POSTGRESQL_SERVICE_HOST"

  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all

  cd $TMP_DIR

  #Dump all databases
  $PG_DUMPALL --file=${TMP_DIR}/${SQL_FILE}.sql 2>>$LOG_FILE
  if [[ $? -eq 0 && -s "${TMP_DIR}/${SQL_FILE}.sql" ]]; then
    log INFO postgresql_backup "Databases dumped successfully."
    return 0
  else
    log ERROR "Backup of the postgresql database failed and needs attention."
    return 1
  fi
}

# Call main program to start the database backup
backup_databases
