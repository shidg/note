#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket

server_addr = ('127.0.0.1',9091)
sk = socket.socket()
sk.connect(server_addr)
while True:
    inp = input('>>>')
    sk.sendall(bytes(inp,'utf8'))
    if inp == 'exit':
        break
    server_response = sk.recv(1024)
    print(str(server_response,'utf8'))

 