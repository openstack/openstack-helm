#!/usr/bin/env python3

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

import os
import sys
import logging

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
{{- if .Values.selenium_v4 }}
from selenium.webdriver.chrome.service import Service
{{- end }}
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException

# Create logger, console handler and formatter
logger = logging.getLogger('Horizon Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

ch.setFormatter(formatter)
logger.addHandler(ch)


def get_variable(env_var):
    if env_var in os.environ:
        logger.info('Found "{}"'.format(env_var))
        return os.environ[env_var]
    else:
        logger.critical('Variable "{}" is not defined!'.format(env_var))
        sys.exit(1)


keystone_user = get_variable('OS_USERNAME')
keystone_password = get_variable('OS_PASSWORD')
horizon_uri = get_variable('HORIZON_URI')
user_domain_name = get_variable('OS_USER_DOMAIN_NAME')

# Add options to make chrome browser headless
options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
chrome_driver = '/etc/selenium/chromedriver'
{{- if .Values.selenium_v4 }}
service = Service(executable_path=chrome_driver)
browser = webdriver.Chrome(service=service, options=options)
{{- else }}
browser = webdriver.Chrome(chrome_driver, chrome_options=options)
{{- end }}

try:
    logger.info('Attempting to connect to Horizon')
    browser.get(horizon_uri)
    el = WebDriverWait(browser, 15).until(
        EC.title_contains('OpenStack Dashboard')
    )
    logger.info('Connected to Horizon')
except TimeoutException:
    logger.critical('Timed out waiting for Horizon')
    browser.quit()
    sys.exit(1)

try:
    logger.info('Attempting to log into Horizon')
{{- if .Values.selenium_v4 }}
    browser.find_element(By.NAME, 'domain').send_keys(user_domain_name)
    browser.find_element(By.NAME, 'username').send_keys(keystone_user)
    browser.find_element(By.NAME, 'password').send_keys(keystone_password)
    browser.find_element(By.ID, 'loginBtn').click()
{{- else }}
    browser.find_element_by_name('domain').send_keys(user_domain_name)
    browser.find_element_by_name('username').send_keys(keystone_user)
    browser.find_element_by_name('password').send_keys(keystone_password)
    browser.find_element_by_id('loginBtn').click()
{{- end }}
    WebDriverWait(browser, 15).until(
        EC.presence_of_element_located((By.ID, 'navbar-collapse'))
    )
    logger.info("Successfully logged into Horizon")
except (TimeoutException, NoSuchElementException):
    logger.error('Failed to login to Horizon')
    browser.quit()
    sys.exit(1)

browser.quit()
