#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process,Manager

def f(d,s,n):
    d[1] = n     # 因为是共享数据，所以是覆盖操作
                 # 无论多少个子线程来操作d这个字典，最终还是只有三个键值对
    d[2] = 2
    d[0.25] = None
    s.append(n)
    print('list s: ',s)

if __name__ == '__main__':
    with Manager() as manager:
        d = manager.dict()  # 通过manage对象创建一个空字典
        s = manager.list(range(5))  #通过manager对象创建一个列表
        p_list = []

        for i in range(10):
            p = Process(target=f, args=(d,s,i))  # 10个子进程操作共享数据d、s
            p.start()
            p_list.append(p)

        for p in p_list:
            p.join()

        print(d)  # 因为是共享数据，所以是覆盖操作
                  # 无论多少个子线程来操作d这个字典，最终还是只有三个键值对
        print(s)

