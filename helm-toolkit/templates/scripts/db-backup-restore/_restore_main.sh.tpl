{{- define "helm-toolkit.scripts.db-backup-restore.restore_main" }}
#!/bin/bash

# This file contains a database restore framework which database scripts
# can use to perform a backup. The idea here is that the database-specific
# functions will be implemented by the various databases using this script
# (like mariadb, postgresql or etcd for example). The database-specific
# script will need to first "source" this file like this:
#   source /tmp/restore_main.sh
#
# Then the script should call the main CLI function (cli_main):
#   cli_main <arg_list>
#       where:
#         <arg_list>    is the list of arguments given by the user
#
#       The framework will require the following variables to be exported:
#
#         export DB_NAMESPACE        Namespace where the database(s) reside
#         export DB_NAME             Name of the database system
#         export ARCHIVE_DIR         Location where the backup tarballs should
#                                    be stored. (full directory path which
#                                    should already exist)
#         export CONTAINER_NAME      Name of the container on the RGW where
#                                    the backups are stored.
#         RGW access variables:
#           export OS_REGION_NAME          Name of the region the RGW resides in
#           export OS_AUTH_URL             Keystone URL associated with the RGW
#           export OS_PROJECT_NAME         Name of the project associated with the
#                                          keystone user
#           export OS_USERNAME             Name of the keystone user
#           export OS_PASSWORD             Password of the keystone user
#           export OS_USER_DOMAIN_NAME     Keystone domain the project belongs to
#           export OS_PROJECT_DOMAIN_NAME  Keystone domain the user belongs to
#           export OS_IDENTITY_API_VERSION Keystone API version to use
#
# The database-specific functions that need to be implemented are:
#   get_databases
#       where:
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#         <db_file>     is the full path of the file to write the database
#                       names into, one database per line
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to extract the database names from the
#       uncompressed database files found in the given "tmp_dir", which is
#       the staging directory for database restore. The database names
#       should be written to the given "db_file", one database name per
#       line.
#
#   get_tables
#         <db_name>     is the name of the database to get the tables from
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#         <table_file>  is the full path of the file to write the table
#                       names into, one table per line
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to extract the table names from the given
#       database, found in the uncompressed database files located in the
#       given "tmp_dir", which is the staging directory for database restore.
#       The table names should be written to the given "table_file", one
#       table name per line.
#
#   get_rows
#         <table_name>  is the name of the table to get the rows from
#         <db_name>     is the name of the database the table resides in
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#         <rows_file>   is the full path of the file to write the table
#                       row data into, one row (INSERT statement) per line
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to extract the rows from the given table
#       in the given database, found in the uncompressed database files
#       located in the given "tmp_dir", which is the staging directory for
#       database restore. The table rows should be written to the given
#       "rows_file", one row (INSERT statement) per line.
#
#   get_schema
#         <table_name>  is the name of the table to get the schema from
#         <db_name>     is the name of the database the table resides in
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#         <schema_file> is the full path of the file to write the table
#                       schema data into
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to extract the schema from the given table
#       in the given database, found in the uncompressed database files
#       located in the given "tmp_dir", which is the staging directory for
#       database restore. The table schema and related alterations and
#       grant information should be written to the given "schema_file".
#
#   restore_single_db
#       where:
#         <db_name>     is the name of the database to be restored
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to restore the database given as "db_name"
#       using the database files located in the "tmp_dir". The framework
#       will delete the "tmp_dir" and the files in it after the restore is
#       complete.
#
#   restore_all_dbs
#       where:
#         <tmp_dir>     is the full directory path where the decompressed
#                       database files reside
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to restore all of the databases which
#       are backed up in the database files located in the "tmp_dir". The
#       framework will delete the "tmp_dir" and the files in it after the
#       restore is complete.
#
# The functions in this file will take care of:
#   1) The CLI parameter parsing for the arguments passed in by the user.
#   2) The listing of either local or remote archive files at the request
#      of the user.
#   3) The retrieval/download of an archive file located either in the local
#      file system or remotely stored on an RGW.
#   4) Calling either "restore_single_db" or "restore_all_dbs" when the user
#      chooses to restore a database or all databases.
#   5) The framework will call "get_databases" when it needs a list of
#      databases when the user requests a database list or when the user
#      requests to restore a single database (to ensure it exists in the
#      archive). Similarly, the framework will call "get_tables", "get_rows",
#      or "get_schema" when it needs that data requested by the user.
#

