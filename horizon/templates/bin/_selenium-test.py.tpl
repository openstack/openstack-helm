#!/usr/bin/env python

{{/*
Copyright 2019 The Openstack-Helm Authors.

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

import os
import sys
import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Create logger, console handler and formatter
logger = logging.getLogger('Horizon Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

ch.setFormatter(formatter)
logger.addHandler(ch)

# Get keystone admin user name
if "OS_USERNAME" in os.environ:
  keystone_user = os.environ['OS_USERNAME']
  logger.info('Found Keystone username')
else:
  logger.critical('Keystone username environment variable not set')
  sys.exit(1)
if "OS_PASSWORD" in os.environ:
  keystone_password = os.environ['OS_PASSWORD']
  logger.info('Found Keystone password')
else:
  logger.critical('Keystone password environment variable not set')
  sys.exit(1)
if "HORIZON_URI" in os.environ:
  horizon_uri = os.environ['HORIZON_URI']
  logger.info('Found Horizon URI')
else:
  logger.critical('Horizon URI environment variable not set')
  sys.exit(1)
if "OS_USER_DOMAIN_NAME" in os.environ:
  user_domain_name = os.environ['OS_USER_DOMAIN_NAME']
  logger.info('Found Keystone user domain')
else:
  logger.critical('Keystone user domain environment variable not set')
  sys.exit(1)

# Add options to make chrome browser headless
options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
browser.get(horizon_uri)

try:
    browser.find_element_by_name('domain').send_keys(user_domain_name)
    browser.find_element_by_name('username').send_keys(keystone_user)
    browser.find_element_by_name('password').send_keys(keystone_password)
    logger.info("Successfully reached Horizon dashboard")
except:
    logger.error('Unable to reach Horizon')
    browser.close()
    sys.exit(1)

try:
  browser.find_element_by_id('loginBtn').click()
  WebDriverWait(browser, 15).until(
      EC.presence_of_element_located((By.ID, 'navbar-collapse'))
  )
  logger.info("Successfully logged into Horizon")
except:
  logger.error("Unable to login to Horizon")
  browser.close()
  sys.exit(1)

browser.close()
