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
import time

st = SeleniumTester('Skiline')

username = st.get_variable('SKYLINE_USER')
password = st.get_variable('SKYLINE_PASSWORD')
skyline_uri = st.get_variable('SKYLINE_URI')
login_url = 'http://{0}/auth/login'.format(skyline_uri)
overview_url = 'http://{0}/base/overview'.format(skyline_uri)

try:
    st.logger.info('Attempting to connect to Skyline')
    st.browser.get(login_url)
    el = WebDriverWait(st.browser, 15).until(
        EC.title_contains('Cloud')
    )
    st.logger.info('Connected to Skyline')
except TimeoutException:
    st.logger.critical('Timed out waiting to connect to Skyline')
    st.browser.quit()
    sys.exit(1)

time.sleep(5)
st.logger.info("Attempting to log into Skyline dashboard")
try:
    print(f"Cookies before login: {st.browser.get_cookies()}")
    st.browser.find_element(By.ID, 'normal_login_domain').send_keys(username)
    st.browser.find_element(By.ID, 'normal_login_password').send_keys(password)
    st.browser.find_element(By.CLASS_NAME, 'login-form-button').click()
    st.logger.info("Submitted login form")
    time.sleep(5)
    st.logger.info(f"Current url: {st.browser.current_url}")
    for cookie in st.browser.get_cookies():
        if cookie['name'] == 'session':
            st.logger.info(f"Session cookie: {cookie['name']} = {cookie['value']}")
            st.logger.info('Successfully logged in to Skyline')
except NoSuchElementException:
    st.logger.error("Failed to log in to Skyline")
    st.browser.quit()
    sys.exit(1)

st.browser.quit()