usage() {
  ret_val=$1
  echo "Usage:"
  echo "Restore command options"
  echo "============================="
  echo "help"
  echo "list_archives [remote]"
  echo "list_databases <archive_filename> [remote]"
  echo "list_tables <archive_filename> <dbname> [remote]"
  echo "list_rows <archive_filename> <dbname> <table_name> [remote]"
  echo "list_schema <archive_filename> <dbname> <table_name> [remote]"
  echo "restore <archive_filename> <db_specifier> [remote]"
  echo "        where <db_specifier> = <dbname> | ALL"
  echo "delete_archive <archive_filename> [remote]"
  clean_and_exit $ret_val ""
}

log() {
  #Log message to a file or stdout
  #TODO: This can be convert into mail alert of alert send to a monitoring system
  #Params: $1 log level
  #Params: $2 service
  #Params: $3 message
  #Params: $4 Destination
  LEVEL=$1
  SERVICE=$2
  MSG=$3
  DEST=$4
  DATE=$(date +"%m-%d-%y %H:%M:%S")
  if [[ -z "$DEST" ]]; then
    echo "${DATE} ${LEVEL}: $(hostname) ${SERVICE}: ${MSG}"
  else
    echo "${DATE} ${LEVEL}: $(hostname) ${SERVICE}: ${MSG}" >>$DEST
  fi
}

#Exit cleanly with some message and return code
clean_and_exit() {
  RETCODE=$1
  MSG=$2

  # Clean/remove temporary directories/files
  rm -rf $TMP_DIR
  rm -f $RESULT_FILE

  if [[ "x${MSG}" != "x" ]]; then
    echo $MSG
  fi
  exit $RETCODE
}

determine_resulting_error_code() {
  RESULT="$1"

  echo ${RESULT} | grep "HTTP 404"
  if [[ $? -eq 0 ]]; then
    log ERROR "${DB_NAME}_restore" "Could not find the archive: ${RESULT}"
    return 1
  else
    echo ${RESULT} | grep "HTTP 401"
    if [[ $? -eq 0 ]]; then
      log ERROR "${DB_NAME}_restore" "Could not access the archive: ${RESULT}"
      return 1
    else
      echo ${RESULT} | grep "HTTP 503"
      if [[ $? -eq 0 ]]; then
        log WARN "${DB_NAME}_restore" "RGW service is unavailable. ${RESULT}"
        # In this case, the RGW may be temporarily down.
        # Return slightly different error code so the calling code can retry
        return 2
      else
        echo ${RESULT} | grep "ConnectionError"
        if [[ $? -eq 0 ]]; then
          log WARN "${DB_NAME}_restore" "Could not reach the RGW: ${RESULT}"
          # In this case, keystone or the site/node may be temporarily down.
          # Return slightly different error code so the calling code can retry
          return 2
        else
          log ERROR "${DB_NAME}_restore" "Archive ${ARCHIVE} could not be retrieved: ${RESULT}"
          return 1
        fi
      fi
    fi
  fi
  return 0
}

