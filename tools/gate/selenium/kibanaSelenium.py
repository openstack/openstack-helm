import logging
import os
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException

logger = logging.getLogger('Kibana Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')

ch.setFormatter(formatter)
logger.addHandler(ch)

artifacts = '/tmp/artifacts/'
if not os.path.exists(artifacts):
    os.makedirs(artifacts)


def get_variable(env_var):
    if env_var in os.environ:
        logger.info('Found "{}"'.format(env_var))
        return os.environ[env_var]
    else:
        logger.critical('Variable "{}" is not defined!'.format(env_var))
        sys.exit(1)


kibana_user = get_variable('KIBANA_USER')
kibana_password = get_variable('KIBANA_PASSWORD')
kibana_journal_uri = get_variable('KIBANA_JOURNAL_URI')
kibana_kernel_uri = get_variable('KIBANA_KERNEL_URI')
kibana_logstash_uri = get_variable('KIBANA_LOGSTASH_URI')

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

targets = [(kibana_kernel_uri, 'Kernel'),
           (kibana_journal_uri, 'Journal'),
           (kibana_logstash_uri, 'Logstash')]

for target, name in targets:
    retry = 3
    while retry > 0:
        prefix = ''
        browser = webdriver.Chrome(
            '/etc/selenium/chromedriver', chrome_options=options)
        url = "http://{0}:{1}@{2}".format(kibana_user, kibana_password, target)
        browser.get(url)

        try:
            WebDriverWait(browser, 60).until(
                EC.presence_of_element_located(
                    (By.XPATH, '//*[@id="kibana-body"]/div[1]/div/div/div[3]/'
                     'discover-app/div/div[2]/div[2]/div/div[2]/div[2]/'
                     'doc-table/div/table/tbody/tr[1]/td[2]'))
            )
            logger.info('{} index loaded successfully'.format(name))
            retry = 0
        except TimeoutException, e:
            logger.error('Error occured loading {} index'.format(name))
            prefix = 'Error_'
        browser.save_screenshot(
            artifacts + '{}Kibana_{}.png'.format(prefix, name))
        browser.quit()
        retry -= 1
