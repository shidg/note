#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from multiprocessing import Process, Pipe

def f(conn):
    conn.send([42, None, 'Hello'])
    conn.close()

if __name__ == '__main__':
    parent_conn, child_conn = Pipe()  # Pipe()创建一对对象
    p = Process(target=f,args=(child_conn,)) # child_conn放入子进程中
    p.start()
    print(parent_conn.recv())  # parent_conn 在主进程中
    p.join()