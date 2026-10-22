{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

#!/usr/bin/python

import os
import sys
import logging
from sqlalchemy import create_engine
from sqlalchemy import text

from oslo_config import cfg


# Create logger, console handler and formatter
logger = logging.getLogger('Keystone credential cleanup')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

mysql_x509 = os.getenv('MARIADB_X509', "")
ssl_args = {}
if mysql_x509:
    ssl_args = {'ssl': {'ca': '/etc/mysql/certs/ca.crt',
                        'key': '/etc/mysql/certs/tls.key',
                        'cert': '/etc/mysql/certs/tls.crt'}}

# Get the connection string for the service db
cfg.CONF.register_opt(cfg.StrOpt('connection'), 'database')
cfg.CONF(sys.argv[1:])

user_db_conn = cfg.CONF.database.connection
if not user_db_conn:
    logger.critical(
        'Could not get db config from config file'
    )
    sys.exit(1)

# User DB engine
try:
    user_engine = create_engine(user_db_conn, connect_args=ssl_args)
    logger.info('Got user db config')
except:
    logger.critical('Could not get user database config')
    raise

# Delete all entries from credential table
try:
    cmd = text("DELETE FROM credential")
    with user_engine.connect() as connection:
        connection.execute(cmd)
        try:
            connection.commit()
        except AttributeError:
            pass
    logger.info('Deleted all entries in credential table')
except:
    logger.critical('Failed to clean up credential table in keystone db')
    raise

logger.info('Finished DB Management')
