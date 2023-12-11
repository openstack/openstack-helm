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
#         export BACK_UP_MODE          Determines the mode of backup taken.
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
#           export REMOTE_BACKUP_RETRIES   Number of retries to send backup to remote
#                                          in case of any temporary failures.
#           export MIN_DELAY_SEND_REMOTE   Minimum seconds to delay before sending backup
#                                          to remote to stagger backups being sent to RGW
#           export MAX_DELAY_SEND_REMOTE   Maximum seconds to delay before sending backup
#                                          to remote to stagger backups being sent to RGW.
#                                          A random number between min and max delay is generated
#                                          to set the delay.
#
#         RGW backup throttle limits variables:
#           export THROTTLE_BACKUPS_ENABLED   Boolean variableto control backup functionality
#           export THROTTLE_LIMIT             Number of simultaneous RGW upload sessions
#           export THROTTLE_LOCK_EXPIRE_AFTER Time in seconds to expire flag file is orphaned
#           export THROTTLE_RETRY_AFTER       Time in seconds to wait before retry
#           export THROTTLE_CONTAINER_NAME    Name of RGW container to place flag falies into
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
#   verify_databases_backup_archives [scope]
#       returns: 0 if no errors; 1 if any errors occurred
#
#       This function is expected to verify the database backup archives. If this function
#        completes successfully (returns 0), the
#       framework will automatically starts remote backup upload.
#
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
#   5) Controlling remote storage gateway load from client side and throttling it
#      by using a dedicated RGW container to store flag files defining upload session
#      in progress
#
# Note: not using set -e in this script because more elaborate error handling
# is needed.

log_backup_error_exit() {
  MSG=$1
  ERRCODE=${2:-0}
  log ERROR "${DB_NAME}_backup" "${DB_NAMESPACE} namespace: ${MSG}"
  rm -f $ERR_LOG_FILE
  rm -rf $TMP_DIR
  exit 0
}

