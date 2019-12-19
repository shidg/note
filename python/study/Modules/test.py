#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

def consumer(name):
    print('%s 准备抢包子了！'%(name))
    while True:
        baozi = yield
        print('包子 %s上桌了，被%s吃掉了'%(baozi,name))

while True:
    consumer('tom')

