#!/usr/bin/env python
# -*- coding: utf-8 -*-#
'''
@Author: --- shidg ---
@Created at: 2019-12-24 14:49:10
@Version: 
@Modify by: 
'''
from wsgiref.simple_server import make_server
from index import application

httpd = make_server('',8000,application)
print('http is running on port 8000...')

httpd.serve_forever()