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
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException
from seleniumtester import SeleniumTester

st = SeleniumTester('Nagios')

username = st.get_variable('NAGIOS_USER')
password = st.get_variable('NAGIOS_PASSWORD')
nagios_uri = st.get_variable('NAGIOS_URI')
nagios_url = 'http://{0}:{1}@{2}'.format(username, password, nagios_uri)

try:
    st.logger.info('Attempting to connect to Nagios')
    st.browser.get(nagios_url)
    el = WebDriverWait(st.browser, 15).until(
        EC.title_contains('Nagios')
    )
    st.logger.info('Connected to Nagios')
except TimeoutException:
    st.logger.critical('Timed out waiting for Nagios')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Switching Focus to Navigation side frame')
    sideFrame = st.browser.switch_to.frame('side')
except NoSuchElementException:
    st.logger.error('Failed selecting side frame')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to visit Services page')
    st.click_link_by_name('Services')
    st.take_screenshot('Nagios Services')
except TimeoutException:
    st.logger.error('Failed to load Services page')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to visit Host Groups page')
    st.click_link_by_name('Host Groups')
    st.take_screenshot('Nagios Host Groups')
except TimeoutException:
    st.logger.error('Failed to load Host Groups page')
    st.browser.quit()
    sys.exit(1)

try:
    st.logger.info('Attempting to visit Hosts page')
    st.click_link_by_name('Hosts')
    st.take_screenshot('Nagios Hosts')
except TimeoutException:
    st.logger.error('Failed to load Hosts page')
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
