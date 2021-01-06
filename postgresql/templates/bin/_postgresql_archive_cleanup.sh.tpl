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

set +ex

# ARCHIVE_LIMIT env variable is Threshold of archiving supposed to be kept in percentage
clean_up () {
  echo "Cleanup required as Utilization is above threshold"
  # Get file count and delete half of the archive while maintaining the order of the files
  FILE_COUNT=$(ls -1 ${ARCHIVE_PATH} | sort | wc -l)
  COUNT=0
  echo $((FILE_COUNT/2))
  for file in $(ls -1 ${ARCHIVE_PATH} | sort); do
    if [[ $COUNT -lt $((FILE_COUNT/2)) ]]; then
      echo "removing following file $file"
      rm -rf ${ARCHIVE_PATH}/$file
    else
      break
    fi
    COUNT=$((COUNT+1))
  done
}
#infinite loop to check the utilization of archive
while true
do
  # checking the utilization of archive directory
  UTILIZATION=$(df -h ${ARCHIVE_PATH} | awk ' NR==2 {print $5} ' | awk '{ print substr( $0, 1, length($0)-1 ) }')
  if [[ $UTILIZATION -gt ${ARCHIVE_LIMIT} ]];
  then
    clean_up
  fi
  sleep 3600
done


