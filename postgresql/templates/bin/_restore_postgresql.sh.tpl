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
export LOG_FILE=/tmp/dbrestore.log

# Extract all databases from an archive and put them in the requested
# file.
get_databases() {
  TMP_DIR=$1
  DB_FILE=$2

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then
    grep 'CREATE DATABASE' $SQL_FILE | awk '{ print $3 }' > $DB_FILE
  else
    # Error, cannot report the databases
    echo "No SQL file found - cannot extract the databases"
    return 1
  fi
}

# Extract all tables of a database from an archive and put them in the requested
# file.
get_tables() {
  DATABASE=$1
  TMP_DIR=$2
  TABLE_FILE=$3

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then
    cat $SQL_FILE | sed -n /'\\connect '$DATABASE/,/'\\connect'/p | grep "CREATE TABLE" | awk -F'[. ]' '{print $4}' > $TABLE_FILE
  else
    # Error, cannot report the tables
    echo "No SQL file found - cannot extract the tables"
    return 1
  fi
}

# Extract all rows in the given table of a database from an archive and put them in the requested
# file.
get_rows() {
  DATABASE=$1
  TABLE=$2
  TMP_DIR=$3
  ROW_FILE=$4

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then
    cat $SQL_FILE | sed -n /'\\connect '${DATABASE}/,/'\\connect'/p > /tmp/db.sql
    cat /tmp/db.sql | grep "INSERT INTO public.${TABLE} VALUES" > $ROW_FILE
    rm /tmp/db.sql
  else
    # Error, cannot report the rows
    echo "No SQL file found - cannot extract the rows"
    return 1
  fi
}

# Extract the schema for the given table in the given database belonging to the archive file
# found in the TMP_DIR.
get_schema() {
  DATABASE=$1
  TABLE=$2
  TMP_DIR=$3
  SCHEMA_FILE=$4

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then
    DB_FILE=$(mktemp -p /tmp)
    cat $SQL_FILE | sed -n /'\\connect '${DATABASE}/,/'\\connect'/p > ${DB_FILE}
    cat ${DB_FILE} | sed -n /'CREATE TABLE public.'${TABLE}' ('/,/'--'/p > ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'CREATE SEQUENCE public.'${TABLE}/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'ALTER TABLE public.'${TABLE}/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'ALTER TABLE ONLY public.'${TABLE}/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'ALTER SEQUENCE public.'${TABLE}/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'SELECT pg_catalog.*public.'${TABLE}/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'CREATE INDEX.*public.'${TABLE}' USING'/,/'--'/p >> ${SCHEMA_FILE}
    cat ${DB_FILE} | sed -n /'GRANT.*public.'${TABLE}' TO'/,/'--'/p >> ${SCHEMA_FILE}
    rm -f ${DB_FILE}
  else
    # Error, cannot report the rows
    echo "No SQL file found - cannot extract the schema"
    return 1
  fi
}

# Extract Single Database SQL Dump from pg_dumpall dump file
extract_single_db_dump() {
  ARCHIVE=$1
  DATABASE=$2
  DIR=$3
  sed -n '/\\connect'" ${DATABASE}/,/PostgreSQL database dump complete/p" ${ARCHIVE} > ${DIR}/${DATABASE}.sql
}

# Re-enable connections to a database
reenable_connections() {
  SINGLE_DB_NAME=$1

  # First make sure this is not the main postgres database or either of the
  # two template databases that should not be touched.
  if [[ ${SINGLE_DB_NAME} == "postgres" ||
        ${SINGLE_DB_NAME} == "template0" ||
        ${SINGLE_DB_NAME} == "template1" ]]; then
    echo "Cannot re-enable connections on an postgres internal db ${SINGLE_DB_NAME}"
    return 1
  fi

  # Re-enable connections to the DB
  $PSQL -tc "UPDATE pg_database SET datallowconn = 'true' WHERE datname = '${SINGLE_DB_NAME}';" > /dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    echo "Could not re-enable connections for database ${SINGLE_DB_NAME}"
    return 1
  fi
  return 0
}

# Drop connections from a database
drop_connections() {
  SINGLE_DB_NAME=$1

  # First make sure this is not the main postgres database or either of the
  # two template databases that should not be touched.
  if [[ ${SINGLE_DB_NAME} == "postgres" ||
        ${SINGLE_DB_NAME} == "template0" ||
        ${SINGLE_DB_NAME} == "template1" ]]; then
    echo "Cannot drop connections on an postgres internal db ${SINGLE_DB_NAME}"
    return 1
  fi

  # First, prevent any new connections from happening on this database.
  $PSQL -tc "UPDATE pg_database SET datallowconn = 'false' WHERE datname = '${SINGLE_DB_NAME}';" > /dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    echo "Could not prevent new connections before restoring database ${SINGLE_DB_NAME}."
    return 1
  fi

  # Next, force disconnection of all clients currently connected to this database.
  $PSQL -tc "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${SINGLE_DB_NAME}';" > /dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    echo "Could not drop existing connections before restoring database ${SINGLE_DB_NAME}."
    reenable_connections ${SINGLE_DB_NAME}
    return 1
  fi
  return 0
}

# Re-enable connections for all of the databases within Postgresql
reenable_connections_on_all_dbs() {
  # Get a list of the databases
  DB_LIST=$($PSQL -tc "\l" | grep "| postgres |" | awk '{print $1}')

  RET=0

  # Re-enable the connections for each of the databases.
  for DB in $DB_LIST; do
    if [[ ${DB} != "postgres" && ${DB} != "template0" && ${DB} != "template1" ]]; then
      reenable_connections $DB
      if [[ "$?" -ne 0 ]]; then
        RET=1
      fi
    fi
  done

  return $RET
}

