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

#set -x
export PGPASSFILE=/etc/postgresql/admin_user.conf
ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive
RESTORE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/restore
POSTGRESQL_HOST=$(cat /etc/postgresql/admin_user.conf | cut -d: -f 1)
LIST_OPTIONS=(list_archives list_databases)
ARGS=("$@")
PSQL="psql -U $POSTGRESQL_BACKUP_USER -h $POSTGRESQL_HOST"

usage() {
  echo "Usage:"
  echo "$0 options"
  echo "============================="
  echo "options: "
  echo "list_archives"
  echo "list_databases archive_filename"
  echo "restore archive_filename [DB_NAME or ALL/all]"
}

#Delete file
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

#Extract Single Database SQL Dump from pg_dumpall dump file
extract_single_db_dump() {
  sed  "/connect.*$2/,\$!d" $1 | sed "/PostgreSQL database dump complete/,\$d" > \
      ${RESTORE_DIR}/$2.sql
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

#Return all databases from an archive
get_databases() {
  archive_file=$1
  if [ -e ${ARCHIVE_DIR}/${archive_file} ]
  then
    files_to_purge=$(find $RESTORE_DIR/ -iname "*.sql" -print)
    delete_files $files_to_purge
    tar zxvf ${ARCHIVE_DIR}/${archive_file} -C ${RESTORE_DIR} 1>/dev/null
    if [ -e ${RESTORE_DIR}/postgres.all.sql ]
    then
      DBS=$( grep 'CREATE DATABASE' ${RESTORE_DIR}/postgres.all.sql | awk '{ print $3 }' )
    else
      DBS=" "
    fi
  else
    DBS=" "
  fi
}

#Display all databases from an archive
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
  else
    echo "There is no database in the archive."
  fi

}

create_db_if_not_exist() {
  #Postgresql does not have the concept of creating
  #database if condition. This function help create
  #the database in case it does not exist
  $PSQL -tc "SELECT 1 FROM pg_database WHERE datname = '$1'" | grep -q 1 || \
        $PSQL -c "CREATE DATABASE $1"
}

#Restore a single database dump from pg_dumpall dump.
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
    if [ -f ${RESTORE_DIR}/postgres.all.sql ]
    then
      extract_single_db_dump ${RESTORE_DIR}/postgres.all.sql $single_db_name
      if [[ -f ${RESTORE_DIR}/${single_db_name}.sql && -s ${RESTORE_DIR}/${single_db_name}.sql ]]
      then
        create_db_if_not_exist $single_db_name
        $PSQL -d $single_db_name -f ${RESTORE_DIR}/${single_db_name}.sql 2>dbrestore.log
        if [ "$?" -eq 0 ]
        then
          echo "Database Restore Successful."
        else
          echo "Database Restore Failed."
        fi
      else
        echo "Database Dump For $single_db_name is empty or not available."
      fi
    else
      echo "Database file for dump_all not available to restore from"
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
    if [ -f ${RESTORE_DIR}/postgres.all.sql ]
    then
      $PSQL postgres -f ${RESTORE_DIR}/postgres.all.sql 2>dbrestore.log
      if [ "$?" -eq 0 ]
      then
        echo "Database Restore successful."
      else
        echo "Database Restore failed."
      fi
    else
      echo "There is no database file available to restore from"
    fi
  else
    echo "Archive does not exist"
 fi
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
#Create Restore Directory
mkdir -p $RESTORE_DIR
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
        restore_single_db ${ARGS[2]}
        echo "Tail dbrestore.log for restore log."
        exit 0
      elif [ "$( echo ${ARGS[2]} | tr '[a-z]' '[A-Z]')" == "ALL" ]
      then
        echo "Restoring All The Database."
        restore_all_dbs
        echo "Tail dbrestore.log for restore log."
        exit 0
      else
        echo "There is no database with that name"
      fi
    else
      echo "Archive file not found"
    fi
  fi
else
  usage
  exit
fi

