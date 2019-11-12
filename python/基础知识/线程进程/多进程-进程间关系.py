#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process
import os
import time

class MyProcess(Process):
    def info(self,title):
        print(title)
        print('module name: ', __name__)
        print('parent process: ', os.getppid())
        print('process id: ', os.getpid())

    def f(self,name):
        self.info('\033[31;1mfunction f\033[0m')
        print('Hello', name)

    def run(self):
        self.f('tom')

if __name__ == '__main__':
    MyProcess().info('\033[32;1mmain process\033[0m')
    time.sleep(5)
    for i in range(6):
        p = MyProcess() # 模块本身运行起来就是一个进程
                        # 该模块又创建了若干子进程，所以该模块是其所有子进程的父进程
        p.start()
        p.join()
    print('End')