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

import logging
import os
import sys
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
logger = logging.getLogger('Grafana Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

def get_variable(env_var):
    if env_var in os.environ:
        logger.info('Found "{}"'.format(env_var))
        return os.environ[env_var]
    else:
        logger.critical('Variable "{}" is not defined!'.format(env_var))
        sys.exit(1)

username = get_variable('GRAFANA_USER')
password = get_variable('GRAFANA_PASSWORD')
grafana_uri = get_variable('GRAFANA_URI')

chrome_driver = '/etc/selenium/chromedriver'
options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

{{- if .Values.selenium_v4 }}
service = Service(executable_path=chrome_driver)
browser = webdriver.Chrome(service=service, options=options)
{{- else }}
browser = webdriver.Chrome(chrome_driver, chrome_options=options)
{{- end }}

logger.info("Attempting to open Grafana dashboard")
try:
    browser.get(grafana_uri)
    el = WebDriverWait(browser, 15).until(
    EC.title_contains('Grafana')
    )
    logger.info('Connected to Grafana')
except TimeoutException:
    logger.critical('Timed out waiting for Grafana')
    browser.quit()
    sys.exit(1)

logger.info("Attempting to log into Grafana dashboard")
try:
{{- if .Values.selenium_v4 }}
    browser.find_element(By.NAME, 'user').send_keys(username)
    browser.find_element(By.NAME, 'password').send_keys(password)
    browser.find_element(By.CSS_SELECTOR, '[aria-label="Login button"]').click()
{{- else }}
    browser.find_element_by_name('user').send_keys(username)
    browser.find_element_by_name('password').send_keys(password)
    browser.find_element_by_css_selector('[aria-label="Login button"]').click()
{{- end }}
    logger.info("Successfully logged in to Grafana")
except NoSuchElementException:
    logger.error("Failed to log in to Grafana")
    browser.quit()
    sys.exit(1)

browser.quit()
