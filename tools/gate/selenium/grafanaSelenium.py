import logging
import os
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Create logger, console handler and formatter
logger = logging.getLogger('Grafana Selenium Tests')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get Grafana admin user name
if "GRAFANA_USER" in os.environ:
  grafana_user = os.environ['GRAFANA_USER']
  logger.info('Found Grafana username')
else:
  logger.critical('Grafana username environment variable not set')
  sys.exit(1)

if "GRAFANA_PASSWORD" in os.environ:
  grafana_password = os.environ['GRAFANA_PASSWORD']
  logger.info('Found Grafana password')
else:
  logger.critical('Grafana password environment variable not set')
  sys.exit(1)

if "GRAFANA_URI" in os.environ:
  grafana_uri = os.environ['GRAFANA_URI']
  logger.info('Found Grafana URI')
else:
  logger.critical('Grafana URI environment variable not set')
  sys.exit(1)

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1920x1080')

browser = webdriver.Chrome('/etc/selenium/chromedriver', chrome_options=options)

browser.get(grafana_uri)
username = browser.find_element_by_name('username')
username.send_keys(grafana_user)

password = browser.find_element_by_name('password')
password.send_keys(grafana_password)

login = browser.find_element_by_css_selector('body > grafana-app > div.main-view > div > div:nth-child(1) > div > div > div.login-inner-box > form > div.login-button-group > button')
login.click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.LINK_TEXT, 'Home'))
)

homeBtn = browser.find_element_by_link_text('Home')
homeBtn.click()


el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.LINK_TEXT, 'Nodes'))
)

nodeBtn = browser.find_element_by_link_text('Nodes')
nodeBtn.click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.XPATH, '/html/body/grafana-app/div[2]/div/div[1]/div/div/div[1]/dashboard-grid/div/div[1]/div/plugin-component/panel-plugin-graph/grafana-panel/div/div[2]'))
)

browser.save_screenshot('/tmp/artifacts/Grafana_Nodes.png')

nodeBtn = browser.find_element_by_link_text('Nodes')
nodeBtn.click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.LINK_TEXT, 'Kubernetes Cluster Status'))
)

healthBtn = browser.find_element_by_link_text('Kubernetes Cluster Status')
healthBtn.click()

el = WebDriverWait(browser, 15).until(
    EC.presence_of_element_located((By.XPATH, '/html/body/grafana-app/div[2]/div/div[1]/div/div/div[1]/dashboard-grid/div/div[5]/div/plugin-component/panel-plugin-singlestat/grafana-panel/div'))
)

browser.save_screenshot('/tmp/artifacts/Grafana_ClusterStatus.png')