# Retrieve a list of archives from the RGW.
function retrieve_remote_listing() {
  # List archives from PRIMARY RGW
  log INFO "${DB_NAME}_restore" "Listing archives from PRIMARY RGW..."
  list_archives_from_rgw "PRIMARY"
  local primary_result=$?

  # Check if failover environment variables are defined
  if [[ -n "${OS_AUTH_URL_FAILOVER}" ]] && \
    [[ -n "${OS_REGION_NAME_FAILOVER}" ]] && \
    [[ -n "${OS_INTERFACE_FAILOVER}" ]] && \
    [[ -n "${OS_PROJECT_DOMAIN_NAME_FAILOVER}" ]] && \
    [[ -n "${OS_PROJECT_NAME_FAILOVER}" ]] && \
    [[ -n "${OS_USER_DOMAIN_NAME_FAILOVER}" ]] && \
    [[ -n "${OS_USERNAME_FAILOVER}" ]] && \
    [[ -n "${OS_PASSWORD_FAILOVER}" ]]; then
    # Redefine OS_* variables with OS_*_FAILOVER ones
    log INFO "${DB_NAME}_restore" "Listing archives from FAILOVER RGW..."

    # Saving original OS_* variables as OS_*_PRIMARY
    export OS_AUTH_URL_PRIMARY=${OS_AUTH_URL}
    export OS_REGION_NAME_PRIMARY=${OS_REGION_NAME}
    export OS_INTERFACE_PRIMARY=${OS_INTERFACE}
    export OS_PROJECT_DOMAIN_NAME_PRIMARY=${OS_PROJECT_DOMAIN_NAME}
    export OS_PROJECT_NAME_PRIMARY=${OS_PROJECT_NAME}
    export OS_USER_DOMAIN_NAME_PRIMARY=${OS_USER_DOMAIN_NAME}
    export OS_USERNAME_PRIMARY=${OS_USERNAME}
    export OS_PASSWORD_PRIMARY=${OS_PASSWORD}
    export OS_DEFAULT_DOMAIN_PRIMARY=${OS_DEFAULT_DOMAIN}

    export OS_AUTH_URL=${OS_AUTH_URL_FAILOVER}
    export OS_REGION_NAME=${OS_REGION_NAME_FAILOVER}
    export OS_INTERFACE=${OS_INTERFACE_FAILOVER}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_FAILOVER}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_FAILOVER}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_FAILOVER}
    export OS_USERNAME=${OS_USERNAME_FAILOVER}
    export OS_PASSWORD=${OS_PASSWORD_FAILOVER}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_FAILOVER}

    list_archives_from_rgw "FAILOVER"
    local failover_result=$?

    # Restore original OS_* variables from OS_*_PRIMARY
    export OS_AUTH_URL=${OS_AUTH_URL_PRIMARY}
    export OS_REGION_NAME=${OS_REGION_NAME_PRIMARY}
    export OS_INTERFACE=${OS_INTERFACE_PRIMARY}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_PRIMARY}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_PRIMARY}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_PRIMARY}
    export OS_USERNAME=${OS_USERNAME_PRIMARY}
    export OS_PASSWORD=${OS_PASSWORD_PRIMARY}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_PRIMARY}

    # Return success if either primary or failover listing was successful
    if [[ $primary_result -eq 0 || $failover_result -eq 0 ]]; then
      return 0
    else
      return 1
    fi
  else
    # Return the result of the primary listing if failover variables are not defined
    return $primary_result
  fi
}

function list_archives_from_rgw() {
  local prefix=$1
  local RESULT

  log INFO "${DB_NAME}_restore" "Obtaining list of archives from ${prefix} RGW..."
  RESULT=$(openstack container show $CONTAINER_NAME 2>&1)
  if [[ $? -eq 0 ]]; then
    openstack object list $CONTAINER_NAME | grep $DB_NAME | grep $DB_NAMESPACE | awk -v prefix="$prefix" '{print prefix ":" $2}' >> $TMP_DIR/archive_list
    if [[ $? -ne 0 ]]; then
      log ERROR "${DB_NAME}_restore" "Container object listing could not be obtained from ${prefix} RGW."
      return 1
    else
      log INFO "${DB_NAME}_restore" "Archive listing successfully retrieved from ${prefix} RGW."
    fi
  else
    log ERROR "${DB_NAME}_restore" "Failed to obtain container show from ${prefix} RGW: ${RESULT}"
    return 1
  fi

  return 0
}

