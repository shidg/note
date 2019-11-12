#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import time
sk = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
sk.connect(('127.0.0.1', 8801))

while True:
    inp = input('>>>')
    sk.sendall(bytes(inp,encoding='utf8'))
    data = sk.recv(1024)
    print(data.decode(encoding='utf8'))
