# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# dbc_install: configure database with dbconfig-common?
#              set to anything but "true" to opt out of assistance
dbc_install='true'

# dbc_upgrade: upgrade database with dbconfig-common?
#              set to anything but "true" to opt out of assistance
dbc_upgrade='true'

# dbc_remove: deconfigure database with dbconfig-common?
#             set to anything but "true" to opt out of assistance
dbc_remove='true'

# dbc_dbtype: type of underlying database to use
#	this exists primarily to let dbconfig-common know what database
#	type to use when a package supports multiple database types.
#	don't change this value unless you know for certain that this
#	package supports multiple database types
dbc_dbtype='pgsql'

# dbc_dbuser: database user
#	the name of the user who we will use to connect to the database.
dbc_dbuser='{{ .Values.database.db_user }}'

# dbc_dbpass: database user password
#	the password to use with the above username when connecting
#	to a database, if one is required
dbc_dbpass='{{ .Values.database.db_password }}'

# dbc_dbname: name of database
#	this is the name of your application's database.
dbc_dbname='{{ .Values.database.db_name }}'

# dbc_dbadmin: name of the administrative user
#	this is the administrative user that is used to create all of the above
#	The exception is the MySQL/MariaDB localhost case, where this value is
#	ignored and instead is determined from /etc/mysql/debian.cnf.
dbc_dbadmin='postgres'

dbc_dbserver={{ include "helm-toolkit.postgresql_host" . | quote }}
dbc_dbport={{ .Values.network.port.db_service }}

# dbc_authmethod_admin: authentication method for admin
# dbc_authmethod_user: authentication method for dbuser
#	see the section titled "AUTHENTICATION METHODS" in
#	/usr/share/doc/dbconfig-common/README.pgsql for more info
dbc_authmethod_admin='ident'
dbc_authmethod_user='password'
