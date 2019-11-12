#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import threading
from time import sleep,ctime

def music(a):
    for i in range(2):
        print('Begin to listen to %s. %s' %(a,ctime()))
        sleep(2)
        print('End listen %s' %ctime())

def video(a):
    for i in range(2):
        print('Begin to watch at the %s %s' %(a,ctime()))
        sleep(3)
        print('End watch %s' %ctime())

threads = []

t1 = threading.Thread(target=music,args=('七里香',))
threads.append(t1)

t2 = threading.Thread(target=video,args=('阿甘正传',))
threads.append(t2)

if __name__ == '__main__':

    t1.setDaemon(True) # 对一个线程设置了setDaemon,则主进程在执行完成之后不会等待该线程执行，直接退出，守护线程也跟着一起结束
                       # setDaemon必须在start之前设置
    for thread in threads:
        thread.start()

    print('############# All over ############## %s' %ctime())