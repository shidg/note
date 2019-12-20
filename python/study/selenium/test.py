#!/usr/bin/python
# -*- coding: utf-8 -*- #
'''
author: -- shidegang --
Created Time: 2019-12-20 16:04:48
'''
from selenium import webdriver

options = webdriver.ChromeOptions()
#options.add_argument('--proxy-server=http://221.6.201.18:9999')

browser = webdriver.Chrome('chromedriver',options=options)
#browser = webdriver.Firefox()
browser.get('http://httpbin.org/ip')
print(browser.page_source)
