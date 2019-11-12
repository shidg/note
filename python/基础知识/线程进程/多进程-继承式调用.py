#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process
import time

class MyProcess(Process):
    def __init__(self):
        super().__init__()

    def run(self):
        time.sleep(1)
        print('Hello',self.name,time.ctime())


if __name__ == '__main__':
    p_list = []
    for i in range(3):
        p = MyProcess()
        p_list.append(p)
        p.start()
    for p in p_list:
        p.join()