# Drop connections in all of the databases within Postgresql
drop_connections_on_all_dbs() {
  # Get a list of the databases
  DB_LIST=$($PSQL -tc "\l" | grep "| postgres |" | awk '{print $1}')

  RET=0

  # Drop the connections for each of the databases.
  for DB in $DB_LIST; do
    # Make sure this is not the main postgres database or either of the
    # two template databases that should not be touched.
    if [[ ${DB} != "postgres" && ${DB} != "template0" && ${DB} != "template1" ]]; then
      drop_connections $DB
      if [[ "$?" -ne 0 ]]; then
        RET=1
      fi
    fi
  done

  # If there was a failure to drop any connections, go ahead and re-enable
  # them all to prevent a lock-out condition
  if [[ $RET -ne 0 ]]; then
    reenable_connections_on_all_dbs
  fi

  return $RET
}

# Restore a single database dump from pg_dumpall sql dumpfile.
restore_single_db() {
  SINGLE_DB_NAME=$1
  TMP_DIR=$2

  # Reset the logfile incase there was some older log there
  rm -rf ${LOG_FILE}
  touch ${LOG_FILE}

  # First make sure this is not the main postgres database or either of the
  # two template databases that should not be touched.
  if [[ ${SINGLE_DB_NAME} == "postgres" ||
        ${SINGLE_DB_NAME} == "template0" ||
        ${SINGLE_DB_NAME} == "template1" ]]; then
    echo "Cannot restore an postgres internal db ${SINGLE_DB_NAME}"
    return 1
  fi

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then
    extract_single_db_dump $SQL_FILE $SINGLE_DB_NAME $TMP_DIR
    if [[ -f $TMP_DIR/$SINGLE_DB_NAME.sql && -s $TMP_DIR/$SINGLE_DB_NAME.sql ]]; then
      # Drop connections first
      drop_connections ${SINGLE_DB_NAME}
      if [[ "$?" -ne 0 ]]; then
        return 1
      fi

      # Next, drop the database
      $PSQL -tc "DROP DATABASE $SINGLE_DB_NAME;"
      if [[ "$?" -ne 0 ]]; then
        echo "Could not drop the old ${SINGLE_DB_NAME} database before restoring it."
        reenable_connections ${SINGLE_DB_NAME}
        return 1
      fi

      # Postgresql does not have the concept of creating database if condition.
      # This next command creates the database in case it does not exist.
      $PSQL -tc "SELECT 1 FROM pg_database WHERE datname = '$SINGLE_DB_NAME'" | grep -q 1 || \
            $PSQL -c "CREATE DATABASE $SINGLE_DB_NAME"
      if [[ "$?" -ne 0 ]]; then
        echo "Could not create the single database being restored: ${SINGLE_DB_NAME}."
        reenable_connections ${SINGLE_DB_NAME}
        return 1
      fi
      $PSQL -d $SINGLE_DB_NAME -f ${TMP_DIR}/${SINGLE_DB_NAME}.sql 2>>$LOG_FILE >> $LOG_FILE
      if [[ "$?" -eq 0 ]]; then
        if grep "ERROR:" ${LOG_FILE} > /dev/null 2>&1; then
          cat $LOG_FILE
          echo "Errors occurred during the restore of database ${SINGLE_DB_NAME}"
          reenable_connections ${SINGLE_DB_NAME}
          return 1
        else
          echo "Database restore Successful."
        fi
      else
        # Dump out the log file for debugging
        cat $LOG_FILE
        echo -e "\nDatabase restore Failed."
        reenable_connections ${SINGLE_DB_NAME}
        return 1
      fi

      # Re-enable connections to the DB
      reenable_connections ${SINGLE_DB_NAME}
      if [[ "$?" -ne 0 ]]; then
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

  # Reset the logfile incase there was some older log there
  rm -rf ${LOG_FILE}
  touch ${LOG_FILE}

  SQL_FILE=$TMP_DIR/postgres.$POSTGRESQL_POD_NAMESPACE.*.sql
  if [ -f $SQL_FILE ]; then

    # Check the scope of the archive.
    SCOPE=$(echo ${SQL_FILE} | awk -F'.' '{print $(NF-1)}')
    if [[ "${SCOPE}" != "all" ]]; then
      # This is just a single database backup. The user should
      # instead use the single database restore option.
      echo "Cannot use the restore all option for an archive containing only a single database."
      echo "Please use the single database restore option."
      return 1
    fi

    # First drop all connections on all databases
    drop_connections_on_all_dbs
    if [[ "$?" -ne 0 ]]; then
      return 1
    fi

    $PSQL postgres -f $SQL_FILE 2>>$LOG_FILE >> $LOG_FILE
    if [[ "$?" -eq 0 ]]; then
      if grep "ERROR:" ${LOG_FILE} > /dev/null 2>&1; then
        cat ${LOG_FILE}
        echo "Errors occurred during the restore of the databases."
        reenable_connections_on_all_dbs
        return 1
      else
        echo "Database Restore Successful."
      fi
    else
      # Dump out the log file for debugging
      cat ${LOG_FILE}
      echo -e "\nDatabase Restore failed."
      reenable_connections_on_all_dbs
      return 1
    fi

    # Re-enable connections on all databases
    reenable_connections_on_all_dbs
    if [[ "$?" -ne 0 ]]; then
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
