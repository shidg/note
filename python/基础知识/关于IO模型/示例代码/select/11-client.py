#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket

sk = socket.socket()
server_addr = ('127.0.0.1',9005)
#server_addr = ('127.0.0.1',9006)
sk.connect(server_addr)

while True:
    data = sk.recv(1024)
    print(data.decode(encoding='utf8'))
    inp = input('>>>')
    sk.sendall(inp.encode(encoding='utf8'))