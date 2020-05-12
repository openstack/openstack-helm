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
from seleniumtester import SeleniumTester

st = SeleniumTester('Prometheus')

username = st.get_variable('PROMETHEUS_USER')
password = st.get_variable('PROMETHEUS_PASSWORD')
prometheus_uri = st.get_variable('PROMETHEUS_URI')
prometheus_url = 'http://{}:{}@{}'.format(username, password, prometheus_uri)

try:
    st.logger.info('Attempting to connect to Prometheus')
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

try:
    st.logger.info('Attempting to view Runtime Information')
    st.click_link_by_name('Status')
    st.click_link_by_name('Runtime & Build Information')
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located((By.XPATH, '/html/body/div/table[1]'))
    )
    st.take_screenshot('Prometheus Runtime Info')
except TimeoutException:
    st.logger.error('Failed to load Runtime Information page')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to view Runtime Information')
    st.click_link_by_name('Status')
    st.click_link_by_name('Command-Line Flags')
    el = WebDriverWait(st.browser, 15).until(
        EC.presence_of_element_located((By.XPATH, '/html/body/div/table'))
    )
    st.take_screenshot('Prometheus Command Line Flags')
except TimeoutException:
    st.logger.error('Failed to load Command Line Flags page')
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
