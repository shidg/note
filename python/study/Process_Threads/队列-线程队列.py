#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
## 队列是一种数据结构，自带安全锁，可以保证线程是安全的，不会出现两个线程同时操作队列中同一个数据的情况 ##

import threading,queue
from time import sleep
from random import randint

class Production(threading.Thread):
    def run(self):
        while True:
            r = randint(0,100)
            q.put(r)
            print('生产出来%s号包子'%r)
            sleep(5)

class Proces(threading.Thread):
    def run(self):
        while True:
            re = q.get()
            print('吃掉%s号包子'%re)

if __name__ == '__main__':
    q = queue.Queue(10)
    threads = [Production(),Production(),Production(),Proces()]

    for t in threads:
        t.start()


#d = queue.Queue(3)  # 队列长度为3,先进先出队列
##d = queue.LifoQueue() # 后进先出队列
##d = queue.PriorityQueue() # 优先级队列模式
#d.put('a')
#d.put('b')
#d.put('c')
#d.get() # 先取到a, 先进先出原则 FIFO（默认原则，可以设置为后进先出 LIFO 或自定义优先级）
#d.get()


