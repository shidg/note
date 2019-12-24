#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

## 递归锁  可重用锁 ##

import threading,time

################### 死锁的例子 ######################
# lockA = threading.Lock()
# lockB = threading.Lock()

lock = threading.RLock()

class MyThread(threading.Thread):
    def doA(self):
        lock.acquire()
        #lockA.acquire()
        print(self.name,'got lockA',time.ctime())
        time.sleep(3)  # 线程在sleep的时候cpu会切换到其他线程，但是锁并不释放，所以即使其他线程分配到了cpu
                       # 确因为拿不到锁而无法执行
        lock.acquire()
        #lockB.acquire()
        print(self.name,'got lockB',time.ctime())
        lock.release()
        lock.release()
        #lockB.release()
        #lockA.release()

    def doB(self):
        lock.acquire()
        #lockB.acquire()
        print(self.name,'got lockB',time.ctime())
        time.sleep(2)
        lock.acquire()
        #lockA.acquire()
        print(self.name,'got lockA',time.ctime())
        lock.release()
        lock.release()
        #lockA.release()
        #lockB.release()

    def run(self):
        self.doA()
        self.doB()

if __name__ == '__main__':
    threads = []
    for i in range(5):
        threads.append(MyThread())

    for t in threads:
        t.start()
###  一个线程启动后，在sleep的时候cpu切换到另一个线程，但是会出现各自占有一个锁，都需要等待对方释放锁才能继续执行 ##
###  使用一个递归锁来代替两把锁，lock = threading.RLock() ###






