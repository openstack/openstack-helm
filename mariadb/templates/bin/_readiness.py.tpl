#!/usr/bin/env python
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
