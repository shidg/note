#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
import socket
import time
import select

sk1 = socket.socket()
sk1.bind(('127.0.0.1',9005))
sk1.listen(3)

sk2 = socket.socket()
sk2.bind(('127.0.0.1',9006))
sk2.listen(3)

while True:
    r, w, e = select.select([sk1,sk2],[],[])
    for obj in r:
        print('----- r ------: ',r)
        conn, addr = obj.accept()
        print('conn:',conn)
        conn.sendall('hello'.encode(encoding='utf8'))
