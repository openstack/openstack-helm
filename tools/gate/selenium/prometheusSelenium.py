import os
import logging
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Create logger, console handler and formatter
logger = logging.getLogger('Prometheus Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get Grafana admin user name
if "PROMETHEUS_USER" in os.environ:
  prometheus_user = os.environ['PROMETHEUS_USER']
  logger.info('Found Prometheus username')
else:
  logger.critical('Prometheus username environment variable not set')
  sys.exit(1)

if "PROMETHEUS_PASSWORD" in os.environ:
  prometheus_password = os.environ['PROMETHEUS_PASSWORD']
  logger.info('Found Prometheus password')
else:
  logger.critical('Prometheus password environment variable not set')
  sys.exit(1)

if "PROMETHEUS_URI" in os.environ:
  prometheus_uri = os.environ['PROMETHEUS_URI']
  logger.info('Found Prometheus URI')
else:
  logger.critical('Prometheus URI environment variable not set')
  sys.exit(1)

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)

browser.get("http://"+prometheus_user+":"+prometheus_password+"@"+prometheus_uri)

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.NAME, 'submit'))
)

browser.save_screenshot('/tmp/artifacts/Prometheus_Dash.png')


statusBtn = browser.find_element_by_link_text('Status')
statusBtn.click()

browser.find_element_by_link_text('Runtime & Build Information').click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.XPATH, '/html/body/div/table[1]'))
)

browser.save_screenshot('/tmp/artifacts/Prometheus_RuntimeInfo.png')

statusBtn = browser.find_element_by_link_text('Status')
statusBtn.click()

browser.find_element_by_link_text('Command-Line Flags').click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.XPATH, '/html/body/div/table'))
)

browser.save_screenshot('/tmp/artifacts/Prometheus_CommandLineFlags.png')
