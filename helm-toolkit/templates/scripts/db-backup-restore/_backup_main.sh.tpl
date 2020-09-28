{{- define "helm-toolkit.scripts.db-backup-restore.backup_main" }}
#!/bin/bash

# This file contains a database backup framework which database scripts
# can use to perform a backup. The idea here is that the database-specific
# functions will be implemented by the various databases using this script
# (like mariadb, postgresql or etcd for example). The database-specific
# script will need to first "source" this file like this:
#   source /tmp/backup_main.sh
#
# Then the script should call the main backup function (backup_databases):
#   backup_databases [scope]
#       [scope] is an optional parameter, defaulted to "all". If only one specific
#               database is required to be backed up then this parameter will
#               contain the name of the database; otherwise all are backed up.
#
#       The framework will require the following variables to be exported:
#
#         export DB_NAMESPACE          Namespace where the database(s) reside
#         export DB_NAME               Name of the database system
#         export LOCAL_DAYS_TO_KEEP    Number of days to keep the local backups
#         export REMOTE_DAYS_TO_KEEP   Number of days to keep the remote backups
#         export ARCHIVE_DIR           Local location where the backup tarballs should
#                                      be stored. (full directory path)
#         export REMOTE_BACKUP_ENABLED "true" if remote backup enabled; false
#                                      otherwise
#         export CONTAINER_NAME        Name of the container on the RGW to store
#                                      the backup tarball.
#         export STORAGE_POLICY        Name of the storage policy defined on the
#                                      RGW which is intended to store backups.
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
#       The following variables are optional:
#         export RGW_TIMEOUT           Number of seconds to wait for the
#                                      connection to the RGW to be available
#                                      when sending a backup to the RGW. Default
#                                      is 1800 (30 minutes).
#
# The database-specific functions that need to be implemented are:
#   dump_databases_to_directory <directory> <err_logfile> [scope]
#       where:
#         <directory>   is the full directory path to dump the database files
#                       into. This is a temporary directory for this backup only.
#         <err_logfile> is the full directory path where error logs are to be
#                       written by the application.
#         [scope]       set to "all" if all databases are to be backed up; or
#                       set to the name of a specific database to be backed up.
#                       This optional parameter is defaulted to "all".
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to dump the database file(s) to the specified
#       directory path. If this function completes successfully (returns 0), the
#       framework will automatically tar/zip the files in that directory and
#       name the tarball appropriately according to the proper conventions.
#
# The functions in this file will take care of:
#   1) Calling "dump_databases_to_directory" and then compressing the files,
#      naming the tarball properly, and then storing it locally at the specified
#      local directory.
#   2) Sending the tarball built to the remote gateway, to be stored in the
#      container configured to store database backups.
#   3) Removing local backup tarballs which are older than the number of days
#      specified by the "LOCAL_DAYS_TO_KEEP" variable.
#   4) Removing remote backup tarballs (from the remote gateway) which are older
#      than the number of days specified by the "REMOTE_DAYS_TO_KEEP" variable.
#

# Note: not using set -e in this script because more elaborate error handling
# is needed.
set -x

