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

{{- $envAll := . }}

# Capture the user's command line arguments
ARGS=("$@")

if [[ -s /tmp/restore_main.sh ]]; then
  source /tmp/restore_main.sh
else
  echo "File /tmp/restore_main.sh does not exist."
  exit 1
fi

# Export the variables needed by the framework
export DB_NAME="mariadb"
export DB_NAMESPACE=${MARIADB_POD_NAMESPACE}
export ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${DB_NAMESPACE}/${DB_NAME}/archive

RESTORE_USER='restoreuser'
RESTORE_PW=$(pwgen 16 1)
RESTORE_LOG='/tmp/restore_error.log'
rm -f $RESTORE_LOG

# This is for commands which require admin access
MYSQL="mysql \
       --defaults-file=/etc/mysql/admin_user.cnf \
       --host=$MARIADB_SERVER_SERVICE_HOST \
       --connect-timeout 10"

# This is for commands which we want the temporary "restore" user
# to execute
RESTORE_CMD="mysql \
             --user=${RESTORE_USER} \
             --password=${RESTORE_PW} \
             --host=$MARIADB_SERVER_SERVICE_HOST \
{{- if .Values.manifests.certificates }}
             --ssl-ca=/etc/mysql/certs/ca.crt \
             --ssl-key=/etc/mysql/certs/tls.key \
             --ssl-cert=/etc/mysql/certs/tls.crt \
{{- end }}
             --connect-timeout 10"

# Get a single database data from the SQL file.
# $1 - database name
# $2 - sql file path
current_db_desc() {
  PATTERN="-- Current Database:"
  sed -n "/${PATTERN} \`$1\`/,/${PATTERN}/p" $2
}

#Return all database from an archive
get_databases() {
  TMP_DIR=$1
  DB_FILE=$2

  if [[ -e ${TMP_DIR}/db.list ]]
  then
    DBS=$(cat ${TMP_DIR}/db.list | \
              grep -ivE 'information_schema|performance_schema|mysql|sys' )
  else
    DBS=" "
  fi

  echo $DBS > $DB_FILE
}

# Determine sql file from 2 options - current and legacy one
# if current is not found check that there is no other namespaced dump file
# before falling back to legacy one
_get_sql_file() {
  TMP_DIR=$1
  SQL_FILE="${TMP_DIR}/mariadb.${MARIADB_POD_NAMESPACE}.*.sql"
  LEGACY_SQL_FILE="${TMP_DIR}/mariadb.*.sql"
  INVALID_SQL_FILE="${TMP_DIR}/mariadb.*.*.sql"
  if [ -f ${SQL_FILE} ]
  then
    echo "Found $(ls ${SQL_FILE})" > /dev/stderr
    printf ${SQL_FILE}
  elif [ -f ${INVALID_SQL_FILE} ]
  then
    echo "Expected to find ${SQL_FILE} or ${LEGACY_SQL_FILE}, but found $(ls ${INVALID_SQL_FILE})" > /dev/stderr
  elif [ -f ${LEGACY_SQL_FILE} ]
  then
    echo "Falling back to legacy naming ${LEGACY_SQL_FILE}. Found $(ls ${LEGACY_SQL_FILE})" > /dev/stderr
    printf ${LEGACY_SQL_FILE}
  fi
}

# Extract all tables of a database from an archive and put them in the requested
# file.
get_tables() {
  DATABASE=$1
  TMP_DIR=$2
  TABLE_FILE=$3

  SQL_FILE=$(_get_sql_file $TMP_DIR)
  if [ ! -z $SQL_FILE ]; then
    current_db_desc ${DATABASE} ${SQL_FILE} \
        | grep "^CREATE TABLE" | awk -F '`' '{print $2}' \
        > $TABLE_FILE
  else
    # Error, cannot report the tables
    echo "No SQL file found - cannot extract the tables"
    return 1
  fi
}

# Extract all rows in the given table of a database from an archive and put
# them in the requested file.
get_rows() {
  DATABASE=$1
  TABLE=$2
  TMP_DIR=$3
  ROW_FILE=$4

  SQL_FILE=$(_get_sql_file $TMP_DIR)
  if [ ! -z $SQL_FILE ]; then
    current_db_desc ${DATABASE} ${SQL_FILE} \
        | grep "INSERT INTO \`${TABLE}\` VALUES" > $ROW_FILE
    return 0
  else
    # Error, cannot report the rows
    echo "No SQL file found - cannot extract the rows"
    return 1
  fi
}

# Extract the schema for the given table in the given database belonging to
# the archive file found in the TMP_DIR.
get_schema() {
  DATABASE=$1
  TABLE=$2
  TMP_DIR=$3
  SCHEMA_FILE=$4

  SQL_FILE=$(_get_sql_file $TMP_DIR)
  if [ ! -z $SQL_FILE ]; then
    DB_FILE=$(mktemp -p /tmp)
    current_db_desc ${DATABASE} ${SQL_FILE} > ${DB_FILE}
    sed -n /'CREATE TABLE `'$TABLE'`'/,/'--'/p ${DB_FILE} > ${SCHEMA_FILE}
    if [[ ! (-s ${SCHEMA_FILE}) ]]; then
      sed -n /'CREATE TABLE IF NOT EXISTS `'$TABLE'`'/,/'--'/p ${DB_FILE} \
          > ${SCHEMA_FILE}
    fi
    rm -f ${DB_FILE}
  else
    # Error, cannot report the rows
    echo "No SQL file found - cannot extract the schema"
    return 1
  fi
}

