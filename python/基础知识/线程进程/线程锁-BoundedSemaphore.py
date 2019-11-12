#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 信号量 #

import threading,time

class MyThread(threading.Thread):
    def run(self):
        if semaphore.acquire():
            print(self.name)
            time.sleep(2)
            semaphore.release()

if __name__ == '__main__':
    semaphore = threading.BoundedSemaphore(5)  # 最大允许5个线程并发执行
                                               # 并非是真正的并行，PYTHON中没有真正的并行，因为GIL的存在）
    #semaphore = threading.Semaphore(5)
    threads = []
    for i in range(100):
        threads.append(MyThread())

    for t in threads:
        t.start()