# Retrieve a single archive from the RGW.
retrieve_remote_archive() {
  local archive=$1
  local prefix=$(echo $archive | awk -F: '{print $1}')
  local filename

  if [[ $prefix == "PRIMARY" || $prefix == "FAILOVER" ]]; then
    filename=$(echo $archive | awk -F: '{print $2":"$3":"$4}')
  else
    filename=$archive
  fi

  if [[ $prefix == "PRIMARY" ]]; then
    log INFO "${DB_NAME}_restore" "Retrieving archive ${filename} from PRIMARY RGW..."
    retrieve_archive_from_rgw $filename
    return $?
  elif [[ $prefix == "FAILOVER" ]]; then
    log INFO "${DB_NAME}_restore" "Retrieving archive ${filename} from FAILOVER RGW..."

    # Saving original OS_* variables as OS_*_PRIMARY
    export OS_AUTH_URL_PRIMARY=${OS_AUTH_URL}
    export OS_REGION_NAME_PRIMARY=${OS_REGION_NAME}
    export OS_INTERFACE_PRIMARY=${OS_INTERFACE}
    export OS_PROJECT_DOMAIN_NAME_PRIMARY=${OS_PROJECT_DOMAIN_NAME}
    export OS_PROJECT_NAME_PRIMARY=${OS_PROJECT_NAME}
    export OS_USER_DOMAIN_NAME_PRIMARY=${OS_USER_DOMAIN_NAME}
    export OS_USERNAME_PRIMARY=${OS_USERNAME}
    export OS_PASSWORD_PRIMARY=${OS_PASSWORD}
    export OS_DEFAULT_DOMAIN_PRIMARY=${OS_DEFAULT_DOMAIN}

    # Redefine OS_* variables with OS_*_FAILOVER ones
    export OS_AUTH_URL=${OS_AUTH_URL_FAILOVER}
    export OS_REGION_NAME=${OS_REGION_NAME_FAILOVER}
    export OS_INTERFACE=${OS_INTERFACE_FAILOVER}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_FAILOVER}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_FAILOVER}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_FAILOVER}
    export OS_USERNAME=${OS_USERNAME_FAILOVER}
    export OS_PASSWORD=${OS_PASSWORD_FAILOVER}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_FAILOVER}

    retrieve_archive_from_rgw $filename
    local result=$?

    # Restore original OS_* variables from OS_*_PRIMARY
    export OS_AUTH_URL=${OS_AUTH_URL_PRIMARY}
    export OS_REGION_NAME=${OS_REGION_NAME_PRIMARY}
    export OS_INTERFACE=${OS_INTERFACE_PRIMARY}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_PRIMARY}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_PRIMARY}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_PRIMARY}
    export OS_USERNAME=${OS_USERNAME_PRIMARY}
    export OS_PASSWORD=${OS_PASSWORD_PRIMARY}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_PRIMARY}

    return $result
  else
    log ERROR "${DB_NAME}_restore" "Invalid prefix ${prefix} for archive ${archive}."
    return 1
  fi
}

# Function to retrieve an archive from RGW
retrieve_archive_from_rgw() {
  local filename=$1
  local RESULT

  log INFO "${DB_NAME}_restore" "Obtaining archive ${filename} from RGW..."
  RESULT=$(openstack object save --file $TMP_DIR/${filename} $CONTAINER_NAME ${filename}  2>&1)
  if [[ $? -eq 0 ]]; then
    log INFO "${DB_NAME}_restore" "Archive ${filename} successfully retrieved."
    return 0
  else
    log ERROR "${DB_NAME}_restore" "Failed to retrieve archive ${filename}."
    determine_resulting_error_code "${RESULT}"
    return $?
  fi
}

