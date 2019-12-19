#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import ssl
ssl._create_default_https_context = ssl._create_unverified_context  #解决ssl证书错误的问题

import gevent
from urllib.request import urlopen

def f(url):
    print('Get: %s'%url)
    resp = urlopen(url)
    data = resp.read()
    print('%d bytes received from %s.' %(len(data),url))

gevent.joinall([
    gevent.spawn(f, 'https://baidu.com/'),
    gevent.spawn(f, 'https://www.sohu.com/'),
    gevent.spawn(f, 'https://www.github.com/'),
])

