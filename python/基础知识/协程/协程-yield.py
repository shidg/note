#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import time
import queue

def consumer(name):
    print('Ready to eat baozi……')
    while True:
        new_baozi = yield
        print('[%s] is eating baozi %s'%(name,new_baozi))

def producer():
    con.__next__()
    #next(con)
    con2.__next__()
    #next(con2)
    n = 0
    while n < 5:
        print('\033[32;1m[producer]\033[0m is making baozi %s'%n)
        time.sleep(2)
        con.send(n)
        con2.send(n)
        n += 1

if __name__ == '__main__':
    con = consumer('c1')
    con2 = consumer('c2')
    producer()
