#!/usr/bin/env python
import os
import sys
import time
import pymysql

DB_HOST = "127.0.0.1"
DB_PORT = int(os.environ.get('MARIADB_SERVICE_PORT', '3306'))

while True:
    try:
        pymysql.connections.Connection(host=DB_HOST, port=DB_PORT,
                                       connect_timeout=1)
        sys.exit(0)
    except pymysql.err.OperationalError as e:
        code, message = e.args

        if code == 2003 and 'time out' in message:
            print('Connection timeout, sleeping')
            time.sleep(1)
            continue
        if code == 1045:
            print('Mysql ready to use. Exiting')
            sys.exit(0)

        # other error
        raise
