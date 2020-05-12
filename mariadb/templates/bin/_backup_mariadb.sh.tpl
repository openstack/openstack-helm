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
set -x
BACKUPS_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/current
ARCHIVE_DIR=${MARIADB_BACKUP_BASE_DIR}/db/${MARIADB_POD_NAMESPACE}/mariadb/archive

MYSQL="mysql \
   --defaults-file=/etc/mysql/admin_user.cnf \
   --connect-timeout 10"

MYSQLDUMP="mysqldump \
   --defaults-file=/etc/mysql/admin_user.cnf"

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

DBNAME=( $($MYSQL --silent --skip-column-names -e \
   "show databases;" | \
   egrep -vi 'information_schema|performance_schema|mysql') )

#check if there is a database to backup, otherwise exit
if [[ -z "${DBNAME// }" ]]
then
  echo "There is no database to backup"
  exit 0
fi

#Create archive and backup directories.
mkdir -p $BACKUPS_DIR $ARCHIVE_DIR

#Create a list of Databases
printf "%s\n" "${DBNAME[@]}" > $BACKUPS_DIR/db.list

#Retrieve and create the GRANT files per DB
for db in "${DBNAME[@]}"
do
  echo $($MYSQL --skip-column-names -e "select concat('show grants for ',user,';') \
        from mysql.db where ucase(db)=ucase('$db');") | \
        sed -r "s/show grants for ([a-zA-Z0-9_-]*)/show grants for '\1'/" | \
        $MYSQL --silent --skip-column-names 2>grant_err.log > $BACKUPS_DIR/${db}_grant.sql
  if [ "$?" -eq 0 ]
  then
    sed -i 's/$/;/' $BACKUPS_DIR/${db}_grant.sql
  else
    cat grant_err.log
  fi
done

#Dumping the database
#DATE=$(date +"%Y_%m_%d_%H_%M_%S")
DATE=$(date +'%Y-%m-%dT%H:%M:%SZ')
$MYSQLDUMP $MYSQL_BACKUP_MYSQLDUMP_OPTIONS "${DBNAME[@]}"  \
          > $BACKUPS_DIR/mariadb.all.sql 2>dberror.log
if [[ $? -eq 0 && -s $BACKUPS_DIR/mariadb.all.sql ]]
then
  #Archive the current db files
  pushd $BACKUPS_DIR 1>/dev/null
  tar zcvf $ARCHIVE_DIR/mariadb.all.${DATE}.tar.gz *
  ARCHIVE_RET=$?
  popd 1>/dev/null
else
  #TODO: This can be convert into mail alert of alert send to a monitoring system
  echo "Backup failed and need attention."
  cat dberror.log
  exit 1
fi

#Remove the current backup
if [ -d $BACKUPS_DIR ]
then
  rm -rf $BACKUPS_DIR/*.sql
fi

#Only delete the old archive after a successful archive
if [ $ARCHIVE_RET -eq 0 ]
  then
    if [ "$MARIADB_BACKUP_DAYS_TO_KEEP" -gt 0 ]
    then
      echo "Deleting backups older than $MARIADB_BACKUP_DAYS_TO_KEEP days"
      if [ -d $ARCHIVE_DIR ]
      then
        for archive_file in $(ls -1 $ARCHIVE_DIR/*.gz)
        do
          archive_date=$( echo $archive_file | awk -F/ '{print $NF}' | cut -d'.' -f 3)
          if [ "$(seconds_difference $archive_date)" -gt "$(($MARIADB_BACKUP_DAYS_TO_KEEP*86400))" ]
          then
            rm -rf $archive_file
          fi
        done
      fi
    fi
fi
