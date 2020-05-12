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

export PGPASSWORD=$(cat /etc/postgresql/admin_user.conf \
                    | grep postgres | awk -F: '{print $5}')

ARCHIVE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/archive
RESTORE_DIR=${POSTGRESQL_BACKUP_BASE_DIR}/db/${POSTGRESQL_POD_NAMESPACE}/postgres/restore
POSTGRESQL_HOST=$(cat /etc/postgresql/admin_user.conf | cut -d: -f 1)
LOG_FILE=/tmp/dbrestore.log
ARGS=("$@")
PSQL="psql -U $POSTGRESQL_BACKUP_USER -h $POSTGRESQL_HOST"

source /tmp/common_backup_restore.sh

usage() {
  ret_val=$1
  echo "Usage:"
  echo "Restore command options"
  echo "============================="
  echo "help"
  echo "list_archives [remote]"
  echo "list_databases <archive_filename> [remote]"
  echo "restore <archive_filename> <db_specifier> [remote]"
  echo "        where <db_specifier> = <dbname> | ALL"
  clean_and_exit $ret_val ""
}

#Extract Single Database SQL Dump from pg_dumpall dump file
extract_single_db_dump() {
  sed  "/connect.*$2/,\$!d" $1 | sed "/PostgreSQL database dump complete/,\$d" > \
      ${RESTORE_DIR}/$2.sql
}

