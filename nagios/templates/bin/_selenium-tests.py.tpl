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
import logging
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
from selenium.common.exceptions import ScreenshotException

# Create logger, console handler and formatter
logger = logging.getLogger('Nagios Selenium Tests')
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

def click_link_by_name(link_name):
    try:
        logger.info("Clicking '{}' link".format(link_name))
{{- if .Values.selenium_v4 }}
        link = browser.find_element(By.LINK_TEXT, link_name)
{{- else }}
        link = browser.find_element_by_link_text(link_name)
{{- end }}
        link.click()
    except NoSuchElementException:
        logger.error("Failed clicking '{}' link".format(link_name))
        browser.quit()
        sys.exit(1)

def take_screenshot(page_name, artifacts_dir='/tmp/artifacts/'):  # nosec
    file_name = page_name.replace(' ', '_')
    try:
        el = WebDriverWait(browser, 15)
        browser.save_screenshot('{}{}.png'.format(artifacts_dir, file_name))
        logger.info("Successfully captured {} screenshot".format(page_name))
    except ScreenshotException:
        logger.error("Failed to capture {} screenshot".format(page_name))
        browser.quit()
        sys.exit(1)

username = get_variable('NAGIOS_USER')
password = get_variable('NAGIOS_PASSWORD')
nagios_uri = get_variable('NAGIOS_URI')
nagios_url = 'http://{0}:{1}@{2}'.format(username, password, nagios_uri)

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

try:
    logger.info('Attempting to connect to Nagios')
    browser.get(nagios_url)
    el = WebDriverWait(browser, 15).until(
        EC.title_contains('Nagios')
    )
    logger.info('Connected to Nagios')
except TimeoutException:
    logger.critical('Timed out waiting for Nagios')
    browser.quit()
    sys.exit(1)

try:
    logger.info('Switching Focus to Navigation side frame')
    sideFrame = browser.switch_to.frame('side')
except NoSuchElementException:
    logger.error('Failed selecting side frame')
    browser.quit()
    sys.exit(1)

try:
    logger.info('Attempting to visit Services page')
    click_link_by_name('Services')
    take_screenshot('Nagios Services')
except TimeoutException:
    logger.error('Failed to load Services page')
    browser.quit()
    sys.exit(1)

try:
    logger.info('Attempting to visit Host Groups page')
    click_link_by_name('Host Groups')
    take_screenshot('Nagios Host Groups')
except TimeoutException:
    logger.error('Failed to load Host Groups page')
    browser.quit()
    sys.exit(1)

try:
    logger.info('Attempting to visit Hosts page')
    click_link_by_name('Hosts')
    take_screenshot('Nagios Hosts')
except TimeoutException:
    logger.error('Failed to load Hosts page')
    browser.quit()
    sys.exit(1)

logger.info("The following screenshots were captured:")
for root, dirs, files in os.walk("/tmp/artifacts/"):  # nosec
    for name in files:
        logger.info(os.path.join(root, name))

browser.quit()