log_backup_error_exit() {
  MSG=$1
  ERRCODE=$2
  log ERROR "${DB_NAME}_backup" "${DB_NAMESPACE} namespace: ${MSG}"
  rm -f $ERR_LOG_FILE
  rm -rf $TMP_DIR
  exit $ERRCODE
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

#Get the day delta since the archive file backup
seconds_difference() {
  ARCHIVE_DATE=$( date --date="$1" +%s )
  if [[ $? -ne 0 ]]; then
    SECOND_DELTA=0
  fi
  CURRENT_DATE=$( date +%s )
  SECOND_DELTA=$(($CURRENT_DATE-$ARCHIVE_DATE))
  if [[ "$SECOND_DELTA" -lt 0 ]]; then
    SECOND_DELTA=0
  fi
  echo $SECOND_DELTA
}

# Send the specified tarball file at the specified filepath to the
# remote gateway.
send_to_remote_server() {
  FILEPATH=$1
  FILE=$2

  # Grab the list of containers on the remote site
  RESULT=$(openstack container list 2>&1)

  if [[ $? -eq 0 ]]; then
    echo $RESULT | grep $CONTAINER_NAME
    if [[ $? -ne 0 ]]; then
      # Find the swift URL from the keystone endpoint list
      SWIFT_URL=$(openstack catalog show object-store -c endpoints | grep public | awk '{print $4}')

      # Get a token from keystone
      TOKEN=$(openstack token issue -f value -c id)

      # Create the container
      RES_FILE=$(mktemp -p /tmp)
      curl -g -i -X PUT ${SWIFT_URL}/${CONTAINER_NAME} \
           -H "X-Auth-Token: ${TOKEN}" \
           -H "X-Storage-Policy: ${STORAGE_POLICY}" 2>&1 > $RES_FILE

      if [[ $? -ne 0 || $(grep "HTTP" $RES_FILE | awk '{print $2}') -ge 400 ]]; then
        log ERROR "${DB_NAME}_backup" "Error creating container ${CONTAINER_NAME}"
        cat $RES_FILE
        rm -f $RES_FILE
        return 1
      fi
      rm -f $RES_FILE

      swift stat $CONTAINER_NAME
      if [[ $? -ne 0 ]]; then
        log ERROR "${DB_NAME}_backup" "Error retrieving container ${CONTAINER_NAME} details after creation."
        return 1
      fi
    fi
  else
    echo $RESULT | grep "HTTP 401"
    if [[ $? -eq 0 ]]; then
      log ERROR "${DB_NAME}_backup" "Access denied by keystone: ${RESULT}"
      return 1
    else
      echo $RESULT | grep -E "ConnectionError|Failed to discover available identity versions"
      if [[ $? -eq 0 ]]; then
        log ERROR "${DB_NAME}_backup" "Could not reach the RGW: ${RESULT}"
        # In this case, keystone or the site/node may be temporarily down.
        # Return slightly different error code so the calling code can retry
        return 2
      else
        log ERROR "${DB_NAME}_backup" "Could not get container list: ${RESULT}"
        return 1
      fi
    fi
  fi

  # Create an object to store the file
  openstack object create --name $FILE $CONTAINER_NAME $FILEPATH/$FILE || log ERROR "${DB_NAME}_backup" "Cannot create container object ${FILE}!"
  openstack object show $CONTAINER_NAME $FILE
  if [[ $? -ne 0 ]]; then
    log ERROR "${DB_NAME}_backup" "Error retrieving container object $FILE after creation."
    return 1
  fi

  log INFO "${DB_NAME}_backup" "Created file $FILE in container $CONTAINER_NAME successfully."
  return 0
}

# This function attempts to store the built tarball to the remote gateway,
# with built-in logic to handle error cases like:
#   1) Network connectivity issues - retries for a specific amount of time
#   2) Authorization errors - immediately logs an ERROR and returns
store_backup_remotely() {
  FILEPATH=$1
  FILE=$2

  # If the RGW_TIMEOUT has already been set, use that value, otherwise give it
  # a default value.
  if [[ -z $RGW_TIMEOUT ]]; then
    RGW_TIMEOUT=1800
  fi

  ERROR_SEEN=false
  DONE=false
  TIMEOUT_EXP=$(( $(date +%s) + $RGW_TIMEOUT ))
  while [[ $DONE == "false" ]]; do
    # Store the new archive to the remote backup storage facility.
    send_to_remote_server $FILEPATH $FILE

    # Check if successful
    if [[ $? -eq 0 ]]; then
      log INFO "${DB_NAME}_backup" "Backup file ${FILE} successfully sent to RGW."
      DONE=true
    elif [[ $? -eq 2 ]]; then
      # Temporary failure occurred. We need to retry if we have not timed out
      log WARN "${DB_NAME}_backup" "Backup file ${FILE} could not be sent to RGW due to connection issue."
      DELTA=$(( TIMEOUT_EXP - $(date +%s) ))
      if [[ $DELTA -lt 0 ]]; then
        DONE=true
        log ERROR "${DB_NAME}_backup" "Timed out waiting for RGW to become available."
        ERROR_SEEN=true
      else
        log INFO "${DB_NAME}_backup" "Sleeping 30 seconds waiting for RGW to become available..."
        sleep 30
        log INFO "${DB_NAME}_backup" "Retrying..."
      fi
    else
      log ERROR "${DB_NAME}_backup" "Backup file ${FILE} could not be sent to the RGW."
      ERROR_SEEN=true
      DONE=true
    fi
  done

  if [[ $ERROR_SEEN == "true" ]]; then
    log ERROR "${DB_NAME}_backup" "Errors encountered. Exiting."
    return 1
  fi
  return 0
}

remove_old_local_archives() {
  log INFO "${DB_NAME}_backup" "Deleting backups older than ${LOCAL_DAYS_TO_KEEP} days"
  if [[ -d $ARCHIVE_DIR ]]; then
    for ARCHIVE_FILE in $(ls -1 $ARCHIVE_DIR/*.gz); do
      ARCHIVE_DATE=$( echo $ARCHIVE_FILE | awk -F/ '{print $NF}' | cut -d'.' -f 4)
      if [[ "$(seconds_difference $ARCHIVE_DATE)" -gt "$(($LOCAL_DAYS_TO_KEEP*86400))" ]]; then
        log INFO "${DB_NAME}_backup" "Deleting file $ARCHIVE_FILE."
        rm -rf $ARCHIVE_FILE
        if [[ $? -ne 0 ]]; then
          # Log error but don't exit so we can finish the script
          # because at this point we haven't sent backup to RGW yet
          log ERROR "${DB_NAME}_backup" "Cannot remove ${ARCHIVE_FILE}"
        fi
      else
        log INFO "${DB_NAME}_backup" "Keeping file ${ARCHIVE_FILE}."
      fi
    done
  fi
}

remove_old_remote_archives() {
  log INFO "${DB_NAME}_backup" "Deleting backups older than ${REMOTE_DAYS_TO_KEEP} days"
  BACKUP_FILES=$(mktemp -p /tmp)
  DB_BACKUP_FILES=$(mktemp -p /tmp)

  openstack object list $CONTAINER_NAME > $BACKUP_FILES
  if [[ $? -ne 0 ]]; then
    log_backup_error_exit "Could not obtain a list of current backup files in the RGW" 1
  fi

  # Filter out other types of backup files
  cat $BACKUP_FILES | grep $DB_NAME | grep $DB_NAMESPACE | awk '{print $2}' > $DB_BACKUP_FILES

  for ARCHIVE_FILE in $(cat $DB_BACKUP_FILES); do
    ARCHIVE_DATE=$( echo $ARCHIVE_FILE | awk -F/ '{print $NF}' | cut -d'.' -f 4)
    if [[ "$(seconds_difference ${ARCHIVE_DATE})" -gt "$((${REMOTE_DAYS_TO_KEEP}*86400))" ]]; then
      log INFO "${DB_NAME}_backup" "Deleting file ${ARCHIVE_FILE} from the RGW"
      openstack object delete $CONTAINER_NAME $ARCHIVE_FILE || log_backup_error_exit "Cannot delete container object ${ARCHIVE_FILE}!" 1
    fi
  done

  # Cleanup now that we're done.
  rm -f $BACKUP_FILES $DB_BACKUP_FILES
}

# Main function to backup the databases. Calling functions need to supply:
#  1) The directory where the final backup will be kept after it is compressed.
#  2) A temporary directory to use for placing database files to be compressed.
#     Note: this temp directory will be deleted after backup is done.
#  3) Optional "scope" parameter indicating what database to back up. Defaults
#     to "all".
backup_databases() {
  SCOPE=${1:-"all"}

  # Create necessary directories if they do not exist.
  mkdir -p $ARCHIVE_DIR || log_backup_error_exit "Cannot create directory ${ARCHIVE_DIR}!"
  export TMP_DIR=$(mktemp -d) || log_backup_error_exit "Cannot create temp directory!"

  # Create temporary log file
  export ERR_LOG_FILE=$(mktemp -p /tmp) || log_backup_error_exit "Cannot create log file!"

  # It is expected that this function will dump the database files to the $TMP_DIR
  dump_databases_to_directory $TMP_DIR $ERR_LOG_FILE $SCOPE

  # If successful, there should be at least one file in the TMP_DIR
  if [[ $? -ne 0 || $(ls $TMP_DIR | wc -w) -eq 0 ]]; then
    cat $ERR_LOG_FILE
    log_backup_error_exit "Backup of the ${DB_NAME} database failed and needs attention."
  fi

  log INFO "${DB_NAME}_backup" "Databases dumped successfully. Creating tarball..."

  NOW=$(date +"%Y-%m-%dT%H:%M:%SZ")
  TARBALL_FILE="${DB_NAME}.${DB_NAMESPACE}.${SCOPE}.${NOW}.tar.gz"

  cd $TMP_DIR || log_backup_error_exit "Cannot change to directory $TMP_DIR"

  #Archive the current database files
  tar zcvf $ARCHIVE_DIR/$TARBALL_FILE *
  if [[ $? -ne 0 ]]; then
    log_backup_error_exit "Backup tarball could not be created."
  fi

  # Get the size of the file
  ARCHIVE_SIZE=$(ls -l $ARCHIVE_DIR/$TARBALL_FILE | awk '{print $5}')

  log INFO "${DB_NAME}_backup" "Tarball $TARBALL_FILE created successfully."

  cd $ARCHIVE_DIR

  # Remove the temporary directory and files as they are no longer needed.
  rm -rf $TMP_DIR
  rm -f $ERR_LOG_FILE

  #Only delete the old archive after a successful archive
  export LOCAL_DAYS_TO_KEEP=$(echo $LOCAL_DAYS_TO_KEEP | sed 's/"//g')
  if [[ "$LOCAL_DAYS_TO_KEEP" -gt 0 ]]; then
    remove_old_local_archives
  fi

  REMOTE_BACKUP=$(echo $REMOTE_BACKUP_ENABLED | sed 's/"//g')
  if $REMOTE_BACKUP; then
    store_backup_remotely $ARCHIVE_DIR $TARBALL_FILE
    if [[ $? -ne 0 ]]; then
      # This error should print first, then print the summary as the last
      # thing that the user sees in the output.
      log ERROR "${DB_NAME}_backup" "Backup ${TARBALL_FILE} could not be sent to remote RGW."
      set +x
      echo "=================================================================="
      echo "Local backup successful, but could not send to remote RGW."
      echo "Backup archive name: $TARBALL_FILE"
      echo "Backup archive size: $ARCHIVE_SIZE"
      echo "=================================================================="
      set -x
      # Because the local backup was successful, exit with 0 so the pod will not
      # continue to restart and fill the disk with more backups. The ERRORs are
      # logged and alerting system should catch those errors and flag the operator.
      exit 0
    fi

    #Only delete the old archive after a successful archive
    export REMOTE_DAYS_TO_KEEP=$(echo $REMOTE_DAYS_TO_KEEP | sed 's/"//g')
    if [[ "$REMOTE_DAYS_TO_KEEP" -gt 0 ]]; then
      remove_old_remote_archives
    fi

    # Turn off trace just for a clearer printout of backup status - for manual backups, mainly.
    set +x
    echo "=================================================================="
    echo "Local backup and backup to remote RGW successful!"
    echo "Backup archive name: $TARBALL_FILE"
    echo "Backup archive size: $ARCHIVE_SIZE"
    echo "=================================================================="
    set -x
  else
    # Remote backup is not enabled. This is ok; at least we have a local backup.
    log INFO "${DB_NAME}_backup" "Skipping remote backup, as it is not enabled."

    # Turn off trace just for a clearer printout of backup status - for manual backups, mainly.
    set +x
    echo "=================================================================="
    echo "Local backup successful!"
    echo "Backup archive name: $TARBALL_FILE"
    echo "Backup archive size: $ARCHIVE_SIZE"
    echo "=================================================================="
    set -x
  fi
}
{{- end }}