#Exit cleanly with some message and return code
clean_and_exit() {
  RETCODE=$1
  MSG=$2

  #Cleanup Restore Directory
  rm -rf $RESTORE_DIR/*

  if [[ "x${MSG}" != "x" ]];
  then
    echo $MSG
  fi
  exit $RETCODE
}

# Signal the other container that it should retrieve a list of archives
# from the RGW.
retrieve_remote_listing() {
  # Remove the last response, if there was any
  rm -rf $RESTORE_DIR/archive_list_*

  # Signal by creating a file in the restore directory
  touch $RESTORE_DIR/archive_listing_request

  # Wait until the archive listing has been retrieved from the other container.
  echo "Waiting for archive listing..."
  wait_for_file $RESTORE_DIR/archive_list_*

  if [[ $? -eq 1 ]]
  then
    clean_and_exit 1 "Request failed - container did not respond. Archive listing is NOT available."
  fi

  ERR=$(cat $RESTORE_DIR/archive_list_error 2>/dev/null)
  if [[ $? -eq 0 ]]
  then
    clean_and_exit 1 "Request failed - ${ERR}"
  fi

  echo "Done waiting. Archive list is available."
}

# Signal the other container that it should retrieve a single archive
# from the RGW.
retrieve_remote_archive() {
  ARCHIVE=$1

  # Remove the last response, if there was any
  rm -rf $RESTORE_DIR/archive_*

  # Signal by creating a file in the restore directory containing the archive
  # name.
  echo "$ARCHIVE" > $RESTORE_DIR/get_archive_request

  # Wait until the archive has been retrieved from the other container.
  echo "Waiting for requested archive ${ARCHIVE}..."
  wait_for_file $RESTORE_DIR/archive_*

  if [[ $? -eq 1 ]]
  then
    clean_and_exit 1 "Request failed - container did not respond. Archive ${ARCHIVE} is NOT available."
  fi

  ERR=$(cat $RESTORE_DIR/archive_error 2>/dev/null)
  if [[ $? -eq 0 ]]
  then
    clean_and_exit 1 "Request failed - ${ERR}"
  fi

  rm -rf $RESTORE_DIR/archive_response
  if [[ -e $RESTORE_DIR/$ARCHIVE ]]
  then
    echo "Done waiting. Archive $ARCHIVE is available."
  else
    clean_and_exit 1 "Request failed - Archive $ARCHIVE is NOT available."
  fi
}

#Display all archives
list_archives() {
  REMOTE=$1

  if [[ "x${REMOTE^^}" == "xREMOTE" ]]
  then
    retrieve_remote_listing
    if [[ -e $RESTORE_DIR/archive_list_response ]]
    then
      echo
      echo "All Archives from RGW Data Store"
      echo "=============================================="
      cat $RESTORE_DIR/archive_list_response
      clean_and_exit 0 ""
    else
      clean_and_exit 1 "Archives could not be retrieved from the RGW."
    fi
  elif [[ "x${REMOTE}" == "x" ]]
  then
    if [ -d $ARCHIVE_DIR ]
    then
      archives=$(find $ARCHIVE_DIR/ -iname "*.gz" -print)
      echo
      echo "All Local Archives"
      echo "=============================================="
      for archive in $archives
      do
        echo $archive | cut -d '/' -f 8
      done
      clean_and_exit 0 ""
    else
      clean_and_exit 1 "Local archive directory is not available."
    fi
  else
    usage 1
  fi
}

#Return all databases from an archive
get_databases() {
  ARCHIVE_FILE=$1
  REMOTE=$2

  if [[ "x$REMOTE" == "xremote" ]]
  then
    retrieve_remote_archive $ARCHIVE_FILE
  elif [[ "x$REMOTE" == "x" ]]
  then
    if [ -e $ARCHIVE_DIR/$ARCHIVE_FILE ]
    then
      cp $ARCHIVE_DIR/$ARCHIVE_FILE $RESTORE_DIR/$ARCHIVE_FILE
      if [[ $? != 0 ]]
      then
        clean_and_exit 1 "Could not copy local archive to restore directory."
      fi
    else
      clean_and_exit 1 "Local archive file could not be found."
    fi
  else
    usage 1
  fi

  echo "Decompressing archive $ARCHIVE_FILE..."
  cd $RESTORE_DIR
  tar zxvf - < $RESTORE_DIR/$ARCHIVE_FILE 1>/dev/null
  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [ -e $RESTORE_DIR/$SQL_FILE ]
  then
    DBS=$( grep 'CREATE DATABASE' $RESTORE_DIR/$SQL_FILE | awk '{ print $3 }' )
  else
    DBS=" "
  fi
}

#Display all databases from an archive
list_databases() {
  ARCHIVE_FILE=$1
  REMOTE=$2
  WHERE="local"

  if [[ "x${REMOTE}" != "x" ]]
  then
    WHERE="remote"
  fi

  get_databases $ARCHIVE_FILE $REMOTE
  if [ -n "$DBS" ]
  then
    echo " "
    echo "Databases in the $WHERE archive $ARCHIVE_FILE"
    echo "================================================================================"
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
  SINGLE_DB_NAME=$1
  if [ -z "$SINGLE_DB_NAME" ]
  then
    usage 1
  fi

  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [ -f $RESTORE_DIR/$SQL_FILE ]
  then
    extract_single_db_dump $RESTORE_DIR/$SQL_FILE $SINGLE_DB_NAME
    if [[ -f $RESTORE_DIR/$SINGLE_DB_NAME.sql && -s $RESTORE_DIR/$SINGLE_DB_NAME.sql ]]
    then
      create_db_if_not_exist $single_db_name
      $PSQL -d $SINGLE_DB_NAME -f ${RESTORE_DIR}/${SINGLE_DB_NAME}.sql 2>>$LOG_FILE >> $LOG_FILE
      if [ "$?" -eq 0 ]
      then
        echo "Database Restore Successful."
      else
        clean_and_exit 1 "Database Restore Failed."
      fi
    else
      clean_and_exit 1 "Database Dump For $SINGLE_DB_NAME is empty or not available."
    fi
  else
    clean_and_exit 1 "Database file for dump_all not available to restore from"
  fi
}

#Restore all the databases
restore_all_dbs() {
  SQL_FILE=postgres.$POSTGRESQL_POD_NAMESPACE.all.sql
  if [ -f $RESTORE_DIR/$SQL_FILE ]
  then
    $PSQL postgres -f $RESTORE_DIR/$SQL_FILE 2>>$LOG_FILE >> $LOG_FILE
    if [ "$?" -eq 0 ]
    then
      echo "Database Restore successful."
    else
      clean_and_exit 1 "Database Restore failed."
    fi
  else
    clean_and_exit 1 "There is no database file available to restore from"
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
#Create Restore Directory if it's not created already
mkdir -p $RESTORE_DIR

#Cleanup Restore Directory
rm -rf $RESTORE_DIR/*

if [ ${#ARGS[@]} -gt 4 ]
then
  usage 1
elif [ ${#ARGS[@]} -eq 1 ]
then
  if [ "${ARGS[0]}" == "list_archives" ]
  then
    list_archives
    clean_and_exit 0 ""
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
    clean_and_exit 0 ""
  elif [ "${ARGS[0]}" == "list_archives" ]
  then
    list_archives ${ARGS[1]}
    clean_and_exit 0 ""
  else
    usage 1
  fi
elif [[ ${#ARGS[@]} -eq 3 ]] || [[ ${#ARGS[@]} -eq 4 ]]
then
  if [ "${ARGS[0]}" == "list_databases" ]
  then
    list_databases ${ARGS[1]} ${ARGS[2]}
    clean_and_exit 0 ""
  elif [ "${ARGS[0]}" != "restore" ]
  then
    usage 1
  else
    ARCHIVE=${ARGS[1]}
    DB_SPEC=${ARGS[2]}
    REMOTE=""
    if [ ${#ARGS[@]} -eq 4 ]
    then
      REMOTE=${ARGS[3]}
    fi

    #Get all the databases in that archive
    get_databases $ARCHIVE $REMOTE

    #check if the requested database is available in the archive
    if [ $(is_Option "$DBS" $DB_SPEC) -eq 1 ]
    then
      echo "Restoring Database $DB_SPEC And Grants"
      restore_single_db $DB_SPEC
      echo "Tail ${LOG_FILE} for restore log."
      clean_and_exit 0 ""
    elif [ "$( echo $DB_SPEC | tr '[a-z]' '[A-Z]')" == "ALL" ]
    then
      echo "Restoring All The Databases. This could take a few minutes..."
      restore_all_dbs
      clean_and_exit 0 "Tail ${LOG_FILE} for restore log."
    else
      clean_and_exit 1 "There is no database with that name"
    fi
  fi
else
  usage 1
fi

clean_and_exit 0 "Done"
