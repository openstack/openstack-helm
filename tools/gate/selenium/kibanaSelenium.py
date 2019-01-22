import logging
import os
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException
from threading import Thread

logger = logging.getLogger('Kibana Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

ch.setFormatter(formatter)
logger.addHandler(ch)

# Get Grafana admin user name
if "KIBANA_USER" in os.environ:
  kibana_user = os.environ['KIBANA_USER']
  logger.info('Found Kibana username')
else:
  logger.critical('Kibana username environment variable not set')
  sys.exit(1)

if "KIBANA_PASSWORD" in os.environ:
  kibana_password = os.environ['KIBANA_PASSWORD']
  logger.info('Found Kibana password')
else:
  logger.critical('Kibana password environment variable not set')
  sys.exit(1)

if "KIBANA_JOURNAL_URI" in os.environ:
  kibana_journal_uri = os.environ['KIBANA_JOURNAL_URI']
  logger.info('Found Kibana Journal URI')
else:
  logger.critical('Kibana Journal URI environment variable not set')
  sys.exit(1)

if "KIBANA_KERNEL_URI" in os.environ:
  kibana_kernel_uri = os.environ['KIBANA_KERNEL_URI']
  logger.info('Found Kibana Kernel URI')
else:
  logger.critical('Kibana Kernel URI environment variable not set')
  sys.exit(1)

if "KIBANA_LOGSTASH_URI" in os.environ:
  kibana_logstash_uri = os.environ['KIBANA_LOGSTASH_URI']
  logger.info('Found Kibana Logstash URI')
else:
  logger.critical('Kibana Logstash URI environment variable not set')
  sys.exit(1)

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

errNO = 1

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
url = "http://{0}:{1}@{2}".format(kibana_user, kibana_password, kibana_journal_uri)
browser.get(url)

try:
    WebDriverWait(browser, 60).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="kibana-body"]/div[1]/div/div/div[3]/discover-app/div/div[2]/div[2]/div/div[2]/div[2]/doc-table/div/table/tbody/tr[1]/td[2]'))
    )
    browser.save_screenshot('/tmp/artifacts/Kibana_JournalIndex.png')
except TimeoutException, e:
    browser.save_screenshot('/tmp/artifacts/Error_{}.png'.format(errNO))
    logger.error('Error occured loading Journal index')
    errNO += 1

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
url = "http://{0}:{1}@{2}".format(kibana_user, kibana_password, kibana_kernel_uri)
browser.get(url)

try:
    WebDriverWait(browser, 60).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="kibana-body"]/div[1]/div/div/div[3]/discover-app/div/div[2]/div[2]/div/div[2]/div[2]/doc-table/div/table/tbody/tr[1]/td[2]'))
    )
    browser.save_screenshot('/tmp/artifacts/Kibana_KernelIndex.png')
except TimeoutException, e:
    browser.save_screenshot('/tmp/artifacts/Error_{}.png'.format(errNO))
    logger.error('Error occured loading Kernel index')
    errNO += 1

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)
url = "http://{0}:{1}@{2}".format(kibana_user, kibana_password, kibana_logstash_uri)
browser.get(url)

try:
    WebDriverWait(browser, 60).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="kibana-body"]/div[1]/div/div/div[3]/discover-app/div/div[2]/div[2]/div/div[2]/div[2]/doc-table/div/table/tbody/tr[1]/td[2]'))
    )
    browser.save_screenshot('/tmp/artifacts/Kibana_LogstashIndex.png')
except TimeoutException, e:
    browser.save_screenshot('/tmp/artifacts/Error_{}.png'.format(errNO))
    logger.error('Error occured loading Logstash index')
    errNO += 1