# Delete an archive from the RGW.
# Delete a single archive from the RGW.
delete_remote_archive() {
  local archive=$1
  local prefix=$(echo $archive | awk -F: '{print $1}')
  local filename

  if [[ $prefix == "PRIMARY" || $prefix == "FAILOVER" ]]; then
    filename=$(echo $archive | awk -F: '{print $2":"$3":"$4}')
  else
    filename=$archive
  fi

  if [[ $prefix == "PRIMARY" ]]; then
    log INFO "${DB_NAME}_restore" "Deleting archive ${filename} from PRIMARY RGW..."
    delete_archive_from_rgw $filename
    return $?
  elif [[ $prefix == "FAILOVER" ]]; then
    log INFO "${DB_NAME}_restore" "Deleting archive ${filename} from FAILOVER RGW..."

    # Saving original OS_* variables as OS_*_PRIMARY
    export OS_AUTH_URL_PRIMARY=${OS_AUTH_URL}
    export OS_REGION_NAME_PRIMARY=${OS_REGION_NAME}
    export OS_INTERFACE_PRIMARY=${OS_INTERFACE}
    export OS_PROJECT_DOMAIN_NAME_PRIMARY=${OS_PROJECT_DOMAIN_NAME}
    export OS_PROJECT_NAME_PRIMARY=${OS_PROJECT_NAME}
    export OS_USER_DOMAIN_NAME_PRIMARY=${OS_USER_DOMAIN_NAME}
    export OS_USERNAME_PRIMARY=${OS_USERNAME}
    export OS_PASSWORD_PRIMARY=${OS_PASSWORD}
    export OS_DEFAULT_DOMAIN_PRIMARY=${OS_DEFAULT_DOMAIN}

    # Redefine OS_* variables with OS_*_FAILOVER ones
    export OS_AUTH_URL=${OS_AUTH_URL_FAILOVER}
    export OS_REGION_NAME=${OS_REGION_NAME_FAILOVER}
    export OS_INTERFACE=${OS_INTERFACE_FAILOVER}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_FAILOVER}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_FAILOVER}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_FAILOVER}
    export OS_USERNAME=${OS_USERNAME_FAILOVER}
    export OS_PASSWORD=${OS_PASSWORD_FAILOVER}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_FAILOVER}

    delete_archive_from_rgw $filename
    local result=$?

    # Restore original OS_* variables from OS_*_PRIMARY
    export OS_AUTH_URL=${OS_AUTH_URL_PRIMARY}
    export OS_REGION_NAME=${OS_REGION_NAME_PRIMARY}
    export OS_INTERFACE=${OS_INTERFACE_PRIMARY}
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME_PRIMARY}
    export OS_PROJECT_NAME=${OS_PROJECT_NAME_PRIMARY}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME_PRIMARY}
    export OS_USERNAME=${OS_USERNAME_PRIMARY}
    export OS_PASSWORD=${OS_PASSWORD_PRIMARY}
    export OS_DEFAULT_DOMAIN=${OS_DEFAULT_DOMAIN_PRIMARY}

    return $result
  else
    log ERROR "${DB_NAME}_restore" "Invalid prefix ${prefix} for archive ${archive}."
    return 1
  fi
}

# Function to delete an archive from RGW
delete_archive_from_rgw() {
  local filename=$1
  local RESULT

  RESULT=$(openstack object delete $CONTAINER_NAME $filename 2>&1)
  if [[ $? -eq 0 ]]; then
    log INFO "${DB_NAME}_restore" "Archive ${filename} successfully deleted."
    return 0
  else
    log ERROR "${DB_NAME}_restore" "Failed to delete archive ${filename}."
    determine_resulting_error_code "${RESULT}"
    return $?
  fi
}

# Display all archives
list_archives() {
  REMOTE=$1

  if [[ "x${REMOTE^^}" == "xREMOTE" ]]; then
    retrieve_remote_listing
    if [[ $? -eq 0 && -e $TMP_DIR/archive_list ]]; then
      echo
      echo "All Archives from RGW Data Store"
      echo "=============================================="
      cat $TMP_DIR/archive_list | sort
      clean_and_exit 0 ""
    else
      clean_and_exit 1 "ERROR: Archives could not be retrieved from the RGW."
    fi
  elif [[ "x${REMOTE}" == "x" ]]; then
    if [[ -d $ARCHIVE_DIR ]]; then
      archives=$(find $ARCHIVE_DIR/ -iname "*.gz" -print | sort)
      echo
      echo "All Local Archives"
      echo "=============================================="
      for archive in $archives
      do
        echo $archive | cut -d '/' -f8-
      done
      clean_and_exit 0 ""
    else
      clean_and_exit 1 "ERROR: Local archive directory is not available."
    fi
  else
    usage 1
  fi
}

