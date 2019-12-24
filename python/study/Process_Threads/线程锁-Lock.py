#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import threading

r = threading.Lock() # 线程锁

def addNum():
    global num
    #num -= 1
    r.acquire()    # 为以下代码加锁,不执行完不允许cpu切换
                   # 在多个线程操作共享数据的时候，可能因为cpu的切换导致数据不一致，这时候需要在必要的时候加锁
    tmp = num
    print('--get num: ',num)
    num = tmp-1
    r.release()    # 代码执行完成，锁解除

num = 100
thread_list = []


for i in range(100):
    t = threading.Thread(target=addNum)
    t.start()
    thread_list.append(t)

for t in thread_list:
    t.join()

print('Final num: ',num)
