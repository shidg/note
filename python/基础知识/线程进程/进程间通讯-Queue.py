#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process,Queue

class MyProcess(Process):
    def f(self,q,n):
        q.put([42, n, 'hello'])
        print('sub q id: ',id(q))
    def run(self):
        self.f(q,i)

if __name__ == '__main__':
    q = Queue()
    print('main q id: ',id(q))
    p_list = []
    for i in range(3):
        #p = Process(target=f, args=(q,i))
        p = MyProcess() # 父进程创建的对象q,在这里传递以函数参数的方式传递给子进程
        p_list.append(p)
        p.start()

    print(q.get())  # 在主进程里去get子进程插入队列的内容
    print(q.get())
    print(q.get())

    for p in p_list:
        p.join()

    print('Main process end')
