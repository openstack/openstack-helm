#!/bin/bash

SCOPE=${1:-"all"}

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

source /tmp/backup_main.sh

# Export the variables required by the framework
# Note: REMOTE_BACKUP_ENABLED, STORAGE_POLICY  and CONTAINER_NAME are already
#       exported.
export DB_NAMESPACE=${MARIADB_POD_NAMESPACE}
export DB_NAME="mariadb"
export LOCAL_DAYS_TO_KEEP=${MARIADB_LOCAL_BACKUP_DAYS_TO_KEEP}
export REMOTE_DAYS_TO_KEEP=${MARIADB_REMOTE_BACKUP_DAYS_TO_KEEP}
export REMOTE_BACKUP_RETRIES=${NUMBER_OF_RETRIES_SEND_BACKUP_TO_REMOTE}
export MIN_DELAY_SEND_REMOTE=${MIN_DELAY_SEND_BACKUP_TO_REMOTE}
export MAX_DELAY_SEND_REMOTE=${MAX_DELAY_SEND_BACKUP_TO_REMOTE}
export ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${DB_NAMESPACE}/${DB_NAME}/archive

# Dump all the database files to existing $TMP_DIR and save logs to $LOG_FILE
dump_databases_to_directory() {
  TMP_DIR=$1
  LOG_FILE=$2
  SCOPE=${3:-"all"}


  MYSQL="mysql \
     --defaults-file=/etc/mysql/admin_user.cnf \
     --connect-timeout 10"

  MYSQLDUMP="mysqldump \
     --defaults-file=/etc/mysql/admin_user.cnf"

  if [[ "${SCOPE}" == "all" ]]; then
    MYSQL_DBNAMES=( $($MYSQL --silent --skip-column-names -e \
       "show databases;" | \
       grep -ivE 'information_schema|performance_schema|mysql|sys') )
  else
    if [[ "${SCOPE}" != "information_schema" && "${SCOPE}" != "performance_schema" && "${SCOPE}" != "mysql" && "${SCOPE}" != "sys" ]]; then
      MYSQL_DBNAMES=( ${SCOPE} )
    else
      log ERROR "It is not allowed to backup database ${SCOPE}."
      return 1
    fi
  fi

  #check if there is a database to backup, otherwise exit
  if [[ -z "${MYSQL_DBNAMES// }" ]]
  then
    log INFO "There is no database to backup"
    return 0
  fi

  #Create a list of Databases
  printf "%s\n" "${MYSQL_DBNAMES[@]}" > $TMP_DIR/db.list

  if [[ "${SCOPE}" == "all" ]]; then
    #Retrieve and create the GRANT file for all the users
{{- if .Values.manifests.certificates }}
    SSL_DSN=";mysql_ssl=1"
    SSL_DSN="$SSL_DSN;mysql_ssl_client_key=/etc/mysql/certs/tls.key"
    SSL_DSN="$SSL_DSN;mysql_ssl_client_cert=/etc/mysql/certs/tls.crt"
    SSL_DSN="$SSL_DSN;mysql_ssl_ca_file=/etc/mysql/certs/ca.crt"
    if ! pt-show-grants --defaults-file=/etc/mysql/admin_user.cnf $SSL_DSN \
{{- else }}
    if ! pt-show-grants --defaults-file=/etc/mysql/admin_user.cnf \
{{- end }}
         2>>"$LOG_FILE" > "$TMP_DIR"/grants.sql; then
      log ERROR "Failed to create GRANT for all the users"
      return 1
    fi
  fi

  #Retrieve and create the GRANT files per DB
  for db in "${MYSQL_DBNAMES[@]}"
  do
    echo $($MYSQL --skip-column-names -e "select concat('show grants for ',user,';') \
          from mysql.db where ucase(db)=ucase('$db');") | \
          sed -r "s/show grants for ([a-zA-Z0-9_-]*)/show grants for '\1'/g" | \
          $MYSQL --silent --skip-column-names 2>>$LOG_FILE > $TMP_DIR/${db}_grant.sql
    if [ "$?" -eq 0 ]
    then
      sed -i 's/$/;/' $TMP_DIR/${db}_grant.sql
    else
      log ERROR "Failed to create GRANT files for ${db}"
      return 1
    fi
  done

  #Dumping the database

  SQL_FILE=mariadb.$MARIADB_POD_NAMESPACE.${SCOPE}

  $MYSQLDUMP $MYSQL_BACKUP_MYSQLDUMP_OPTIONS "${MYSQL_DBNAMES[@]}"  \
            > $TMP_DIR/${SQL_FILE}.sql 2>>$LOG_FILE
  if [[ $? -eq 0 && -s $TMP_DIR/${SQL_FILE}.sql ]]
  then
    log INFO "Database(s) dumped successfully. (SCOPE = ${SCOPE})"
    return 0
  else
    log ERROR "Backup failed and need attention. (SCOPE = ${SCOPE})"
    return 1
  fi
}

