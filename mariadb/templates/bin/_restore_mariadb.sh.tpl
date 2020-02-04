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

log_error() {
  echo $1
  exit 1
}

ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/archive
RESTORE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/restore
ARGS=("$@")
RESTORE_USER='restoreuser'
RESTORE_PW=$(pwgen 16 1)
RESTORE_LOG='/tmp/restore_error.log'
rm -f $RESTORE_LOG

#Create Restore Directory
mkdir -p $RESTORE_DIR

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
             --connect-timeout 10"

#Delete file
delete_files() {
  files_to_delete=("$@")
  for f in "${files_to_delete[@]}"
  do
    if [ -f $f ]
    then
      rm -rf $f
    fi
  done
}

#Display all archives
list_archives() {
  if [ -d ${ARCHIVE_DIR} ]
  then
    archives=$(find ${ARCHIVE_DIR}/ -iname "*.gz" -print)
    echo "All Archives"
    echo "=================================="
    for archive in $archives
    do
      echo $archive | cut -d '/' -f 8
    done
  else
    log_error "Archive directory is not available."
  fi
}

#Return all database from an archive
get_databases() {
  archive_file=$1
  if [ -e ${ARCHIVE_DIR}/${archive_file} ]
  then
    files_to_purge=$(find $RESTORE_DIR/ -iname "*.sql" -print)
    delete_files $files_to_purge
    tar zxvf ${ARCHIVE_DIR}/${archive_file} -C ${RESTORE_DIR} 1>/dev/null
    if [ -e ${RESTORE_DIR}/db.list ]
    then
      DBS=$(cat ${RESTORE_DIR}/db.list )
    else
      DBS=" "
    fi
  else
    DBS=" "
  fi
}

#Display all database from an archive
list_databases() {
  archive_file=$1
  get_databases $archive_file
  #echo $DBS
  if [ -n "$DBS" ]
  then
    echo " "
    echo "Databases in the archive $archive_file"
    echo "================================================================="
    for db in $DBS
    do
      echo $db
    done
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
  if [ "$?" -eq 0 ]
  then
    $MYSQL --execute="GRANT ALL ON ${restore_db}.* TO ${RESTORE_USER}@'%' IDENTIFIED BY '${RESTORE_PW}';" 2>>$RESTORE_LOG
    if [ "$?" -ne 0 ]
    then
      cat $RESTORE_LOG
      log_error "Failed to grant restore user ALL permissions on database ${restore_db}"
    fi
  else
    cat $RESTORE_LOG
    log_error "Failed to grant restore user select permissions on all databases"
  fi
}

# Delete temporary restore user
delete_restore_user() {
  error_handling=$1

  $MYSQL --execute="DROP USER ${RESTORE_USER}@'%';" 2>>$RESTORE_LOG
  if [ "$?" -ne 0 ]
  then
    if [ "$error_handling" == "exit_on_error" ]
    then
      cat $RESTORE_LOG
      log_error "Failed to delete temporary restore user - needs attention to avoid a security hole"
    fi
  fi
}

#Restore a single database
restore_single_db() {
  single_db_name=$1
  if [ -z "$single_db_name" ]
  then
    log_error "Restore single DB called but with wrong parameter."
  fi
  if [ -f ${ARCHIVE_DIR}/${archive_file} ]
  then
    files_to_purge=$(find $RESTORE_DIR/ -iname "*.sql" -print)
    delete_files $files_to_purge
    tar zxvf ${ARCHIVE_DIR}/${archive_file} -C ${RESTORE_DIR} 1>/dev/null
    if [ -f ${RESTORE_DIR}/mariadb.all.sql ]
    then
      # Restoring a single database requires us to create a temporary user
      # which has capability to only restore that ONE database. One gotcha
      # is that the mysql command to restore the database is going to throw
      # errors because of all the other databases that it cannot access. So
      # because of this reason, the --force option is used to prevent the
      # command from stopping on an error.
      create_restore_user $single_db_name
      $RESTORE_CMD --force < ${RESTORE_DIR}/mariadb.all.sql 2>>$RESTORE_LOG
      if [ "$?" -eq 0 ]
      then
        echo "Database $single_db_name Restore successful."
      else
        cat $RESTORE_LOG
        delete_restore_user "exit_on_error"
        log_error "Database $single_db_name Restore failed."
      fi
      delete_restore_user "exit_on_error"

      if [ -f ${RESTORE_DIR}/${single_db_name}_grant.sql ]
      then
        $MYSQL < ${RESTORE_DIR}/${single_db_name}_grant.sql 2>>$RESTORE_LOG
        if [ "$?" -eq 0 ]
        then
          echo "Database $single_db_name Permission Restore successful."
        else
          cat $RESTORE_LOG
          log_error "Database $single_db_name Permission Restore failed."
        fi
      else
        log_error "There is no permission file available for $single_db_name"
      fi
    else
      log_error "There is no database file available to restore from"
    fi
  else
    log_error "Archive does not exist"
  fi
}

