#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import time

sk = socket.socket()
ip_port = ('127.0.0.1',9000)
sk.bind(ip_port)
sk.listen(3)
sk.setblocking(False) # 设置为非阻塞性IO，运行会报错，因为nonblocking io接收不到数据就直接返回错误，不会等待

while True:
    try:
        conn,addr = sk.accept()
        data = conn.recv(1024)
        print(data.decode(encoding='utf8'))
        sk.close() # 非阻塞： 只要没数据就报错，（只要没有数据传输，连接成功，马上断开）
    except BlockingIOError as e:
        print('Error: ',e)
        time.sleep(2)