# functions from  mariadb-verifier chart

get_time_delta_secs () {
  second_delta=0
  input_date_second=$( date --date="$1" +%s )
  if [ -n "$input_date_second" ]; then
    current_date=$( date +"%Y-%m-%dT%H:%M:%SZ" )
    current_date_second=$( date --date="$current_date" +%s )
    ((second_delta=current_date_second-input_date_second))
    if [ "$second_delta" -lt 0 ]; then
      second_delta=0
    fi
  fi
  echo $second_delta
}


check_data_freshness () {
  archive_file=$(basename "$1")
  archive_date=$(echo "$archive_file" | cut -d'.' -f 4)
  SCOPE=$2

  if [[ "${SCOPE}" != "all" ]]; then
    log "Data freshness check is skipped for individual database."
    return 0
  fi

  log "Checking for data freshness in the backups..."
  # Get some idea of which database.table has changed in the last 30m
  # Excluding the system DBs and aqua_test_database
  #
  changed_tables=$(${MYSQL_LIVE} -e "select TABLE_SCHEMA,TABLE_NAME from \
information_schema.tables where UPDATE_TIME >= SUBTIME(now(),'00:30:00') AND TABLE_SCHEMA \
NOT IN('information_schema', 'mysql', 'performance_schema', 'sys', 'aqua_test_database');" | \
awk '{print $1 "." $2}')

  if [ -n "${changed_tables}" ]; then
    delta_secs=$(get_time_delta_secs "$archive_date")
    age_offset={{ .Values.conf.backup.validateData.ageOffset }}
    ((age_threshold=delta_secs+age_offset))

    data_freshness=false
    skipped_freshness=false

    for table in ${changed_tables}; do
      tab_schema=$(echo "$table" | awk -F. '{print $1}')
      tab_name=$(echo "$table" | awk -F. '{print $2}')

      local_table_existed=$(${MYSQL_LOCAL_SHORT_SILENT} -e "select TABLE_SCHEMA,TABLE_NAME from \
INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=\"${tab_schema}\" AND TABLE_NAME=\"${tab_name}\";")

      if [ -n "$local_table_existed" ]; then
        # TODO: If last updated field of a table structure has different
        # patterns (updated/timstamp), it may be worth to parameterize the patterns.
        datetime=$(${MYSQL_LOCAL_SHORT_SILENT} -e "describe ${table};" | \
                   awk '(/updated/ || /timestamp/) && /datetime/ {print $1}')

        if [ -n "${datetime}" ]; then
          data_ages=$(${MYSQL_LOCAL_SHORT_SILENT} -e "select \
time_to_sec(timediff(now(),${datetime})) from ${table} where ${datetime} is not null order by 1 limit 10;")

          for age in $data_ages; do
            if [ "$age" -le $age_threshold ]; then
              data_freshness=true
              break
            fi
          done

          # As long as there is an indication of data freshness, no need to check further
          if [ "$data_freshness" = true ] ; then
            break
          fi
        else
          skipped_freshness=true
          log "No indicator to determine data freshness for table $table. Skipped data freshness check."

          # Dumping out table structure to determine if enhancement is needed to include this table
          debug_info=$(${MYSQL_LOCAL} --skip-column-names -e "describe ${table};" | awk '{print $2 " " $1}')
          log "$debug_info" "DEBUG"
        fi
      else
        log "Table $table doesn't exist in local database"
        skipped_freshness=true
      fi
    done

    if [ "$data_freshness" = true ] ; then
      log "Database passed integrity (data freshness) check."
    else
      if [ "$skipped_freshness" = false ] ; then
        log "Local backup database restore failed integrity check." "ERROR"
        log "The backup may not have captured the up-to-date data." "INFO"
        return 1
      fi
    fi
  else
    log "No tables changed in this backup. Skipped data freshness check as the"
    log "check should have been performed by previous validation runs."
  fi

  return 0
}