# Retrieve the archive from the desired location and decompress it into
# the restore directory
get_archive() {
  local archive=$1
  local prefix=$(echo $archive | awk -F: '{print $1}')
  local filename

  if [[ $prefix == "PRIMARY" || $prefix == "FAILOVER" ]]; then
    filename=$(echo $archive | awk -F: '{print $2":"$3":"$4}')
  else
    filename=$archive
  fi
  REMOTE=$2

  if [[ "x$REMOTE" == "xremote" ]]; then
    log INFO "${DB_NAME}_restore" "Retrieving archive ${prefix}:${filename} from the remote RGW..."
    retrieve_remote_archive ${prefix}:${filename}
    if [[ $? -ne 0 ]]; then
      clean_and_exit 1 "ERROR: Could not retrieve remote archive: ${prefix}:${filename}"
    fi
  elif [[ "x$REMOTE" == "x" ]]; then
    if [[ -e $ARCHIVE_DIR/$filename ]]; then
      cp $ARCHIVE_DIR/$filename $TMP_DIR/$filename
      if [[ $? -ne 0 ]]; then
        clean_and_exit 1 "ERROR: Could not copy local archive to restore directory."
      fi
    else
      clean_and_exit 1 "ERROR: Local archive file could not be found."
    fi
  else
    usage 1
  fi

  log INFO "${DB_NAME}_restore" "Decompressing archive $filename..."

  cd $TMP_DIR
  tar zxvf - < $TMP_DIR/$filename 1>/dev/null
  if [[ $? -ne 0 ]]; then
    clean_and_exit 1 "ERROR: Archive decompression failed."
  fi
}

# Display all databases from an archive
list_databases() {
  ARCHIVE_FILE=$1
  REMOTE=$2
  WHERE="local"

  if [[ -n ${REMOTE} ]]; then
    WHERE="remote"
  fi

  # Get the archive from the source location (local/remote)
  get_archive $ARCHIVE_FILE $REMOTE

  # Expectation is that the database listing will be put into
  # the given file one database per line
  get_databases $TMP_DIR $RESULT_FILE
  if [[ "$?" -ne 0 ]]; then
    clean_and_exit 1 "ERROR: Could not retrieve databases from $WHERE archive $ARCHIVE_FILE."
  fi

  if [[ -f "$RESULT_FILE" ]]; then
    echo " "
    echo "Databases in the $WHERE archive $ARCHIVE_FILE"
    echo "================================================================================"
    cat $RESULT_FILE
  else
    clean_and_exit 1 "ERROR: Databases file missing. Could not list databases from $WHERE archive $ARCHIVE_FILE."
  fi
}

# Display all tables of a database from an archive
list_tables() {
  ARCHIVE_FILE=$1
  DATABASE=$2
  REMOTE=$3
  WHERE="local"

  if [[ -n ${REMOTE} ]]; then
    WHERE="remote"
  fi

  # Get the archive from the source location (local/remote)
  get_archive $ARCHIVE_FILE $REMOTE

  # Expectation is that the database listing will be put into
  # the given file one table per line
  get_tables $DATABASE $TMP_DIR $RESULT_FILE
  if [[ "$?" -ne 0 ]]; then
    clean_and_exit 1 "ERROR: Could not retrieve tables for database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi

  if [[ -f "$RESULT_FILE" ]]; then
    echo " "
    echo "Tables in database $DATABASE from $WHERE archive $ARCHIVE_FILE"
    echo "================================================================================"
    cat $RESULT_FILE
  else
    clean_and_exit 1 "ERROR: Tables file missing. Could not list tables of database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi
}

