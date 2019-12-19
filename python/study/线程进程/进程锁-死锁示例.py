#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import threading
import time

lock_a = threading.Lock()
lock_b = threading.Lock()

class MyThread(threading.Thread):
    def func1(self):
        global lock_a
        global lock_b

        lock_a.acquire()
        print(self.name,'got lock_a')
        time.sleep(1)
        lock_b.acquire()
        time.sleep(1)
        lock_b.release()
        lock_a.release()


    def func2(self):
        global lock_a
        global lock_b

        lock_b.acquire()
        print(self.name,'got lock_b')
        time.sleep(1)
        lock_a.acquire()
        time.sleep(1)
        lock_a.release()
        lock_b.release()


    def run(self):
        self.func1()
        self.func2()
thread1 = MyThread()
thread2 = MyThread()

thread1.start()
thread2.start()
thread1.join()
thread2.join()
print("program finished")

###  一个线程启动后，在sleep的时候cpu切换到另一个线程，但是会出现各自占有一个锁，都需要等待对方释放锁才能继续执行 ##