cleanup_local_databases () {
  old_local_dbs=$(${MYSQL_LOCAL_SHORT_SILENT} -e 'show databases;' | \
    grep -ivE 'information_schema|performance_schema|mysql|sys' || true)

  for db in $old_local_dbs; do
    ${MYSQL_LOCAL_SHORT_SILENT} -e "drop database $db;"
  done
}

list_archive_dir () {
  archive_dir_content=$(ls -1R "$ARCHIVE_DIR")
  if [ -n "$archive_dir_content" ]; then
    log "Content of $ARCHIVE_DIR"
    log "${archive_dir_content}"
  fi
}

remove_remote_archive_file () {
  archive_file=$(basename "$1")
  token_req_file=$(mktemp --suffix ".json")
  header_file=$(mktemp)
  resp_file=$(mktemp --suffix ".json")
  http_resp="404"

  HEADER_CONTENT_TYPE="Content-Type: application/json"
  HEADER_ACCEPT="Accept: application/json"

  cat << JSON_EOF > "$token_req_file"
{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "domain": {
                        "name": "${OS_USER_DOMAIN_NAME}"
                    },
                    "name": "${OS_USERNAME}",
                    "password": "${OS_PASSWORD}"
                }
            }
        },
        "scope": {
            "project": {
                "domain": {
                    "name": "${OS_PROJECT_DOMAIN_NAME}"
                },
                "name": "${OS_PROJECT_NAME}"
            }
        }
    }
}
JSON_EOF

  http_resp=$(curl -s -X POST "$OS_AUTH_URL/auth/tokens"  -H "${HEADER_CONTENT_TYPE}" \
       -H "${HEADER_ACCEPT}" -d @"${token_req_file}" -D "$header_file" -o "$resp_file" -w "%{http_code}")

  if [ "$http_resp" = "201" ]; then
    OS_TOKEN=$(grep -i "x-subject-token" "$header_file" | cut -d' ' -f2 | tr -d "\r")

    if [ -n "$OS_TOKEN" ]; then
      OS_OBJ_URL=$(python3 -c "import json,sys;print([[ep['url'] for ep in obj['endpoints'] if ep['interface']=='public'] for obj in json.load(sys.stdin)['token']['catalog'] if obj['type']=='object-store'][0][0])" < "$resp_file")

      if [ -n "$OS_OBJ_URL" ]; then
        http_resp=$(curl -s -X DELETE "$OS_OBJ_URL/$CONTAINER_NAME/$archive_file" \
                         -H "${HEADER_CONTENT_TYPE}" -H "${HEADER_ACCEPT}" \
                         -H "X-Auth-Token: ${OS_TOKEN}" -D "$header_file" -o "$resp_file" -w "%{http_code}")
      fi
    fi
  fi

  if [ "$http_resp" == "404" ] ; then
    log "Failed to cleanup remote backup. Container object $archive_file is not on RGW."
    return 1
  fi

  if [ "$http_resp" != "204" ] ; then
    log "Failed to cleanup remote backup. Cannot delete container object $archive_file" "ERROR"
    cat "$header_file"
    cat "$resp_file"
  fi
  return 0
}

handle_bad_archive_file () {
  archive_file=$1

  if [ ! -d "$BAD_ARCHIVE_DIR" ]; then
    mkdir -p "$BAD_ARCHIVE_DIR"
  fi

  # Move the file to quarantine directory such that
  # file won't be used for restore in case of recovery
  #
  log "Moving $i to $BAD_ARCHIVE_DIR..."
  mv "$i" "$BAD_ARCHIVE_DIR"
  log "Removing $i from remote RGW..."
  if remove_remote_archive_file "$i"; then
    log "File $i has been successfully removed from RGW."
  else
    log "FIle $i cannot be removed form RGW." "ERROR"
    return 1
  fi

  # Atmost only three bad files are kept. Deleting the oldest if
  # number of files exceeded the threshold.
  #
  bad_files=$(find "$BAD_ARCHIVE_DIR" -name "*.tar.gz" 2>/dev/null | wc -l)
  if [ "$bad_files" -gt 3 ]; then
    ((bad_files=bad_files-3))
    delete_files=$(find "$BAD_ARCHIVE_DIR" -name "*.tar.gz" 2>/dev/null | sort | head --lines=$bad_files)
    for b in $delete_files; do
      log "Deleting $b..."
      rm -f "${b}"
    done
  fi
  return 0
}

