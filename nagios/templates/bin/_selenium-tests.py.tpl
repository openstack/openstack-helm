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
import logging
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Create logger, console handler and formatter
logger = logging.getLogger('Nagios Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

if "NAGIOS_USER" in os.environ:
  nagios_user = os.environ['NAGIOS_USER']
  logger.info('Found Nagios username')
else:
  logger.critical('Nagios username environment variable not set')
  sys.exit(1)

if "NAGIOS_PASSWORD" in os.environ:
  nagios_password = os.environ['NAGIOS_PASSWORD']
  logger.info('Found Nagios password')
else:
  logger.critical('Nagios password environment variable not set')
  sys.exit(1)

if "NAGIOS_URI" in os.environ:
  nagios_uri = os.environ['NAGIOS_URI']
  logger.info('Found Nagios URI')
else:
  logger.critical('Nagios URI environment variable not set')
  sys.exit(1)

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

logger.info("Attempting to open Chrome webdriver")
try:
  browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
  logger.info("Successfully opened Chrome webdriver")
except:
  logger.error("Unable to open Chrome webdriver")
  browser.close()
  sys.exit(1)

logger.info("Attempting to login to Nagios dashboard")
try:
  browser.get('http://'+nagios_user+':'+nagios_password+'@'+nagios_uri)
  logger.info("Successfully logged in to Nagios dashboard")
  sideFrame = browser.switch_to.frame('side')
  try:
    logger.info("Attempting to access Nagios services link")
    services = browser.find_element_by_link_text('Services')
    services.click()
    logger.info("Successfully accessed Nagios services link")
    try:
      logger.info("Attempting to capture Nagios services screen")
      el = WebDriverWait(browser, 15)
      browser.save_screenshot('/tmp/artifacts/Nagios_Services.png')
      logger.info("Successfully captured Nagios services screen")
    except:
      logger.error("Unable to capture Nagios services screen")
      browser.close()
      sys.exit(1)
  except:
    logger.error("Unable to access Nagios services link")
    browser.close()
    sys.exit(1)
  try:
    logger.info("Attempting to access Nagios host groups link")
    host_groups = browser.find_element_by_link_text('Host Groups')
    host_groups.click()
    logger.info("Successfully accessed Nagios host groups link")
    try:
      logger.info("Attempting to capture Nagios host groups screen")
      el = WebDriverWait(browser, 15)
      browser.save_screenshot('/tmp/artifacts/Nagios_Host_Groups.png')
      logger.info("Successfully captured Nagios host groups screen")
    except:
      logger.error("Unable to capture Nagios host groups screen")
      browser.close()
      sys.exit(1)
  except:
    logger.error("Unable to access Nagios host groups link")
    browser.close()
    sys.exit(1)
  try:
    logger.info("Attempting to access Nagios hosts link")
    hosts = browser.find_element_by_link_text('Hosts')
    hosts.click()
    logger.info("Successfully accessed Nagios hosts link")
    try:
      logger.info("Attempting to capture Nagios hosts screen")
      el = WebDriverWait(browser, 15)
      browser.save_screenshot('/tmp/artifacts/Nagios_Hosts.png')
      logger.info("Successfully captured Nagios hosts screen")
    except:
      logger.error("Unable to capture Nagios hosts screen")
      browser.close()
      sys.exit(1)
  except:
    logger.error("Unable to access Nagios hosts link")
    browser.close()
    sys.exit(1)
  browser.close()
  logger.info("The following screenshots were captured:")
  for root, dirs, files in os.walk("/tmp/artifacts/"):
    for name in files:
      logger.info(os.path.join(root, name))
except:
  logger.error("Unable to log in to Nagios dashbaord")
  browser.close()
  sys.exit(1)
