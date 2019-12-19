#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# python -m pip install requests
# python -m pip install gevent

from gevent import monkey; monkey.patch_all()
import gevent
import requests
from datetime import datetime


def f(url):
    print('time: %s, GET: %s' %(datetime.now(),url))
    resp = requests.get(url)
    print('time: %s, %d bytes received from %s.' %(datetime.now(), len(resp.text), url))

gevent.joinall([
        gevent.spawn(f, 'https://www.python.org/'),
        gevent.spawn(f, 'https://www.yahoo.com/'),
        gevent.spawn(f, 'https://github.com/'),
])


