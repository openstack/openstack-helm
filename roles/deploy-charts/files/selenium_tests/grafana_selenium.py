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
from selenium.common.exceptions import NoSuchElementException
from selenium_tester import SeleniumTester

st = SeleniumTester('Grafana')

username = st.get_variable('GRAFANA_USER', 'admin')
password = st.get_variable('GRAFANA_PASSWORD', 'password')
grafana_uri = st.get_variable('GRAFANA_URI', 'grafana.openstack-helm.org')
grafana_url = 'http://{0}'.format(grafana_uri)

try:
    st.logger.info('Attempting to connect to Grafana')
    st.browser.get(grafana_url)
    el = WebDriverWait(st.browser, 15).until(
        EC.title_contains('Grafana')
    )
    st.logger.info('Connected to Grafana')
except TimeoutException:
    st.logger.critical('Timed out waiting to connect to Grafana')
    st.browser.quit()
    sys.exit(1)

st.logger.info("Attempting to log into Grafana dashboard")
try:
    st.browser.find_element(By.NAME, 'user').send_keys(username)
    st.browser.find_element(By.NAME, 'password').send_keys(password)
    # Grafana builds its CSS class names with Emotion, so they are content
    # hashes -- the button used to be found by class "css-1mhnkuh", which
    # stopped existing the first time the frontend was rebuilt and took this
    # test with it. The submit button is the only one on the login form and
    # its type is part of the form's behaviour rather than its styling.
    st.browser.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
except NoSuchElementException:
    st.logger.error("Failed to find the Grafana login form")
    st.browser.quit()
    sys.exit(1)

# Clicking submit proves nothing: Grafana answers bad credentials by staying
# on /login and showing a message, so a test that stopped at the click above
# passed whether or not the credentials worked. Grafana sends an
# authenticated session anywhere but /login.
try:
    WebDriverWait(st.browser, 15).until(
        lambda browser: '/login' not in browser.current_url
    )
    st.logger.info("Successfully logged in to Grafana")
    st.take_screenshot('Grafana Dashboard')
except TimeoutException:
    st.logger.error(
        "Grafana did not accept the credentials for user '{}'".format(username)
    )
    st.take_screenshot('Grafana Login Failure')
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
