#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import time
sk = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

while True:
    sk.connect(('127.0.0.1',8877))
    print('hello')
    sk.sendall(bytes('hello',encoding='utf8'))
    time.sleep(2)
    break