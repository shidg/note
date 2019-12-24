#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

## event 不是锁，只是一个标志位，用来控制线程的阻塞还是激活 ##

# Evnet作用类似于条件变量（Condition），区别在于Event用于不访问共享资源的环境，
# evnet=threading.Evnet() 初始值为False
# evnet.isSet()  返回event的状态值
# evnet.wait()  如果event.isSet() == False 线程将阻塞
# evnet.set()  设置evnet状态值为True,所有阻塞的线程激活进入就绪状态，等待调用
# evnet.clear() 恢复evnet的状态值为False

import threading,time

class Boss(threading.Thread):
    def run(self):
        print('BOSS: 今晚加班到22：00')
        event.isSet() or event.set()
        time.sleep(5)
        print('BOSS: 可以下班了')
        time.sleep(2)
        event.isSet() or event.set()


class Worker(threading.Thread):
    def run(self):
        event.wait() # 如果event.isSet()的值是False,则阻塞，否则继续向下执行,默认值是False
        print('命苦啊……')
        time.sleep(0.25)
        event.clear()
        event.wait()
        print('Worker: OhYear!')

if __name__ == '__main__':
    event = threading.Event()
    threads = []
    for i in range(5):
        threads.append(Worker())
    threads.append(Boss())

    for t in threads:
        t.start()

    for t in threads:
        t.join()
