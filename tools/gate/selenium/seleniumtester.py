# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import logging
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import ScreenshotException

class SeleniumTester():
    def __init__(self, name):
        self.logger = self.get_logger(name)
        self.chrome_driver = self.get_variable('CHROMEDRIVER')
        self.artifacts_dir = self.get_variable('ARTIFACTS_DIR')
        self.initialize_artifiacts_dir()
        self.browser = self.get_browser()

    def get_logger(self, name):
        logger = logging.getLogger('{} Selenium Tests'.format(name))
        logger.setLevel(logging.DEBUG)
        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )

        # Set the formatter and add the handler
        ch.setFormatter(formatter)
        logger.addHandler(ch)
        return logger

    def get_variable(self, env_var):
        if env_var in os.environ:
            self.logger.info('Found "{}"'.format(env_var))
            return os.environ[env_var]
        else:
            self.logger.critical(
                'Variable "{}" is not defined!'.format(env_var)
            )
            sys.exit(1)

    def get_browser(self):
        options = Options()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--window-size=1920x1080')
        service = Service(executable_path=self.chrome_driver)
        browser = webdriver.Chrome(service=service, options=options)
        return browser

    def initialize_artifiacts_dir(self):
        if self.artifacts_dir and not os.path.exists(self.artifacts_dir):
            os.makedirs(self.artifacts_dir)
            self.logger.info(
                'Created {} for test artifacts'.format(self.artifacts_dir)
            )

    def click_link_by_name(self, link_name):
        try:
            el = WebDriverWait(self.browser, 15).until(
                EC.presence_of_element_located((By.LINK_TEXT, link_name))
            )
            self.logger.info("Clicking '{}' link".format(link_name))
            link = self.browser.find_element(By.LINK_TEXT, link_name)
            link.click()
        except (TimeoutException, NoSuchElementException):
            self.logger.error("Failed clicking '{}' link".format(link_name))
            self.browser.quit()
            sys.exit(1)

    def take_screenshot(self, page_name):
        file_name = page_name.replace(' ', '_')
        try:
            el = WebDriverWait(self.browser, 15)
            self.browser.save_screenshot(
                '{}{}.png'.format(self.artifacts_dir, file_name)
            )
            self.logger.info(
                "Successfully captured {} screenshot".format(page_name)
            )
        except ScreenshotException:
            self.logger.error(
                "Failed to capture {} screenshot".format(page_name)
                )
            self.browser.quit()
            sys.exit(1)
