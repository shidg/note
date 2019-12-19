#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import os

sk = socket.socket()
server_addr = ('127.0.0.1',9090)
sk.connect(server_addr)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

while True:
    inp = input('>>>')
    cmd, path = inp.split('|')

    full_path = os.path.join(BASE_DIR,path)
    file_name = os.path.basename(full_path)
    file_size = os.stat(full_path).st_size

    #action_info = 'post|%s|%s'%(file_name,file_size)
    action_info = 'post|{}|{}'.format(file_name,file_size)

    sk.sendall(bytes(action_info,'utf8'))

    with open(full_path,'rb') as f:
        has_send = 0
        while has_send != file_size:
            data = f.read(1024)
            sk.sendall(data)
            has_send += len(data)

        print('上传成功')





