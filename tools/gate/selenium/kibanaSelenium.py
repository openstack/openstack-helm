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

st = SeleniumTester('Kibana')

username = st.get_variable('KIBANA_USER')
password = st.get_variable('KIBANA_PASSWORD')
kibana_uri = st.get_variable('KIBANA_URI')
kibana_url = 'http://{0}:{1}@{2}'.format(username, password, kibana_uri)

try:
    st.logger.info('Attempting to connect to Kibana')
    st.browser.get(kibana_url)
    el = WebDriverWait(st.browser, 45).until(
        EC.title_contains('Kibana')
    )
    st.logger.info('Connected to Kibana')
except TimeoutException:
    st.logger.critical('Timed out waiting for Kibana')
    st.browser.quit()
    sys.exit(1)

kernel_query = st.get_variable('KERNEL_QUERY')
journal_query = st.get_variable('JOURNAL_QUERY')
logstash_query = st.get_variable('LOGSTASH_QUERY')

queries = [(kernel_query, 'Kernel'),
           (journal_query, 'Journal'),
           (logstash_query, 'Logstash')]

for query, name in queries:
    retry = 3
    while retry > 0:
        query_url = '{}/app/kibana#/{}'.format(kibana_url, query)

        try:
            st.logger.info('Attempting to query {} index'.format(name))
            st.browser.get(query_url)
            WebDriverWait(st.browser, 60).until(
                EC.presence_of_element_located(
                    (By.XPATH, '/html/body/div[2]/div/div/div/div[3]/'
                    'discover-app/main/div/div[2]/div/div[2]/section[2]/'
                    'doc-table/div/table/tbody/tr[1]/td[2]')
                )
            )
            st.logger.info('{} index loaded successfully'.format(name))
            st.take_screenshot('Kibana {} Index'.format(name))
            retry = 0

        except TimeoutException:
            if retry > 1:
                st.logger.warning('Timed out loading {} index'.format(name))
            else:
                st.logger.error('Could not load {} index'.format(name))

        retry -= 1
        if retry <= 0:
            # Reset test condition
            st.browser.get(kibana_url)

st.browser.quit()
