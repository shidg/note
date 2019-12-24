#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket

sk = socket.socket()
server_addr = ('127.0.0.1',9000)
sk.connect(server_addr)

while True:
    sk.sendall('hello'.encode(encoding='utf8'))
    data = sk.recv(1024)
    print(data.decode(encoding='utf8'))