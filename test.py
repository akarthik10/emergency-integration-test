from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import random
import string
import time

delay = 5
polygon_script = "var polygon = L.polygon([ [42.40267150842343, -72.56280899047853], [42.3643786536149, -72.56280899047853], [42.35829022102702, -72.49071121215822], [42.419908345406256, -72.48041152954103]]).addTo(map); polygonsDrawn[polygon._leaflet_id] = polygon;"

def type_into_field(name, value):
	input = driver.find_element_by_xpath("//label[text()='"+name+"']").get_attribute("for")
	driver.find_element_by_id(input).send_keys(value)

driver = webdriver.Firefox(executable_path=r'bin/geckodriver')
driver.get("http://localhost:8000")
assert 'Register' in driver.page_source
driver.implicitly_wait(5)

driver.find_element_by_link_text("Register").click()

type_into_field("Name", "Test User")
random = ''.join([random.choice(string.ascii_letters + string.digits) for n in xrange(10)])
type_into_field("E-Mail Address", random + "@" + random + ".com")
type_into_field("Password", random)
type_into_field("Confirm Password", random)
driver.find_element_by_xpath("//button[contains(.,'Register')]").click()

time.sleep(5)
type_into_field("Title", "Test notification")
type_into_field("Body", "Test notification body")
driver.execute_script(polygon_script)
driver.find_element_by_xpath("//button[contains(.,'Send')]").click()
time.sleep(120)
driver.close()
