#!/usr/bin/env python3

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium_tester import SeleniumTester

st = SeleniumTester('Prometheus')

username = st.get_variable('PROMETHEUS_USER', 'admin')
password = st.get_variable('PROMETHEUS_PASSWORD', 'changeme')
prometheus_uri = st.get_variable('PROMETHEUS_URI', 'prometheus.openstack-helm.org')
prometheus_url = 'http://{}'.format(prometheus_uri)

try:
    st.logger.info('Attempting to connect to Prometheus')
    st.set_basic_auth(username, password)
    st.browser.get(prometheus_url)
    el = WebDriverWait(st.browser, 15).until(
        EC.title_contains('Prometheus')
    )
    st.logger.info('Connected to Prometheus')
    st.take_screenshot('Prometheus Dashboard')
except TimeoutException:
    st.logger.critical('Timed out waiting for Prometheus')
    st.browser.quit()
    sys.exit(1)

# These pages used to be checked for a table at /html/body/div/table, an
# absolute path that says the table is a child of the first div in the body.
# That describes one particular rendering of the page and broke as soon as
# the UI put anything else around it.
#
# Waiting for a table anywhere would fix that and introduce a worse problem:
# the flags page is reached from the runtime page, which already has a table,
# so the wait would be satisfied by the page we are leaving and the test would
# pass without ever arriving. Require the URL to change first, so the wait is
# for a table on the new page.
try:
    st.logger.info('Attempting to view Runtime Information')
    previous_url = st.browser.current_url
    st.click_link_by_name('Status')
    st.click_link_by_name('Runtime & Build Information')
    WebDriverWait(st.browser, 15).until(EC.url_changes(previous_url))
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located((By.TAG_NAME, 'table'))
    )
    st.take_screenshot('Prometheus Runtime Info')
except TimeoutException:
    st.logger.error('Failed to load Runtime Information page')
    st.take_screenshot('Prometheus Runtime Info Failure')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to view Command-Line Flags')
    previous_url = st.browser.current_url
    st.click_link_by_name('Status')
    st.click_link_by_name('Command-Line Flags')
    WebDriverWait(st.browser, 15).until(EC.url_changes(previous_url))
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located((By.TAG_NAME, 'table'))
    )
    st.take_screenshot('Prometheus Command Line Flags')
except TimeoutException:
    st.logger.error('Failed to load Command Line Flags page')
    st.take_screenshot('Prometheus Command Line Flags Failure')
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
