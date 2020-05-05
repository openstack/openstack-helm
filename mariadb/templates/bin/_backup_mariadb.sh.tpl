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
set -x

source /tmp/backup_main.sh

# Export the variables required by the framework
# Note: REMOTE_BACKUP_ENABLED, STORAGE_POLICY  and CONTAINER_NAME are already
#       exported.
export DB_NAMESPACE=${MARIADB_POD_NAMESPACE}
export DB_NAME="mariadb"
export LOCAL_DAYS_TO_KEEP=${MARIADB_LOCAL_BACKUP_DAYS_TO_KEEP}
export REMOTE_DAYS_TO_KEEP=${MARIADB_REMOTE_BACKUP_DAYS_TO_KEEP}
export ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${DB_NAMESPACE}/${DB_NAME}/archive

# Dump all the database files to existing $TMP_DIR and save logs to $LOG_FILE
dump_databases_to_directory() {
  TMP_DIR=$1
  LOG_FILE=$2

  MYSQL="mysql \
     --defaults-file=/etc/mysql/admin_user.cnf \
     --connect-timeout 10"

  MYSQLDUMP="mysqldump \
     --defaults-file=/etc/mysql/admin_user.cnf"

  MYSQL_DBNAMES=( $($MYSQL --silent --skip-column-names -e \
     "show databases;" | \
     egrep -vi 'information_schema|performance_schema') )

  #check if there is a database to backup, otherwise exit
  if [[ -z "${MYSQL_DBNAMES// }" ]]
  then
    log INFO "There is no database to backup"
    return 0
  fi

  #Create a list of Databases
  printf "%s\n" "${MYSQL_DBNAMES[@]}" > $TMP_DIR/db.list

  #Retrieve and create the GRANT files per DB
  for db in "${MYSQL_DBNAMES[@]}"
  do
    echo $($MYSQL --skip-column-names -e "select concat('show grants for ',user,';') \
          from mysql.db where ucase(db)=ucase('$db');") | \
          sed -r "s/show grants for ([a-zA-Z0-9_-]*)/show grants for '\1'/" | \
          $MYSQL --silent --skip-column-names 2>>$LOG_FILE > $TMP_DIR/${db}_grant.sql
    if [ "$?" -eq 0 ]
    then
      sed -i 's/$/;/' $TMP_DIR/${db}_grant.sql
    else
      log ERROR "Failed to create GRANT files for ${db}"
    fi
  done

  #Dumping the database
  DATE=$(date +'%Y-%m-%dT%H:%M:%SZ')

  SQL_FILE=mariadb.$MARIADB_POD_NAMESPACE.all
  TARBALL_FILE=${SQL_FILE}.${DATE}.tar.gz

  $MYSQLDUMP $MYSQL_BACKUP_MYSQLDUMP_OPTIONS "${MYSQL_DBNAMES[@]}"  \
            > $TMP_DIR/${SQL_FILE}.sql 2>>$LOG_FILE
  if [[ $? -eq 0 && -s $TMP_DIR/${SQL_FILE}.sql ]]
  then
    log INFO "Databases dumped successfully."
    return 0
  else
    log ERROR "Backup failed and need attention."
    return 1
  fi
}

# Call main program to start the database backup
backup_databases
