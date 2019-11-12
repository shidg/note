#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import threading
import time

class MyThread(threading.Thread):
    def __init__(self,num):
        threading.Thread.__init__(self)
        self.num = num

    def run(self):
        print('Running on %s' %(self.num))
        time.sleep(3)

t1 = MyThread(1)
t2 = MyThread(2)

t1.start()
t2.start()