#Restore all the databases
restore_all_dbs() {
  if [ -f ${ARCHIVE_DIR}/${archive_file} ]
  then
    files_to_purge=$(find $RESTORE_DIR/ -iname "*.sql" -print)
    delete_files $files_to_purge
    tar zxvf ${ARCHIVE_DIR}/${archive_file} -C ${RESTORE_DIR} 1>/dev/null
    if [ -f ${RESTORE_DIR}/mariadb.all.sql ]
    then
      $MYSQL < ${RESTORE_DIR}/mariadb.all.sql 2>$RESTORE_LOG
      if [ "$?" -eq 0 ]
      then
        echo "Databases $( echo $DBS | tr -d '\n') Restore successful."
      else
        cat $RESTORE_LOG
        log_error "Databases $( echo $DBS | tr -d '\n') Restore failed."
      fi
      if [ -n "$DBS" ]
      then
        for db in $DBS
        do
          if [ -f ${RESTORE_DIR}/${db}_grant.sql ]
          then
            $MYSQL < ${RESTORE_DIR}/${db}_grant.sql 2>>$RESTORE_LOG
            if [ "$?" -eq 0 ]
            then
              echo "Database $db Permission Restore successful."
            else
              cat $RESTORE_LOG
              log_error "Database $db Permission Restore failed."
            fi
          else
            log_error "There is no permission file available for $db"
          fi
        done
    else
      log_error "There is no database file available to restore from"
    fi
  else
    log_error "Archive does not exist"
  fi
 fi
}

usage() {
  ret_val=$1
  echo "Usage:"
  echo "Restore command options"
  echo "============================="
  echo "help"
  echo "list_archives"
  echo "list_databases <archive_filename>"
  echo "restore <archive_filename> [<db_name> | ALL]"
  exit $ret_val
}

is_Option() {
  opts=$1
  param=$2
  find=0
  for opt in $opts
  do
    if [ "$opt" == "$param" ]
    then
      find=1
    fi
  done
  echo $find
}

#Main
if [ ${#ARGS[@]} -gt 3 ]
then
  usage 1
elif [ ${#ARGS[@]} -eq 1 ]
then
  if [ "${ARGS[0]}" == "list_archives" ]
  then
    list_archives
  elif [ "${ARGS[0]}" == "help" ]
  then
    usage 0
  else
    usage 1
  fi
elif [ ${#ARGS[@]} -eq 2 ]
then
  if [ "${ARGS[0]}" == "list_databases" ]
  then
    list_databases ${ARGS[1]}
  else
    usage 1
  fi
elif [ ${#ARGS[@]} -eq 3 ]
then
  if [ "${ARGS[0]}" != "restore" ]
  then
    usage 1
  else
    if [ -f ${ARCHIVE_DIR}/${ARGS[1]} ]
    then
      #Get all the databases in that archive
      get_databases ${ARGS[1]}

      #check if the requested database is available in the archive
      if [ $(is_Option "$DBS" ${ARGS[2]}) -eq 1 ]
      then
        echo "Creating database ${ARGS[2]} if it does not exist"
        $MYSQL -e "CREATE DATABASE IF NOT EXISTS \`${ARGS[2]}\`" 2>>$RESTORE_LOG
        if [ "$?" -ne 0 ]
        then
          cat $RESTORE_LOG
          log_error "Database ${ARGS[2]} could not be created."
        fi
        echo "Restoring database ${ARGS[2]} and grants...this could take a few minutes."
        restore_single_db ${ARGS[2]}
      elif [ "$( echo ${ARGS[2]} | tr '[a-z]' '[A-Z]')" == "ALL" ]
      then
        echo "Creating databases if they do not exist"
        for db in $DBS
        do
          $MYSQL -e "CREATE DATABASE IF NOT EXISTS \`$db\`"
          if [ "$?" -ne 0 ]
          then
            cat $RESTORE_LOG
            log_error "Database ${db} could not be created."
          fi
        done
        echo "Restoring all databases and grants...this could take a few minutes."
        restore_all_dbs
      else
        echo "Database ${ARGS[2]} does not exist."
      fi
    else
      echo "Archive file not found"
    fi
  fi
else
  usage 1
fi

exit 0
