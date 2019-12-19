#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import os
sk = socket.socket()
addr = ('127.0.0.1',9090)
sk.bind(addr)
sk.listen(3)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
save_path = os.path.join(BASE_DIR,'images')
while True:
    conn, addr = sk.accept()
    while True:
        action_info = conn.recv(1024)
        cmd, file_name, file_size = str(action_info,'utf8').split('|')
        file_size = int(file_size)
        full_path = os.path.join(save_path, file_name)


        with open(full_path,'wb') as f:
            has_recv = 0
            while has_recv != file_size:
                data = conn.recv(1024)
                f.write(data)
                has_recv += len(data)

        print('文件上传成功')
