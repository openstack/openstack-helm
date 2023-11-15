#!/usr/bin/env python
import os
import logging
import sys

from sqlalchemy import create_engine

try:
    import ConfigParser
    PARSER_OPTS = {}
except ImportError:
    import configparser as ConfigParser
    PARSER_OPTS = {"strict": False}

# Create logger, console handler and formatter
logger = logging.getLogger('OpenStack-Helm Keystone Endpoint management')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get the connection string for the service db
if "OPENSTACK_CONFIG_FILE" in os.environ:
    os_conf = os.environ['OPENSTACK_CONFIG_FILE']
    if "OPENSTACK_CONFIG_DB_SECTION" in os.environ:
        os_conf_section = os.environ['OPENSTACK_CONFIG_DB_SECTION']
    else:
        logger.critical(
            'environment variable OPENSTACK_CONFIG_DB_SECTION not set')
        sys.exit(1)
    if "OPENSTACK_CONFIG_DB_KEY" in os.environ:
        os_conf_key = os.environ['OPENSTACK_CONFIG_DB_KEY']
    else:
        logger.critical('environment variable OPENSTACK_CONFIG_DB_KEY not set')
        sys.exit(1)
    try:
        config = ConfigParser.RawConfigParser(**PARSER_OPTS)
        logger.info("Using {0} as db config source".format(os_conf))
        config.read(os_conf)
        logger.info("Trying to load db config from {0}:{1}".format(
            os_conf_section, os_conf_key))
        user_db_conn = config.get(os_conf_section, os_conf_key)
        logger.info("Got config from {0}".format(os_conf))
    except:
        logger.critical(
            "Tried to load config from {0} but failed.".format(os_conf))
        raise
elif "DB_CONNECTION" in os.environ:
    user_db_conn = os.environ['DB_CONNECTION']
    logger.info('Got config from DB_CONNECTION env var')
else:
    logger.critical(
        'Could not get db config, either from config file or env var')
    sys.exit(1)

# User DB engine
try:
    user_engine = create_engine(user_db_conn)
except:
    logger.critical('Could not get user database config')
    raise

# Set Internal Endpoint
try:
    endpoint_url = os.environ['OS_BOOTSTRAP_INTERNAL_URL']
    region_id = os.environ['OS_REGION_NAME']
    cmd = ("update endpoint set url = %s where interface ='internal' and "
           "service_id = (select id from service where "
           "service.type = 'identity') and "
           "region_id = %s")
    user_engine.execute(cmd, (endpoint_url,region_id))
except:
    logger.critical("Could not update internal endpoint")
    raise

# Set Admin Endpoint
try:
    endpoint_url = os.environ['OS_BOOTSTRAP_ADMIN_URL']
    region_id = os.environ['OS_REGION_NAME']
    cmd = ("update endpoint set url = %s where interface ='admin' "
           "and service_id = (select id from service where "
           "service.type = 'identity') "
           "and region_id = %s")
    user_engine.execute(cmd, (endpoint_url,region_id))
except:
    logger.critical("Could not update admin endpoint")
    raise

# Set Public Endpoint
try:
    endpoint_url = os.environ['OS_BOOTSTRAP_PUBLIC_URL']
    region_id = os.environ['OS_REGION_NAME']
    cmd = ("update endpoint set url = %s where interface ='public' "
           "and service_id = (select id from service where "
           "service.type = 'identity') "
           "and region_id = %s")
    user_engine.execute(cmd, (endpoint_url,region_id))
except:
    logger.critical("Could not update public endpoint")
    raise

# Print endpoints
try:
    endpoints = user_engine.execute(
        ("select interface, url from endpoint where service_id = "
         "(select id from service where service.type = 'identity')")
    ).fetchall()
    for row in endpoints:
        logger.info("endpoint ({0}): {1}".format(row[0], row[1]))
except:
    logger.critical("Could not update endpoint")
    raise

logger.info('Finished Endpoint Management')
