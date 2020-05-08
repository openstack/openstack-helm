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

# Capture the user's command line arguments
ARGS=("$@")

# This is needed to get the postgresql admin password
# Note: xtracing should be off so it doesn't print the pw
export PGPASSWORD=$(cat /etc/postgresql/admin_user.conf \
                    | grep postgres | awk -F: '{print $5}')

source /tmp/restore_main.sh

# Export the variables needed by the framework
export DB_NAME="postgres"
export DB_NAMESPACE=${POSTGRESQL_POD_NAMESPACE}
export ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${DB_NAMESPACE}/${DB_NAME}/archive

# Define variables needed in this file
POSTGRESQL_HOST=$(cat /etc/postgresql/admin_user.conf | cut -d: -f 1)
export PSQL="psql -U $POSTGRESQL_ADMIN_USER -h $POSTGRESQL_HOST"

# Extract all databases from an archive and put them in the requested
# file.
get_databases() {
  TMP_DIR=$1
  DB_FILE=$2

  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [[ -e $TMP_DIR/$SQL_FILE ]]; then
    grep 'CREATE DATABASE' $TMP_DIR/$SQL_FILE | awk '{ print $3 }' > $DB_FILE
  else
    # no databases - just touch the file
    touch $DB_FILE
  fi
}

# Extract Single Database SQL Dump from pg_dumpall dump file
extract_single_db_dump() {
  sed  "/connect.*$2/,\$!d" $1 | sed "/PostgreSQL database dump complete/,\$d" > ${3}/$2.sql
}

# Restore a single database dump from pg_dumpall sql dumpfile.
restore_single_db() {
  SINGLE_DB_NAME=$1
  TMP_DIR=$2

  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [[ -f $TMP_DIR/$SQL_FILE ]]; then
    extract_single_db_dump $TMP_DIR/$SQL_FILE $SINGLE_DB_NAME $TMP_DIR
    if [[ -f $TMP_DIR/$SINGLE_DB_NAME.sql && -s $TMP_DIR/$SINGLE_DB_NAME.sql ]]; then
      # Postgresql does not have the concept of creating database if condition.
      # This next command creates the database in case it does not exist.
      $PSQL -tc "SELECT 1 FROM pg_database WHERE datname = '$SINGLE_DB_NAME'" | grep -q 1 || \
            $PSQL -c "CREATE DATABASE $SINGLE_DB_NAME"
      if [[ "$?" -ne 0 ]]; then
        echo "Could not create the single database being restored: ${SINGLE_DB_NAME}."
        return 1
      fi
      $PSQL -d $SINGLE_DB_NAME -f ${TMP_DIR}/${SINGLE_DB_NAME}.sql 2>>$LOG_FILE >> $LOG_FILE
      if [[ "$?" -eq 0 ]]; then
        echo "Database restore Successful."
      else
        echo "Database restore Failed."
        return 1
      fi
    else
      echo "Database dump For $SINGLE_DB_NAME is empty or not available."
      return 1
    fi
  else
    echo "No database file available to restore from."
    return 1
  fi
  return 0
}

# Restore all the databases from the pg_dumpall sql file.
restore_all_dbs() {
  TMP_DIR=$1

  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [[ -f $TMP_DIR/$SQL_FILE ]]; then
    $PSQL postgres -f $TMP_DIR/$SQL_FILE 2>>$LOG_FILE >> $LOG_FILE
    if [[ "$?" -eq 0 ]]; then
      echo "Database Restore successful."
    else
      echo "Database Restore failed."
      return 1
    fi
  else
    echo "There is no database file available to restore from."
    return 1
  fi
  return 0
}

# Call the CLI interpreter, providing the archive directory path and the
# user arguments passed in
cli_main ${ARGS[@]}
