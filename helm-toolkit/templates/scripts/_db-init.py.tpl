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

{{- define "helm-toolkit.db_init" }}
#!/usr/bin/env python

# Creates db and user for an OpenStack Service:
# Set ROOT_DB_CONNECTION and DB_CONNECTION environment variables to contain
# SQLAlchemy strings for the root connection to the database and the one you
# wish the service to use. Alternatively, you can use an ini formatted config
# at the location specified by OPENSTACK_CONFIG_FILE, and extract the string
# from the key OPENSTACK_CONFIG_DB_KEY, in the section specified by
# OPENSTACK_CONFIG_DB_SECTION.

import os
import sys
import ConfigParser
from sqlalchemy import create_engine

# Get the connection string for the service db root user
if "ROOT_DB_CONNECTION" in os.environ:
    db_connection = os.environ['ROOT_DB_CONNECTION']
else:
    print 'ROOT_DB_CONNECTION env var missing'
    sys.exit(1)

# Get the connection string for the service db
if "OPENSTACK_CONFIG_FILE" in os.environ:
    try:
        os_conf = os.environ['OPENSTACK_CONFIG_FILE']
        if "OPENSTACK_CONFIG_DB_SECTION" in os.environ:
            os_conf_section = os.environ['OPENSTACK_CONFIG_DB_SECTION']
        else:
            print 'Env var OPENSTACK_CONFIG_DB_SECTION not set'
            sys.exit(1)
        if "OPENSTACK_CONFIG_DB_KEY" in os.environ:
            os_conf_key = os.environ['OPENSTACK_CONFIG_DB_KEY']
        else:
            print 'Env var OPENSTACK_CONFIG_DB_KEY not set'
            sys.exit(1)
        config = ConfigParser.RawConfigParser()
        print("Using {0} as db config source".format(os_conf))
        config.read(os_conf)
        print("Trying to load db config from {0}:{1}".format(
            os_conf_section, os_conf_key))
        user_db_conn = config.get(os_conf_section, os_conf_key)
        print("Got config from {0}".format(os_conf))
    except:
        print("Tried to load config from {0} but failed.".format(os_conf))
        sys.exit(1)
elif "DB_CONNECTION" in os.environ:
    user_db_conn = os.environ['DB_CONNECTION']
    print 'Got config from DB_CONNECTION env var'
else:
    print 'Could not get db config, either from config file or env var'
    sys.exit(1)

# Root DB engine
try:
    root_engine_full = create_engine(db_connection)
    root_user = root_engine_full.url.username
    root_password = root_engine_full.url.password
    drivername = root_engine_full.url.drivername
    host = root_engine_full.url.host
    port = root_engine_full.url.port
    root_engine_url = ''.join([drivername, '://', root_user, ':', root_password, '@', host, ':', str (port)])
    root_engine = create_engine(root_engine_url)
    connection = root_engine.connect()
    connection.close()
except:
    print 'Could not connect to database as root user'
    sys.exit(1)

# User DB engine
try:
    user_engine = create_engine(user_db_conn)
    # Get our user data out of the user_engine
    database = user_engine.url.database
    user = user_engine.url.username
    password = user_engine.url.password
    print 'Got user db config'
except:
    print 'Could not get user database config'
    sys.exit(1)

# Create DB
try:
    root_engine.execute("CREATE DATABASE IF NOT EXISTS {0}".format(database))
    print("Created database {0}".format(database))
except:
    print("Could not create database {0}".format(database))
    sys.exit(1)

# Create DB User
try:
    root_engine.execute(
        "GRANT ALL ON `{0}`.* TO \'{1}\'@\'%%\' IDENTIFIED BY \'{2}\'".format(
            database, user, password))
    print("Created user {0} for {1}".format(user, database))
except:
    print("Could not create user {0} for {1}".format(user, database))
    sys.exit(1)

# Test connection
try:
    connection = user_engine.connect()
    connection.close()
    print 'Database connection for user ok'
except:
    print 'Could not connect to database as user'
    sys.exit(1)
{{- end }}
