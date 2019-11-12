#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import select

sk = socket.socket()
sk.bind(('127.0.0.1',8877))
sk.listen(5)

sk1 = socket.socket()
sk1.bind(('127.0.0.1',8878))
sk1.listen(5)

while True:
    r, w, e = select.select([sk, sk1], [], [], 5)
    for i in r:
        #conn, addr = i.accept() # 水平触发，边缘触发
        print('hello')
    print('>>', r)
