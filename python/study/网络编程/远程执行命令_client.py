#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
import socket

sk = socket.socket()
address = ('127.0.0.1',9090)
sk.connect(address)

while True:
    inp = input('>>>')
    sk.send(bytes(inp,'utf8'))

    result_length = sk.recv(1024)
    sk.send(bytes('ok','utf8'))

    data = bytes()
    while len(data) != int(str(result_length,'utf8')):
        res = sk.recv(1024)
        data += res

    print(str(data,'utf8'))