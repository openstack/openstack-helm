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

{{/*
NOTE (Portdirect): This file is required to support Horizon regardless of the
image used, and to provide PyMySQL support.
*/}}

import logging
import os
import sys

import pymysql

pymysql.version_info = (1, 3, 13, "final", 0)
pymysql.install_as_MySQLdb()

from django.core.wsgi import get_wsgi_application
from django.conf import settings

# Add this file path to sys.path in order to import settings
sys.path.insert(0, os.path.join(os.path.dirname(os.path.realpath(__file__)), '../..'))
os.environ['DJANGO_SETTINGS_MODULE'] = 'openstack_dashboard.settings'
sys.stdout = sys.stderr

DEBUG = False

application = get_wsgi_application()
