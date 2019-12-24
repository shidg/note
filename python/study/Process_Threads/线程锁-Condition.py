#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

##  条件变量  ##
##  除了具备锁的功能，还可完成进程间通信  ####
##  除了RLock()、 Lock()方法，还提供了wait()  notify()  notifyAll()方法  ##

## 应用场景 ##
# 某些线程需要满足一定条件之后才能继续执行（比如收到其他线程发来的特定信号），
# threading.Condition(Lock/RLock) 参数是可选项，默认自动传入RLock，创建一个RLock锁
# wait()  条件不满足时调用，线程释放锁并进入等待
# notify() 条件创造后调用，通知等待池内激活一个线程
# notifyAll() 条件创造后调用，通知等待池激活所有线程

import threading,time
from random import randint


class Producer(threading.Thread):
    def run(self):
        global L
        while True:
            val = randint(0,100)
            print('生产者',self.name,':Append' + str(val),L)
            if lock_con.acquire():
                L.append(val)
                lock_con.notify()
                lock_con.release()
            time.sleep(3)

class Consumer(threading.Thread):
    def run(self):
        global L
        while True:
            lock_con.acquire()
            if len(L) == 0:
                print('目标为空，无法操作')
                lock_con.wait() # 调用wait()的时候会自动释放锁，无需手动release()
            print('消费者',self.name,'Delete' + str(L[0]),L)
            del L[0]
            lock_con.release()
            time.sleep(0.25)

if __name__ == '__main__':
    L = []
    lock_con = threading.Condition()
    threads = []
    for i in range(5):
        threads.append(Producer())

    threads.append(Consumer())

    for t in threads:
        t.start()
    #for t in threads:
    #    t.join()