cleanup_old_validation_result_file () {
  clean_files=$(find "$ARCHIVE_DIR" -maxdepth 1 -name "*.passed" 2>/dev/null)
  for d in $clean_files; do
    archive_file=${d/.passed}
    if [ ! -f "$archive_file" ]; then
      log "Deleting $d as its associated archive file $archive_file nolonger existed."
      rm -f "${d}"
    fi
  done
}

validate_databases_backup () {
  archive_file=$1
  SCOPE=${2:-"all"}

  restore_log='/tmp/restore_error.log'
  tmp_dir=$(mktemp -d)

  rm -f $restore_log
  cd "$tmp_dir"
  log "Decompressing archive $archive_file..."
  if ! tar zxvf - < "$archive_file" 1>/dev/null; then
    log "Database restore from local backup failed. Archive decompression failed." "ERROR"
    return 1
  fi

  db_list_file="$tmp_dir/db.list"
  if [[ -e "$db_list_file" ]]; then
    dbs=$(sort < "$db_list_file" | grep -ivE sys | tr '\n' ' ')
  else
    dbs=" "
  fi

  sql_file="${tmp_dir}/mariadb.${MARIADB_POD_NAMESPACE}.${SCOPE}.sql"

  if [[ "${SCOPE}" == "all" ]]; then
    grant_file="${tmp_dir}/grants.sql"
  else
    grant_file="${tmp_dir}/${SCOPE}_grant.sql"
  fi

  if [[ -f $sql_file ]]; then
    if $MYSQL_LOCAL < "$sql_file" 2>$restore_log; then
      local_dbs=$(${MYSQL_LOCAL_SHORT_SILENT} -e 'show databases;' | \
        grep -ivE 'information_schema|performance_schema|mysql|sys' | sort | tr '\n' ' ')

      if [ "$dbs" = "$local_dbs" ]; then
        log "Databases restored successful."
      else
        log "Database restore from local backup failed. Database mismatched between local backup and local server" "ERROR"
        log "Databases restored on local server: $local_dbs" "DEBUG"
        log "Databases in the local backup: $dbs" "DEBUG"
        return 1
      fi
    else
      log "Database restore from local backup failed. $dbs" "ERROR"
      cat $restore_log
      return 1
    fi

    if [[ -f $grant_file ]]; then
      if $MYSQL_LOCAL < "$grant_file" 2>$restore_log; then
        if ! $MYSQL_LOCAL -e 'flush privileges;'; then
          log "Database restore from local backup failed. Failed to flush privileges." "ERROR"
          return 1
        fi
        log "Databases permission restored successful."
      else
        log "Database restore from local backup failed. Databases permission failed to restore." "ERROR"
        cat "$restore_log"
        cat "$grant_file"
        log "Local DBs: $local_dbs" "DEBUG"
        return 1
      fi
    else
      log "Database restore from local backup failed. There is no permission file available" "ERROR"
      return 1
    fi

    if ! check_data_freshness "$archive_file" ${SCOPE}; then
      # Log has already generated during check data freshness
      return 1
    fi
  else
    log "Database restore from local backup failed. There is no database file available to restore from" "ERROR"
    return 1
  fi

  return 0
}

# end of functions form mariadb verifier chart

