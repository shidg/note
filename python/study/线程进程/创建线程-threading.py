#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import threading
from time import sleep,ctime

#def foo(x):
#    print('foo: {}'.format(x))
#    time.sleep(1)
#    print('foo end')
#
#def bar(y):
#    print('bar: {}'.format(y))
#    time.sleep(2)
#    print('bar end')
#
#
#t1 = threading.Thread(target=foo,args=(1,))  # 创建线程
#t2 = threading.Thread(target=bar,args=(2,))  # 创建线程
#
#t1.start()  # 线程启动
#t2.start()  # 线程启动
#print('…… in the main ……') # 主进程内的动作

# 主进程（模块本身）的命令和主进程创建的子线程并发执行。
# 不再是自上而下顺序执行，必须前一个函数执行完之后下一个函数才得以执行


# 由于GIL(cpython解释器的全局解释器锁)的存在python在同一时间只允许一个线程运行，所以在python并不能很好地利用多核cpu

# 对于I/O密集型任务，可以使用python多线程
# 对于计算密集型任务，建议使用其他语言或者python的多进程


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
    for thread in threads:
        thread.start()

    thread.join()  # for 循环已经结束，此时的thread取的是for循环中最后一次赋值，在这里其实相当于t2.join()
    print('############# All over ############## %s' %ctime())