# Display all rows of the given database table from an archive
list_rows() {
  ARCHIVE_FILE=$1
  DATABASE=$2
  TABLE=$3
  REMOTE=$4
  WHERE="local"

  if [[ -n ${REMOTE} ]]; then
    WHERE="remote"
  fi

  # Get the archive from the source location (local/remote)
  get_archive $ARCHIVE_FILE $REMOTE

  # Expectation is that the database listing will be put into
  # the given file one table per line
  get_rows $DATABASE $TABLE $TMP_DIR $RESULT_FILE
  if [[ "$?" -ne 0 ]]; then
    clean_and_exit 1 "ERROR: Could not retrieve rows in table ${TABLE} of database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi

  if [[ -f "$RESULT_FILE" ]]; then
    echo " "
    echo "Rows in table $TABLE of database $DATABASE from $WHERE archive $ARCHIVE_FILE"
    echo "================================================================================"
    cat $RESULT_FILE
  else
    clean_and_exit 1 "ERROR: Rows file missing. Could not list rows in table ${TABLE} of database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi
}

# Display the schema information of the given database table from an archive
list_schema() {
  ARCHIVE_FILE=$1
  DATABASE=$2
  TABLE=$3
  REMOTE=$4
  WHERE="local"

  if [[ -n ${REMOTE} ]]; then
    WHERE="remote"
  fi

  # Get the archive from the source location (local/remote)
  get_archive $ARCHIVE_FILE $REMOTE

  # Expectation is that the schema information will be placed into
  # the given schema file.
  get_schema $DATABASE $TABLE $TMP_DIR $RESULT_FILE
  if [[ "$?" -ne 0 ]]; then
    clean_and_exit 1 "ERROR: Could not retrieve schema for table ${TABLE} of database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi

  if [[ -f "$RESULT_FILE" ]]; then
    echo " "
    echo "Schema for table $TABLE of database $DATABASE from $WHERE archive $ARCHIVE_FILE"
    echo "================================================================================"
    cat $RESULT_FILE
  else
    clean_and_exit 1 "ERROR: Schema file missing. Could not list schema for table ${TABLE} of database ${DATABASE} from $WHERE archive $ARCHIVE_FILE."
  fi
}

# Delete an archive
delete_archive() {
  ARCHIVE_FILE=$1
  REMOTE=$2
  WHERE="local"

  if [[ -n ${REMOTE} ]]; then
    WHERE="remote"
  fi

  if [[ "${WHERE}" == "remote" ]]; then
    delete_remote_archive ${ARCHIVE_FILE}
    if [[ $? -ne 0 ]]; then
      clean_and_exit 1 "ERROR: Could not delete remote archive: ${ARCHIVE_FILE}"
    fi
  else # Local
    if [[ -e ${ARCHIVE_DIR}/${ARCHIVE_FILE} ]]; then
      rm -f ${ARCHIVE_DIR}/${ARCHIVE_FILE}
      if [[ $? -ne 0 ]]; then
        clean_and_exit 1 "ERROR: Could not delete local archive."
      fi
    else
      clean_and_exit 1 "ERROR: Local archive file could not be found."
    fi
  fi

  log INFO "${DB_NAME}_restore" "Successfully deleted archive ${ARCHIVE_FILE} from ${WHERE} storage."
}


# Return 1 if the given database exists in the database file. 0 otherwise.
database_exists() {
  DB=$1

  grep "${DB}" ${RESULT_FILE}
  if [[ $? -eq 0 ]]; then
    return 1
  fi
  return 0
}

