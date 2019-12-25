#!/usr/bin/env python
# -*- coding: utf-8 -*-#
'''
@Author: --- shidg ---
@Created at: 2019-12-24 17:38:09
@Version: 
@Modify by: 
'''

def consumer():
    r = ''
    while True:
        n = yield r
        if not n:
            return
        print('[CONSUMER] Consuming %s...' %n)
        r = '200 OK'

def produce(c):
    c.send(None)
    n = 0
    while n < 5:
        n = n + 1
        print('[PRODUCER] Producing %s...' %n)
        r = c.send(n)
        print('[PRODUCER] Consumer return %s' %r)
    c.close()

c = consumer()
produce(c)