# Create temporary user for restoring specific databases.
create_restore_user() {
  restore_db=$1

  # Ensure any old restore user is removed first, if it exists.
  # If it doesn't exist it may return error, so do not exit the
  # script if that's the case.
  delete_restore_user "dont_exit_on_error"

  $MYSQL --execute="GRANT SELECT ON *.* TO ${RESTORE_USER}@'%' IDENTIFIED BY '${RESTORE_PW}';" 2>>$RESTORE_LOG
  if [[ "$?" -eq 0 ]]
  then
    $MYSQL --execute="GRANT ALL ON ${restore_db}.* TO ${RESTORE_USER}@'%' IDENTIFIED BY '${RESTORE_PW}';" 2>>$RESTORE_LOG
    if [[ "$?" -ne 0 ]]
    then
      cat $RESTORE_LOG
      echo "Failed to grant restore user ALL permissions on database ${restore_db}"
      return 1
    fi
  else
    cat $RESTORE_LOG
    echo "Failed to grant restore user select permissions on all databases"
    return 1
  fi
}

# Delete temporary restore user
delete_restore_user() {
  error_handling=$1

  $MYSQL --execute="DROP USER ${RESTORE_USER}@'%';" 2>>$RESTORE_LOG
  if [[ "$?" -ne 0 ]]
  then
    if [ "$error_handling" == "exit_on_error" ]
    then
      cat $RESTORE_LOG
      echo "Failed to delete temporary restore user - needs attention to avoid a security hole"
      return 1
    fi
  fi
}

#Restore a single database
restore_single_db() {
  SINGLE_DB_NAME=$1
  TMP_DIR=$2

  if [[ -z "$SINGLE_DB_NAME" ]]
  then
    echo "Restore single DB called but with wrong parameter."
    return 1
  fi

  SQL_FILE=$(_get_sql_file $TMP_DIR)
  if [ ! -z $SQL_FILE ]; then
    # Restoring a single database requires us to create a temporary user
    # which has capability to only restore that ONE database. One gotcha
    # is that the mysql command to restore the database is going to throw
    # errors because of all the other databases that it cannot access. So
    # because of this reason, the --force option is used to prevent the
    # command from stopping on an error.
    create_restore_user $SINGLE_DB_NAME
    if [[ $? -ne 0 ]]
    then
      echo "Restore $SINGLE_DB_NAME failed create restore user."
      return 1
    fi
    $RESTORE_CMD --force < $SQL_FILE 2>>$RESTORE_LOG
    if [[ "$?" -eq 0 ]]
    then
      echo "Database $SINGLE_DB_NAME Restore successful."
    else
      cat $RESTORE_LOG
      delete_restore_user "exit_on_error"
      echo "Database $SINGLE_DB_NAME Restore failed."
      return 1
    fi
    delete_restore_user "exit_on_error"
    if [[ $? -ne 0 ]]
    then
      echo "Restore $SINGLE_DB_NAME failed delete restore user."
      return 1
    fi
    if [ -f ${TMP_DIR}/${SINGLE_DB_NAME}_grant.sql ]
    then
      $MYSQL < ${TMP_DIR}/${SINGLE_DB_NAME}_grant.sql 2>>$RESTORE_LOG
      if [[ "$?" -eq 0 ]]
      then
        if ! $MYSQL --execute="FLUSH PRIVILEGES;"; then
          echo "Failed to flush privileges for $SINGLE_DB_NAME."
          return 1
        fi
        echo "Database $SINGLE_DB_NAME Permission Restore successful."
      else
        cat $RESTORE_LOG
        echo "Database $SINGLE_DB_NAME Permission Restore failed."
        return 1
      fi
    else
      echo "There is no permission file available for $SINGLE_DB_NAME"
      return 1
    fi
  else
    echo "There is no database file available to restore from"
    return 1
  fi
  return 0
}

#Restore all the databases
restore_all_dbs() {
  TMP_DIR=$1

  SQL_FILE=$(_get_sql_file $TMP_DIR)
  if [ ! -z $SQL_FILE ]; then
    # Check the scope of the archive.
    SCOPE=$(echo ${SQL_FILE} | awk -F'.' '{print $(NF-1)}')
    if [[ "${SCOPE}" != "all" ]]; then
      # This is just a single database backup. The user should
      # instead use the single database restore option.
      echo "Cannot use the restore all option for an archive containing only a single database."
      echo "Please use the single database restore option."
      return 1
    fi

    $MYSQL < $SQL_FILE 2>$RESTORE_LOG
    if [[ "$?" -eq 0 ]]
    then
      echo "Databases $( echo $DBS | tr -d '\n') Restore successful."
    else
      cat $RESTORE_LOG
      echo "Databases $( echo $DBS | tr -d '\n') Restore failed."
      return 1
    fi
    if [[ -f ${TMP_DIR}/grants.sql ]]
    then
      $MYSQL < ${TMP_DIR}/grants.sql 2>$RESTORE_LOG
      if [[ "$?" -eq 0 ]]
      then
        if ! $MYSQL --execute="FLUSH PRIVILEGES;"; then
          echo "Failed to flush privileges."
          return 1
        fi
        echo "Databases Permission Restore successful."
      else
        cat $RESTORE_LOG
        echo "Databases Permission Restore failed."
        return 1
      fi
    else
      echo "There is no permission file available"
      return 1
    fi
  else
    echo "There is no database file available to restore from"
    return 1
  fi
  return 0
}

# Call the CLI interpreter, providing the archive directory path and the
# user arguments passed in
cli_main ${ARGS[@]}