# This is the main CLI interpreter function
cli_main() {
  ARGS=("$@")

  # Create the ARCHIVE DIR if it's not already there.
  mkdir -p $ARCHIVE_DIR

  # Create temp directory for a staging area to decompress files into
  export TMP_DIR=$(mktemp -d)

  # Create a temp file for storing list of databases (if needed)
  export RESULT_FILE=$(mktemp -p /tmp)

  case "${ARGS[0]}" in
    "help")
      usage 0
      ;;

    "list_archives")
      if [[ ${#ARGS[@]} -gt 2 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 1 ]]; then
        list_archives
      else
        list_archives ${ARGS[1]}
      fi
      clean_and_exit 0
      ;;

    "list_databases")
      if [[ ${#ARGS[@]} -lt 2 || ${#ARGS[@]} -gt 3 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 2 ]]; then
        list_databases ${ARGS[1]}
      else
        list_databases ${ARGS[1]} ${ARGS[2]}
      fi
      ;;

    "list_tables")
      if [[ ${#ARGS[@]} -lt 3 || ${#ARGS[@]} -gt 4 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 3 ]]; then
        list_tables ${ARGS[1]} ${ARGS[2]}
      else
        list_tables ${ARGS[1]} ${ARGS[2]} ${ARGS[3]}
      fi
      ;;

    "list_rows")
      if [[ ${#ARGS[@]} -lt 4 || ${#ARGS[@]} -gt 5 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 4 ]]; then
        list_rows ${ARGS[1]} ${ARGS[2]} ${ARGS[3]}
      else
        list_rows ${ARGS[1]} ${ARGS[2]} ${ARGS[3]} ${ARGS[4]}
      fi
      ;;

    "list_schema")
      if [[ ${#ARGS[@]} -lt 4 || ${#ARGS[@]} -gt 5 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 4 ]]; then
        list_schema ${ARGS[1]} ${ARGS[2]} ${ARGS[3]}
      else
        list_schema ${ARGS[1]} ${ARGS[2]} ${ARGS[3]} ${ARGS[4]}
      fi
      ;;

    "restore")
      REMOTE=""
      if [[ ${#ARGS[@]} -lt 3 || ${#ARGS[@]} -gt 4 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 4 ]]; then
        REMOTE=${ARGS[3]}
      fi

      ARCHIVE=${ARGS[1]}
      DB_SPEC=${ARGS[2]}

      #Get all the databases in that archive
      get_archive $ARCHIVE $REMOTE

      if [[ "$( echo $DB_SPEC | tr '[a-z]' '[A-Z]')" != "ALL" ]]; then
        # Expectation is that the database listing will be put into
        # the given file one database per line
        get_databases $TMP_DIR $RESULT_FILE
        if [[ "$?" -ne 0 ]]; then
          clean_and_exit 1 "ERROR: Could not get the list of databases to restore."
        fi

        if [[ ! $DB_NAMESPACE == "kube-system" ]]; then
          #check if the requested database is available in the archive
          database_exists $DB_SPEC
          if [[ $? -ne 1 ]]; then
            clean_and_exit 1 "ERROR: Database ${DB_SPEC} does not exist."
          fi
        fi

        log INFO "${DB_NAME}_restore" "Restoring Database $DB_SPEC And Grants"
        restore_single_db $DB_SPEC $TMP_DIR
        if [[ "$?" -eq 0 ]]; then
          log INFO "${DB_NAME}_restore" "Single database restored successfully."
        else
          clean_and_exit 1 "ERROR: Single database restore failed."
        fi
        clean_and_exit 0 ""
      else
        log INFO "${DB_NAME}_restore" "Restoring All The Databases. This could take a few minutes..."
        restore_all_dbs $TMP_DIR
        if [[ "$?" -eq 0 ]]; then
          log INFO "${DB_NAME}_restore" "All databases restored successfully."
        else
          clean_and_exit 1 "ERROR: Database restore failed."
        fi
        clean_and_exit 0 ""
      fi
      ;;
    "delete_archive")
      if [[ ${#ARGS[@]} -lt 2 || ${#ARGS[@]} -gt 3 ]]; then
        usage 1
      elif [[ ${#ARGS[@]} -eq 2 ]]; then
        delete_archive ${ARGS[1]}
      else
        delete_archive ${ARGS[1]} ${ARGS[2]}
      fi
      ;;
    *)
      usage 1
      ;;
  esac

  clean_and_exit 0 ""
}
{{- end }}
