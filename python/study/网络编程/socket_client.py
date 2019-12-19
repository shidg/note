#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
sk = socket.socket()

serveraddr = ('127.0.0.1',9090)
sk.connect(serveraddr)

while True:
    inp = input('>>>')
    if inp == 'exit':
        break
    sk.send(bytes(inp,'utf8'))
    data = sk.recv(1024)
    print(str(data,'utf8'))

sk.close()
#data = sk.recv(1024)
#print(str(data,'utf8'))