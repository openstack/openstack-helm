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

ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/archive
RESTORE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/restore
ARGS=("$@")
LIST_OPTIONS=(list_archives list_databases)

#Create Restore Directory
mkdir -p $RESTORE_DIR

MYSQL="mysql \
   --defaults-file=/etc/mysql/admin_user.cnf \
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
    exit 0
  else
    echo "Archive directory is not available."
    exit 1
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

#Restore a single database
restore_single_db() {
  single_db_name=$1
  if [ -z "$single_db_name" ]
  then
    usage
    exit 1
  fi
  if [ -f ${ARCHIVE_DIR}/${archive_file} ]
  then
    files_to_purge=$(find $RESTORE_DIR/ -iname "*.sql" -print)
    delete_files $files_to_purge
    tar zxvf ${ARCHIVE_DIR}/${archive_file} -C ${RESTORE_DIR} 1>/dev/null
    if [ -f ${RESTORE_DIR}/mariadb.all.sql ]
    then
      $MYSQL --one-database $single_db_name < ${RESTORE_DIR}/mariadb.all.sql
      if [ "$?" -eq 0 ]
      then
        echo "Database $single_db_name Restore successful."
      else
        echo "Database $single_db_name Restore failed."
      fi
      if [ -f ${RESTORE_DIR}/${single_db_name}_grant.sql ]
      then
        $MYSQL < ${RESTORE_DIR}/${single_db_name}_grant.sql
        if [ "$?" -eq 0 ]
        then
          echo "Database $single_db_name Permission Restore successful."
        else
          echo "Database $single_db_name Permission Restore failed."
        fi
      else
        echo "There is no permission file available for $single_db_name"
      fi
    else
      echo "There is no database file available to restore from"
    fi
  else
    echo "Archive does not exist"
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
      $MYSQL < ${RESTORE_DIR}/mariadb.all.sql
      if [ "$?" -eq 0 ]
      then
        echo "Databases $( echo $DBS | tr -d '\n') Restore successful."
      else
        echo "Databases $( echo $DBS | tr -d '\n') Restore failed."
      fi
      if [ -n "$DBS" ]
      then
        for db in $DBS
        do
          if [ -f ${RESTORE_DIR}/${db}_grant.sql ]
          then
            $MYSQL < ${RESTORE_DIR}/${db}_grant.sql
            if [ "$?" -eq 0 ]
            then
              echo "Database $db Permission Restore successful."
            else
              echo "Database $db Permission Restore failed."
            fi
          else
            echo "There is no permission file available for $db"
          fi
        done
    else
      echo "There is no database file available to restore from"
    fi
  else
    echo "Archive does not exist"
  fi
 fi
}

usage() {
  echo "Usage:"
  echo "$0 options"
  echo "============================="
  echo "options: "
  echo "list_archives"
  echo "list_databases archive_filename"
  echo "restore archive_filename [DB_NAME or ALL/all]"
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
  usage
  exit
elif [ ${#ARGS[@]} -eq 1 ]
then
  if [ $(is_Option "$LIST_OPTIONS" ${ARGS[0]}) -eq 1 ]
  then
    ${ARGS[0]}
    exit
  else
    usage
    exit
  fi
elif [ ${#ARGS[@]} -eq 2 ]
then
  if [ "${ARGS[0]}" == "list_databases" ]
  then
    list_databases ${ARGS[1]}
    exit 0
  else
    usage
    exit
  fi
elif [ ${#ARGS[@]} -eq 3 ]
then
  if [ "${ARGS[0]}" != "restore" ]
  then
    usage
    exit 1
  else
    if [ -f ${ARCHIVE_DIR}/${ARGS[1]} ]
    then
      #Get all the databases in that archive
      get_databases ${ARGS[1]}
      #check if the requested database is available in the archive
      if [ $(is_Option "$DBS" ${ARGS[2]}) -eq 1 ]
      then
        echo "Restoring Database ${ARGS[2]} And Grants"
        echo "Creating Database ${ARGS[2]} if it does not exist"
        $MYSQL -e "CREATE DATABASE IF NOT EXISTS \`${ARGS[2]}\`"
        restore_single_db ${ARGS[2]}
        exit 0
      elif [ "$( echo ${ARGS[2]} | tr '[a-z]' '[A-Z]')" == "ALL" ]
      then
        echo "Restoring All The Database."
        echo "Creating Database if it does not exist"
        for db in $DBS
        do
          $MYSQL -e "CREATE DATABASE IF NOT EXISTS \`$db\`"
        done
        restore_all_dbs
        exit 0
      else
        echo "Database ${ARGS[2]} does not exist."
      fi
    else
      echo "Archive file not found"
    fi
  fi
else
  usage
  exit
fi
