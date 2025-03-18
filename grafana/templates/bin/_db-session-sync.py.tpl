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
import logging
from sqlalchemy import create_engine

# Create logger, console handler and formatter
logger = logging.getLogger('OpenStack-Helm DB Init')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(filename)s - %(lineno)d - %(funcName)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get the connection string for the service db
if "DB_CONNECTION" in os.environ:
    user_db_conn = os.environ['DB_CONNECTION']
    logger.info('Got config from DB_CONNECTION env var')
else:
    logger.critical('Could not get db config, either from config file or env var')
    sys.exit(1)

# User DB engine
try:
    user_engine = create_engine(user_db_conn)
    # Get our user data out of the user_engine
    database = user_engine.url.database
    user = user_engine.url.username
    password = user_engine.url.password
    host = user_engine.url.host
    port = user_engine.url.port
    logger.info('Got user db config')
except:
    logger.critical('Could not get user database config')
    raise

# Test connection
try:
    connection = user_engine.connect()
    connection.close()
    logger.info("Tested connection to DB @ {0}:{1}/{2} as {3}".format(
        host, port, database, user))
except:
    logger.critical('Could not connect to database as user')
    raise

# Create Table
try:
    user_engine.execute('''CREATE TABLE IF NOT EXISTS `session` (
                        `key`CHAR(16) NOT NULL,
                        `data` BLOB,
                        `expiry` INT(11) UNSIGNED NOT NULL,
                        PRIMARY KEY (`key`)
                        ) ENGINE=MyISAM DEFAULT CHARSET=utf8;''')
    logger.info('Created table for session cache')
except:
    logger.critical('Could not create table for session cache')
    raise
