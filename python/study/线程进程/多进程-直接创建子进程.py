#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process
import time

def f(name):
    time.sleep(1)
    print('Hello',name,time.ctime())

if __name__ == '__main__':
    p_list = []
    for i in range(3):
        p = Process(target=f,args=('tom',))
        p_list.append(p)
        p.start()

    for p in p_list:
        p.join()

    print('End')