log_verify_backup_exit() {
  MSG=$1
  ERRCODE=${2:-0}
  log ERROR "${DB_NAME}_verify_backup" "${DB_NAMESPACE} namespace: ${MSG}"
  rm -f $ERR_LOG_FILE
  # rm -rf $TMP_DIR
  exit 0
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

# Generate a random number between MIN_DELAY_SEND_REMOTE and
# MAX_DELAY_SEND_REMOTE
random_number() {
  diff=$((${MAX_DELAY_SEND_REMOTE} - ${MIN_DELAY_SEND_REMOTE} + 1))
  echo $(($(( ${RANDOM} % ${diff} )) + ${MIN_DELAY_SEND_REMOTE} ))
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
      if [[ $? -ne 0 ]]; then
        log WARN "${DB_NAME}_backup" "Unable to get object-store enpoints from keystone catalog."
        return 2
      fi

      # Get a token from keystone
      TOKEN=$(openstack token issue -f value -c id)
      if [[ $? -ne 0 ]]; then
        log WARN "${DB_NAME}_backup" "Unable to get  keystone token."
        return 2
      fi

      # Create the container
      RES_FILE=$(mktemp -p /tmp)
      curl -g -i -X PUT ${SWIFT_URL}/${CONTAINER_NAME} \
           -H "X-Auth-Token: ${TOKEN}" \
           -H "X-Storage-Policy: ${STORAGE_POLICY}" 2>&1 > $RES_FILE

      if [[ $? -ne 0 || $(grep "HTTP" $RES_FILE | awk '{print $2}') -ge 400 ]]; then
        log WARN "${DB_NAME}_backup" "Unable to create container ${CONTAINER_NAME}"
        cat $RES_FILE
        rm -f $RES_FILE
        return 2
      fi
      rm -f $RES_FILE

      swift stat $CONTAINER_NAME
      if [[ $? -ne 0 ]]; then
        log WARN "${DB_NAME}_backup" "Unable to retrieve container ${CONTAINER_NAME} details after creation."
        return 2
      fi
    fi
  else
    echo $RESULT | grep -E "HTTP 401|HTTP 403"
    if [[ $? -eq 0 ]]; then
      log ERROR "${DB_NAME}_backup" "Access denied by keystone: ${RESULT}"
      return 1
    else
      echo $RESULT | grep -E "ConnectionError|Failed to discover available identity versions|Service Unavailable|HTTP 50"
      if [[ $? -eq 0 ]]; then
        log WARN "${DB_NAME}_backup" "Could not reach the RGW: ${RESULT}"
        # In this case, keystone or the site/node may be temporarily down.
        # Return slightly different error code so the calling code can retry
        return 2
      else
        log ERROR "${DB_NAME}_backup" "Could not get container list: ${RESULT}"
        return 1
      fi
    fi
  fi

  # load balance delay
  DELAY=$((1 + ${RANDOM} % 30))
  echo "Sleeping for ${DELAY} seconds to spread the load in time..."
  sleep ${DELAY}

  #---------------------------------------------------------------------------
  # Remote backup throttling
  export THROTTLE_BACKUPS_ENABLED=$(echo $THROTTLE_BACKUPS_ENABLED | sed 's/"//g')
  if $THROTTLE_BACKUPS_ENABLED; then
    # Remove Quotes from the constants which were added due to reading
    # from secret.
    export THROTTLE_LIMIT=$(echo $THROTTLE_LIMIT | sed 's/"//g')
    export THROTTLE_LOCK_EXPIRE_AFTER=$(echo $THROTTLE_LOCK_EXPIRE_AFTER | sed 's/"//g')
    export THROTTLE_RETRY_AFTER=$(echo $THROTTLE_RETRY_AFTER | sed 's/"//g')
    export THROTTLE_CONTAINER_NAME=$(echo $THROTTLE_CONTAINER_NAME | sed 's/"//g')

    # load balance delay
    RESULT=$(openstack container list 2>&1)

    if [[ $? -eq 0 ]]; then
      echo $RESULT | grep $THROTTLE_CONTAINER_NAME
      if [[ $? -ne 0 ]]; then
        # Find the swift URL from the keystone endpoint list
        SWIFT_URL=$(openstack catalog show object-store -c endpoints | grep public | awk '{print $4}')
        if [[ $? -ne 0 ]]; then
          log WARN "${DB_NAME}_backup" "Unable to get object-store enpoints from keystone catalog."
          return 2
        fi

        # Get a token from keystone
        TOKEN=$(openstack token issue -f value -c id)
        if [[ $? -ne 0 ]]; then
          log WARN "${DB_NAME}_backup" "Unable to get  keystone token."
          return 2
        fi

        # Create the container
        RES_FILE=$(mktemp -p /tmp)
        curl -g -i -X PUT ${SWIFT_URL}/${THROTTLE_CONTAINER_NAME} \
            -H "X-Auth-Token: ${TOKEN}" \
            -H "X-Storage-Policy: ${STORAGE_POLICY}" 2>&1 > $RES_FILE

        if [[ $? -ne 0 || $(grep "HTTP" $RES_FILE | awk '{print $2}') -ge 400 ]]; then
          log WARN "${DB_NAME}_backup" "Unable to create container ${THROTTLE_CONTAINER_NAME}"
          cat $RES_FILE
          rm -f $RES_FILE
          return 2
        fi
        rm -f $RES_FILE

        swift stat $THROTTLE_CONTAINER_NAME
        if [[ $? -ne 0 ]]; then
          log WARN "${DB_NAME}_backup" "Unable to retrieve container ${THROTTLE_CONTAINER_NAME} details after creation."
          return 2
        fi
      fi
    else
      echo $RESULT | grep -E "HTTP 401|HTTP 403"
      if [[ $? -eq 0 ]]; then
        log ERROR "${DB_NAME}_backup" "Access denied by keystone: ${RESULT}"
        return 1
      else
        echo $RESULT | grep -E "ConnectionError|Failed to discover available identity versions|Service Unavailable|HTTP 50"
        if [[ $? -eq 0 ]]; then
          log WARN "${DB_NAME}_backup" "Could not reach the RGW: ${RESULT}"
          # In this case, keystone or the site/node may be temporarily down.
          # Return slightly different error code so the calling code can retry
          return 2
        else
          log ERROR "${DB_NAME}_backup" "Could not get container list: ${RESULT}"
          return 1
        fi
      fi
    fi

    NUMBER_OF_SESSIONS=$(openstack object list $THROTTLE_CONTAINER_NAME -f value | wc -l)
    log INFO  "${DB_NAME}_backup"  "There are ${NUMBER_OF_SESSIONS} remote sessions right now."
    while [[ ${NUMBER_OF_SESSIONS} -ge ${THROTTLE_LIMIT} ]]
    do
      log INFO "${DB_NAME}_backup" "Current number of active uploads is ${NUMBER_OF_SESSIONS}>=${THROTTLE_LIMIT}!"
      log INFO "${DB_NAME}_backup" "Retrying in ${THROTTLE_RETRY_AFTER} seconds...."
      sleep ${THROTTLE_RETRY_AFTER}
      NUMBER_OF_SESSIONS=$(openstack object list $THROTTLE_CONTAINER_NAME -f value | wc -l)
      log INFO  "${DB_NAME}_backup"  "There are ${NUMBER_OF_SESSIONS} remote sessions right now."
    done

    # Create a lock file in THROTTLE_CONTAINER
    THROTTLE_FILEPATH=$(mktemp -d)
    THROTTLE_FILE=${CONTAINER_NAME}.lock
    date +%s > $THROTTLE_FILEPATH/$THROTTLE_FILE

    # Create an object to store the file
    openstack object create --name $THROTTLE_FILE $THROTTLE_CONTAINER_NAME $THROTTLE_FILEPATH/$THROTTLE_FILE
    if [[ $? -ne 0 ]]; then
      log WARN "${DB_NAME}_backup" "Cannot create throttle container object ${THROTTLE_FILE}!"
      return 2
    fi

    swift post  $THROTTLE_CONTAINER_NAME $THROTTLE_FILE -H "X-Delete-After:${THROTTLE_LOCK_EXPIRE_AFTER}"
    if [[ $? -ne 0 ]]; then
      log WARN "${DB_NAME}_backup" "Cannot set throttle container object ${THROTTLE_FILE} expiration header!"
      return 2
    fi
    openstack object show $THROTTLE_CONTAINER_NAME $THROTTLE_FILE
    if [[ $? -ne 0 ]]; then
      log WARN "${DB_NAME}_backup" "Unable to retrieve throttle container object $THROTTLE_FILE after creation."
      return 2
    fi
  fi

  #---------------------------------------------------------------------------

  # Create an object to store the file
  openstack object create --name $FILE $CONTAINER_NAME $FILEPATH/$FILE
  if [[ $? -ne 0 ]]; then
    log WARN "${DB_NAME}_backup" "Cannot create container object ${FILE}!"
    return 2
  fi

  openstack object show $CONTAINER_NAME $FILE
  if [[ $? -ne 0 ]]; then
    log WARN "${DB_NAME}_backup" "Unable to retrieve container object $FILE after creation."
    return 2
  fi

  # Remote backup verification
  MD5_REMOTE=$(openstack object show $CONTAINER_NAME $FILE -f json | jq -r ".etag")
  MD5_LOCAL=$(cat ${FILEPATH}/${FILE} | md5sum | awk '{print $1}')
  log INFO "${DB_NAME}_backup" "Obtained MD5 hash for the file $FILE in container $CONTAINER_NAME."
  log INFO "${DB_NAME}_backup" "Local MD5 hash is ${MD5_LOCAL}."
  log INFO "${DB_NAME}_backup" "Remote MD5 hash is ${MD5_REMOTE}."
  if [[ "${MD5_LOCAL}" == "${MD5_REMOTE}" ]]; then
      log INFO "${DB_NAME}_backup" "The local backup & remote backup MD5 hash values are matching for file $FILE in container $CONTAINER_NAME."
  else
      log ERROR "${DB_NAME}_backup" "Mismatch between the local backup & remote backup MD5 hash values"
      return 2
  fi
  rm -f ${REMOTE_FILE}

  #---------------------------------------------------------------------------
  # Remote backup throttling
  export THROTTLE_BACKUPS_ENABLED=$(echo $THROTTLE_BACKUPS_ENABLED | sed 's/"//g')
  if $THROTTLE_BACKUPS_ENABLED; then
    # Remove flag file
    # Delete an object to remove the flag file
    openstack object delete $THROTTLE_CONTAINER_NAME $THROTTLE_FILE
    if [[ $? -ne 0 ]]; then
      log WARN "${DB_NAME}_backup" "Cannot delete throttle container object ${THROTTLE_FILE}"
      return 0
    else
      log INFO "${DB_NAME}_backup" "The throttle container object ${THROTTLE_FILE} has been successfully removed."
    fi
    rm -f ${THROTTLE_FILEPATH}/${THROTTLE_FILE}
  fi

  #---------------------------------------------------------------------------

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

  count=1
  while [[ ${count} -le ${REMOTE_BACKUP_RETRIES} ]]; do
    # Store the new archive to the remote backup storage facility.
    send_to_remote_server $FILEPATH $FILE
    SEND_RESULT="$?"

    # Check if successful
    if [[ $SEND_RESULT -eq 0 ]]; then
      log INFO "${DB_NAME}_backup" "Backup file ${FILE} successfully sent to RGW."
      return 0
    elif [[ $SEND_RESULT -eq 2 ]]; then
      if [[ ${count} -ge ${REMOTE_BACKUP_RETRIES} ]]; then
        log ERROR "${DB_NAME}_backup" "Backup file ${FILE} could not be sent to the RGW in " \
        "${REMOTE_BACKUP_RETRIES} retries. Errors encountered. Exiting."
        break
      fi
      # Temporary failure occurred. We need to retry
      log WARN "${DB_NAME}_backup" "Backup file ${FILE} could not be sent to RGW due to connection issue."
      sleep_time=$(random_number)
      log INFO "${DB_NAME}_backup" "Sleeping ${sleep_time} seconds waiting for RGW to become available..."
      sleep ${sleep_time}
      log INFO "${DB_NAME}_backup" "Retrying..."
    else
      log ERROR "${DB_NAME}_backup" "Backup file ${FILE} could not be sent to the RGW. Errors encountered. Exiting."
      break
    fi

    # Increment the counter
    count=$((count+1))
  done

  return 1
}


function get_archive_date(){
# get_archive_date function returns correct archive date
# for different formats of archives' names
# the old one: <database name>.<namespace>.<table name | all>.<date-time>.tar.gz
# the new one: <database name>.<namespace>.<table name | all>.<backup mode>.<date-time>.tar.gz
  local A_FILE="$1"
  awk -F. '{print $(NF-2)}' <<< ${A_FILE} | tr -d "Z"
}

# This function takes a list of archives' names as an input
# and creates a hash table where keys are number of seconds
# between current date and archive date (see seconds_difference),
# and values are space separated archives' names
#
# +------------+---------------------------------------------------------------------------------------------------------+
# | 1265342678 | "tmp/mysql.backup.auto.2022-02-14T10:13:13Z.tar.gz"                                                     |
# +------------+---------------------------------------------------------------------------------------------------------+
# | 2346254257 | "tmp/mysql.backup.auto.2022-02-11T10:13:13Z.tar.gz tmp/mysql.backup.manual.2022-02-11T10:13:13Z.tar.gz" |
# +------------+---------------------------------------------------------------------------------------------------------+
# <...>
# +------------+---------------------------------------------------------------------------------------------------------+
# | 6253434567 | "tmp/mysql.backup.manual.2022-02-01T10:13:13Z.tar.gz"                                                   |
# +------------+---------------------------------------------------------------------------------------------------------+
# We will use the explained above data stracture to cover rare, but still
# possible case, when we have several backups of the same date. E.g.
# one manual, and one automatic.

declare -A fileTable
create_hash_table() {
unset fileTable
fileList=$@
  for ARCHIVE_FILE in ${fileList}; do
    # Creating index, we will round given ARCHIVE_DATE to the midnight (00:00:00)
    # to take in account a possibility, that we can have more than one scheduled
    # backup per day.
    ARCHIVE_DATE=$(get_archive_date ${ARCHIVE_FILE})
    ARCHIVE_DATE=$(date --date=${ARCHIVE_DATE} +%D)
    log INFO "${DB_NAME}_backup" "Archive date to build index: ${ARCHIVE_DATE}"
    INDEX=$(seconds_difference ${ARCHIVE_DATE})
    if [[ -z fileTable[${INDEX}] ]]; then
      fileTable[${INDEX}]=${ARCHIVE_FILE}
    else
      fileTable[${INDEX}]="${fileTable[${INDEX}]} ${ARCHIVE_FILE}"
    fi
    echo "INDEX: ${INDEX} VALUE:  ${fileTable[${INDEX}]}"
 done
}

function get_backup_prefix() {
# Create list of all possible prefixes in a format:
# <db_name>.<namespace> to cover a possible situation
# when different backups of different databases and/or
# namespaces share the same local or remote storage.
  ALL_FILES=($@)
  PREFIXES=()
  for fname in ${ALL_FILES[@]}; do
    prefix=$(basename ${fname} | cut -d'.' -f1,2 )
    for ((i=0; i<${#PREFIXES[@]}; i++)) do
      if [[ ${PREFIXES[${i}]} == ${prefix} ]]; then
        prefix=""
        break
      fi
    done
    if [[ ! -z ${prefix} ]]; then
        PREFIXES+=(${prefix})
    fi
  done
}

remove_old_local_archives() {
  SECONDS_TO_KEEP=$(( $((${LOCAL_DAYS_TO_KEEP}))*86400))
  log INFO "${DB_NAME}_backup" "Deleting backups older than ${LOCAL_DAYS_TO_KEEP} days (${SECONDS_TO_KEEP} seconds)"
  if [[ -d $ARCHIVE_DIR ]]; then
    count=0
    # We iterate over the hash table, checking the delta in seconds (hash keys),
    # and minimum number of backups we must have in place. List of keys has to be sorted.
    for INDEX in $(tr " " "\n" <<< ${!fileTable[@]} | sort -n -); do
      ARCHIVE_FILE=${fileTable[${INDEX}]}
      if [[ ${INDEX} -lt ${SECONDS_TO_KEEP} || ${count} -lt ${LOCAL_DAYS_TO_KEEP} ]]; then
        ((count++))
        log INFO "${DB_NAME}_backup" "Keeping file(s) ${ARCHIVE_FILE}."
      else
        log INFO "${DB_NAME}_backup" "Deleting file(s) ${ARCHIVE_FILE}."
          rm -f ${ARCHIVE_FILE}
          if [[ $? -ne 0 ]]; then
            # Log error but don't exit so we can finish the script
            # because at this point we haven't sent backup to RGW yet
            log ERROR "${DB_NAME}_backup" "Failed to cleanup local backup. Cannot remove some of ${ARCHIVE_FILE}"
          fi
      fi
    done
  else
    log WARN "${DB_NAME}_backup" "The local backup directory ${$ARCHIVE_DIR} does not exist."
  fi
}

prepare_list_of_remote_backups() {
  BACKUP_FILES=$(mktemp -p /tmp)
  DB_BACKUP_FILES=$(mktemp -p /tmp)
  openstack object list $CONTAINER_NAME > $BACKUP_FILES
  if [[ $? -ne 0 ]]; then
    log_backup_error_exit \
      "Failed to cleanup remote backup. Could not obtain a list of current backup files in the RGW"
  fi
  # Filter out other types of backup files
  cat $BACKUP_FILES | grep $DB_NAME | grep $DB_NAMESPACE | awk '{print $2}' > $DB_BACKUP_FILES
}

# The logic implemented with this function is absolutely similar
# to the function remove_old_local_archives (see above)
remove_old_remote_archives() {
  count=0
  SECONDS_TO_KEEP=$((${REMOTE_DAYS_TO_KEEP}*86400))
  log INFO "${DB_NAME}_backup" "Deleting backups older than ${REMOTE_DAYS_TO_KEEP} days (${SECONDS_TO_KEEP} seconds)"
  for INDEX in $(tr " " "\n" <<< ${!fileTable[@]} | sort -n -); do
    ARCHIVE_FILE=${fileTable[${INDEX}]}
    if [[ ${INDEX} -lt ${SECONDS_TO_KEEP} || ${count} -lt ${REMOTE_DAYS_TO_KEEP} ]]; then
      ((count++))
      log INFO "${DB_NAME}_backup" "Keeping remote backup(s) ${ARCHIVE_FILE}."
    else
      log INFO "${DB_NAME}_backup" "Deleting remote backup(s) ${ARCHIVE_FILE} from the RGW"
      openstack object delete ${CONTAINER_NAME} ${ARCHIVE_FILE} ||  log WARN "${DB_NAME}_backup" \
        "Failed to cleanup remote backup. Cannot delete container object ${ARCHIVE_FILE}"
    fi
  done

  # Cleanup now that we're done.
  for fd in ${BACKUP_FILES} ${DB_BACKUP_FILES}; do
    if [[ -f ${fd} ]]; then
      rm -f ${fd}
    else
      log WARN "${DB_NAME}_backup" "Can not delete a temporary file ${fd}"
    fi
  done
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
  mkdir -p $ARCHIVE_DIR || log_backup_error_exit \
    "Backup of the ${DB_NAME} database failed. Cannot create directory ${ARCHIVE_DIR}!"
  export TMP_DIR=$(mktemp -d) || log_backup_error_exit \
    "Backup of the ${DB_NAME} database failed. Cannot create temp directory!"

  # Create temporary log file
  export ERR_LOG_FILE=$(mktemp -p /tmp) || log_backup_error_exit \
    "Backup of the ${DB_NAME} database failed. Cannot create log file!"

  # It is expected that this function will dump the database files to the $TMP_DIR
  dump_databases_to_directory $TMP_DIR $ERR_LOG_FILE $SCOPE

  # If successful, there should be at least one file in the TMP_DIR
  if [[ $? -ne 0 || $(ls $TMP_DIR | wc -w) -eq 0 ]]; then
    cat $ERR_LOG_FILE
    log_backup_error_exit "Backup of the ${DB_NAME} database failed and needs attention."
  fi

  log INFO "${DB_NAME}_backup" "Databases dumped successfully. Creating tarball..."

  NOW=$(date +"%Y-%m-%dT%H:%M:%SZ")
  if [[ -z "${BACK_UP_MODE}" ]]; then
    TARBALL_FILE="${DB_NAME}.${DB_NAMESPACE}.${SCOPE}.${NOW}.tar.gz"
  else
    TARBALL_FILE="${DB_NAME}.${DB_NAMESPACE}.${SCOPE}.${BACK_UP_MODE}.${NOW}.tar.gz"
  fi

  cd $TMP_DIR || log_backup_error_exit \
    "Backup of the ${DB_NAME} database failed. Cannot change to directory $TMP_DIR"

  #Archive the current database files
  tar zcvf $ARCHIVE_DIR/$TARBALL_FILE *
  if [[ $? -ne 0 ]]; then
    log_backup_error_exit \
      "Backup ${DB_NAME} to local file system failed. Backup tarball could not be created."
  fi

  # Get the size of the file
  ARCHIVE_SIZE=$(ls -l $ARCHIVE_DIR/$TARBALL_FILE | awk '{print $5}')

  log INFO "${DB_NAME}_backup" "Tarball $TARBALL_FILE created successfully."

  cd $ARCHIVE_DIR

  #Only delete the old archive after a successful archive
  export LOCAL_DAYS_TO_KEEP=$(echo $LOCAL_DAYS_TO_KEEP | sed 's/"//g')
  if [[ "$LOCAL_DAYS_TO_KEEP" -gt 0 ]]; then
    get_backup_prefix $(ls -1 ${ARCHIVE_DIR}/*.gz)
    for ((i=0; i<${#PREFIXES[@]}; i++)); do
      echo "Working with prefix: ${PREFIXES[i]}"
      create_hash_table $(ls -1 ${ARCHIVE_DIR}/${PREFIXES[i]}*.gz)
      remove_old_local_archives
    done
  fi

  # Local backup verification process

  # It is expected that this function will verify the database backup files
  if verify_databases_backup_archives ${SCOPE}; then
    log INFO "${DB_NAME}_backup_verify" "Databases backup verified successfully. Uploading verified backups to remote location..."
  else
    # If successful, there should be at least one file in the TMP_DIR
    if [[ $(ls $TMP_DIR | wc -w) -eq 0 ]]; then
      cat $ERR_LOG_FILE
    fi
    log_verify_backup_exit "Verify of the ${DB_NAME} database backup failed and needs attention."
    exit 1
  fi

  # Remove the temporary directory and files as they are no longer needed.
  rm -rf $TMP_DIR
  rm -f $ERR_LOG_FILE

  # Remote backup
  REMOTE_BACKUP=$(echo $REMOTE_BACKUP_ENABLED | sed 's/"//g')
  if $REMOTE_BACKUP; then
    # Remove Quotes from the constants which were added due to reading
    # from secret.
    export REMOTE_BACKUP_RETRIES=$(echo $REMOTE_BACKUP_RETRIES | sed 's/"//g')
    export MIN_DELAY_SEND_REMOTE=$(echo $MIN_DELAY_SEND_REMOTE | sed 's/"//g')
    export MAX_DELAY_SEND_REMOTE=$(echo $MAX_DELAY_SEND_REMOTE | sed 's/"//g')
    export REMOTE_DAYS_TO_KEEP=$(echo $REMOTE_DAYS_TO_KEEP | sed 's/"//g')

    store_backup_remotely $ARCHIVE_DIR $TARBALL_FILE
    if [[ $? -ne 0 ]]; then
      # This error should print first, then print the summary as the last
      # thing that the user sees in the output.
      log ERROR "${DB_NAME}_backup" "Backup ${TARBALL_FILE} could not be sent to remote RGW."
      echo "=================================================================="
      echo "Local backup successful, but could not send to remote RGW."
      echo "Backup archive name: $TARBALL_FILE"
      echo "Backup archive size: $ARCHIVE_SIZE"
      echo "=================================================================="
      # Because the local backup was successful, exit with 0 so the pod will not
      # continue to restart and fill the disk with more backups. The ERRORs are
      # logged and alerting system should catch those errors and flag the operator.
      exit 0
    fi

    #Only delete the old archive after a successful archive
    if [[ "$REMOTE_DAYS_TO_KEEP" -gt 0 ]]; then
      prepare_list_of_remote_backups
      get_backup_prefix $(cat $DB_BACKUP_FILES)
      for ((i=0; i<${#PREFIXES[@]}; i++)); do
        echo "Working with prefix: ${PREFIXES[i]}"
        create_hash_table $(cat ${DB_BACKUP_FILES} | grep ${PREFIXES[i]})
        remove_old_remote_archives
      done
    fi

    echo "=================================================================="
    echo "Local backup and backup to remote RGW successful!"
    echo "Backup archive name: $TARBALL_FILE"
    echo "Backup archive size: $ARCHIVE_SIZE"
    echo "=================================================================="
  else
    # Remote backup is not enabled. This is ok; at least we have a local backup.
    log INFO "${DB_NAME}_backup" "Skipping remote backup, as it is not enabled."

    echo "=================================================================="
    echo "Local backup successful!"
    echo "Backup archive name: $TARBALL_FILE"
    echo "Backup archive size: $ARCHIVE_SIZE"
    echo "=================================================================="
  fi
}
{{- end }}