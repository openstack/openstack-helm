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

# Do not use set -x here because the manual backup or restore pods may be using
# these functions, and it will distort the command output to have tracing on.

log_backup_error_exit() {
  MSG=$1
  ERRCODE=$2
  log ERROR postgresql_backup "${MSG}"
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
  if [ -z "$DEST" ]
  then
    echo "${DATE} ${LEVEL}: $(hostname) ${SERVICE}: ${MSG}"
  else
    echo "${DATE} ${LEVEL}: $(hostname) ${SERVICE}: ${MSG}" >>$DEST
  fi
}

#Get the day delta since the archive file backup
seconds_difference() {
  archive_date=$( date --date="$1" +%s )
  if [ "$?" -ne 0 ]
  then
    second_delta=0
  fi
  current_date=$( date +%s )
  second_delta=$(($current_date-$archive_date))
  if [ "$second_delta" -lt 0 ]
  then
    second_delta=0
  fi
  echo $second_delta
}

# Wait for a file to be available on the file system (written by the other
# container).
wait_for_file() {
  WAIT_FILE=$1
  NO_TIMEOUT=${2:-false}
  TIMEOUT=300
  if [[ $NO_TIMEOUT == "true" ]]
  then
    # Such a large value to virtually never timeout
    TIMEOUT=999999999
  fi
  TIMEOUT_EXP=$(( $(date +%s) + $TIMEOUT ))
  DONE=false
  while [[ $DONE == "false" ]]
  do
    DELTA=$(( TIMEOUT_EXP - $(date +%s) ))
    if [[ "$(ls -l ${WAIT_FILE} 2>/dev/null | wc -l)" -gt 0 ]];
    then
      DONE=true
    elif [[ $DELTA -lt 0 ]]
    then
      DONE=true
      echo "Timed out waiting for file ${WAIT_FILE}."
      return 1
    else
      echo "Still waiting ...will time out in ${DELTA} seconds..."
      sleep 5
    fi
  done
  return 0
}

