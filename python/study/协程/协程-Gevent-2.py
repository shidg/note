#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import gevent

def foo():
    print('Running in foo')
    gevent.sleep(0)  # 模拟IO阻塞
    print('Explict context switch to foo again')

def bar():
    print('Explict context to bar')
    gevent.sleep(0)  # 模拟IO阻塞
    print('Explict context switch back to bar')

gevent.joinall(
    [gevent.spawn(foo),gevent.spawn(bar)]
)