# Verify all the databases backup archives
verify_databases_backup_archives() {
  SCOPE=${1:-"all"}

  # verification code
  export DB_NAME="mariadb"
  export ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/${DB_NAME}/archive
  export BAD_ARCHIVE_DIR=${ARCHIVE_DIR}/quarantine
  export MYSQL_OPTS="--silent --skip-column-names"
  export MYSQL_LIVE="mysql ${MYSQL_OPTS}"
  export MYSQL_LOCAL_OPTS=""
  export MYSQL_LOCAL_SHORT="mysql ${MYSQL_LOCAL_OPTS} --connect-timeout 2"
  export MYSQL_LOCAL_SHORT_SILENT="${MYSQL_LOCAL_SHORT} ${MYSQL_OPTS}"
  export MYSQL_LOCAL="mysql ${MYSQL_LOCAL_OPTS} --connect-timeout 10"

  max_wait={{ .Values.conf.mariadb_server.setup_wait.iteration }}
  duration={{ .Values.conf.mariadb_server.setup_wait.duration }}
  counter=0
  dbisup=false

  log "Waiting for Mariadb backup verification server to start..."

  # During Mariadb init/startup process, a temporary server is startup
  # and shutdown prior to starting up the normal server.
  # To avoid prematurely determine server availability, lets snooze
  # a bit to give time for the process to complete prior to issue
  # mysql commands.
  #


  while [ $counter -lt $max_wait ]; do
    if ! $MYSQL_LOCAL_SHORT -e 'select 1' > /dev/null 2>&1 ; then
      sleep $duration
      ((counter=counter+1))
    else
      # Lets sleep for an additional duration just in case async
      # init takes a bit more time to complete.
      #
      sleep $duration
      dbisup=true
      counter=$max_wait
    fi
  done

  if ! $dbisup; then
    log "Mariadb backup verification server is not running" "ERROR"
    return 1
  fi

  # During Mariadb init process, a test database will be briefly
  # created and deleted. Adding to the exclusion list for some
  # edge cases
  #
  clean_db=$(${MYSQL_LOCAL_SHORT_SILENT} -e 'show databases;' | \
    grep -ivE 'information_schema|performance_schema|mysql|test|sys' || true)

  if [[ -z "${clean_db// }" ]]; then
    log "Clean Server is up and running"
  else
    cleanup_local_databases
    log "Old databases found on the Mariadb backup verification server were cleaned."
    clean_db=$(${MYSQL_LOCAL_SHORT_SILENT} -e 'show databases;' | \
      grep -ivE 'information_schema|performance_schema|mysql|test|sys' || true)

    if [[ -z "${clean_db// }" ]]; then
      log "Clean Server is up and running"
    else
      log "Cannot clean old databases on verification server." "ERROR"
      return 1
    fi
    log "The server is ready for verification."
  fi

  # Starting with 10.4.13, new definer mariadb.sys was added. However, mariadb.sys was deleted
  # during init mariadb as it was not on the exclusion list. This corrupted the view of mysql.user.
  # Insert the tuple back to avoid other similar issues with error i.e
  #   The user specified as a definer ('mariadb.sys'@'localhost') does not exist
  #
  # Before insert the tuple mentioned above, we should make sure that the MariaDB version is 10.4.+
  mariadb_version=$($MYSQL_LOCAL_SHORT -e "status" | grep -E '^Server\s+version:')
  log "Current database ${mariadb_version}"
  if [[ ! -z ${mariadb_version} && -z $(grep '10.2' <<< ${mariadb_version}}) ]]; then
    if [[ -z $(grep 'mariadb.sys' <<< $($MYSQL_LOCAL_SHORT mysql  -e "select * from global_priv where user='mariadb.sys'")) ]]; then
      $MYSQL_LOCAL_SHORT -e "insert into mysql.global_priv values ('localhost','mariadb.sys',\
    '{\"access\":0,\"plugin\":\"mysql_native_password\",\"authentication_string\":\"\",\"account_locked\":true,\"password_last_changed\":0}');"
      $MYSQL_LOCAL_SHORT -e 'flush privileges;'
    fi
  fi

  # Ensure archive dir existed
  if [ -d "$ARCHIVE_DIR" ]; then
    # List archive dir before
    list_archive_dir

      # Ensure the local databases are clean for each restore validation
      #
      cleanup_local_databases

      if [[ "${SCOPE}" == "all" ]]; then
        archive_files=$(find "$ARCHIVE_DIR" -maxdepth 1 -name "*.tar.gz" 2>/dev/null | sort)
        for i in $archive_files; do
          archive_file_passed=$i.passed
          if [ ! -f "$archive_file_passed" ]; then
            log "Validating archive file $i..."
            if validate_databases_backup "$i"; then
              touch "$archive_file_passed"
            else
              if handle_bad_archive_file "$i"; then
                log "File $i has been removed from RGW."
              else
                log "File $i cannot be removed from RGW." "ERROR"
                return 1
              fi
            fi
          fi
        done
      else
        archive_files=$(find "$ARCHIVE_DIR" -maxdepth 1 -name "*.tar.gz" 2>/dev/null | grep "${SCOPE}" | sort)
        for i in $archive_files; do
          archive_file_passed=$i.passed
          if [ ! -f "$archive_file_passed" ]; then
            log "Validating archive file $i..."
            if validate_databases_backup "${i}" "${SCOPE}"; then
              touch "$archive_file_passed"
            else
              if handle_bad_archive_file "$i"; then
                log "File $i has been removed from RGW."
              else
                log "File $i cannot be removed from RGW." "ERROR"
                return 1
              fi
            fi
          fi
        done
      fi


    # Cleanup passed files if its archive file nolonger existed
    cleanup_old_validation_result_file

    # List archive dir after
    list_archive_dir
  fi


  return 0
}

# Call main program to start the database backup
backup_databases ${SCOPE}
