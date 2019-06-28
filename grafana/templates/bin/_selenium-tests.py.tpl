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

import logging
import os
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Create logger, console handler and formatter
logger = logging.getLogger('Grafana Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get Grafana admin user name
if "GRAFANA_USER" in os.environ:
  grafana_user = os.environ['GRAFANA_USER']
  logger.info('Found Grafana username')
else:
  logger.critical('Grafana username environment variable not set')
  sys.exit(1)

if "GRAFANA_PASSWORD" in os.environ:
  grafana_password = os.environ['GRAFANA_PASSWORD']
  logger.info('Found Grafana password')
else:
  logger.critical('Grafana password environment variable not set')
  sys.exit(1)

if "GRAFANA_URI" in os.environ:
  grafana_uri = os.environ['GRAFANA_URI']
  logger.info('Found Grafana URI')
else:
  logger.critical('Grafana URI environment variable not set')
  sys.exit(1)

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

logger.info("Attempting to open Grafana dashboard")
try:
  browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
  logger.info("Successfully opened Grafana dashboard")
except Exception as e:
  logger.error("Unable to open Grafana")
  browser.close()
  sys.exit(1)

logger.info("Attempting to log into Grafana dashboard")
try:
  browser.get(grafana_uri)
  browser.find_element_by_name('username').send_keys(grafana_user)
  browser.find_element_by_name('password').send_keys(grafana_password)
  browser.find_element_by_css_selector('body > grafana-app > div.main-view > div > div:nth-child(1) > div > div > div.login-inner-box > form > div.login-button-group > button').click()
  logger.info("Successfully logged in to Grafana")
except Exception as e:
  logger.error("Failed to log in to Grafana")
  browser.close()
  sys.exit(1)

browser.close()
