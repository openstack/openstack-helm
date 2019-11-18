# Copyright 2019 The Openstack-Helm Authors.

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
from seleniumtester import SeleniumTester

st = SeleniumTester('Grafana')

username = st.get_variable('GRAFANA_USER')
password = st.get_variable('GRAFANA_PASSWORD')
grafana_uri = st.get_variable('GRAFANA_URI')
grafana_url = 'http://{}'.format(grafana_uri)

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

try:
    st.logger.info('Attempting to login to Grafana')
    st.browser.find_element_by_name('username').send_keys(username)
    st.browser.find_element_by_name('password').send_keys(password)
    st.browser.find_element_by_css_selector(
        'body > grafana-app > div.main-view > div > div:nth-child(1) > div > '
        'div > div.login-outer-box > div.login-inner-box > form > div.login-button-group > button'
    ).click()
    st.logger.info("Successfully logged in to Grafana")
except NoSuchElementException:
    st.logger.error("Failed to log in to Grafana")
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to visit Nodes dashboard')
    st.click_link_by_name('Home')
    st.click_link_by_name('Nodes')
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located(
            (By.XPATH, '/html/body/grafana-app/div/div/div/react-container/div'
            '/div[2]/div/div[1]/div/div/div[1]/div/div/div/plugin-component'
            '/panel-plugin-graph/grafana-panel/div/div[2]')
        )
    )
    st.take_screenshot('Grafana Nodes')
except TimeoutException:
    st.logger.error('Failed to load Nodes dashboard')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to visit Cluster Status dashboard')
    st.click_link_by_name('Nodes')
    st.click_link_by_name('Kubernetes Cluster Status')
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located(
            (By.XPATH, '/html/body/grafana-app/div/div/div/react-container/div'
            '/div[2]/div/div[1]/div/div/div[5]/div/div/div/plugin-component'
            '/panel-plugin-singlestat/grafana-panel/div')
        )
    )
    st.take_screenshot('Grafana Cluster Status')
except TimeoutException:
    st.logger.error('Failed to load Cluster Status dashboard')
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
