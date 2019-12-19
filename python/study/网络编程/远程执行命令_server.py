#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket
import subprocess

sk = socket.socket()
address = ('127.0.0.1',9090)
sk.bind(address)
sk.listen(3)
conn, addr = sk.accept()
while True:
    data = conn.recv(1024)

    obj = subprocess.Popen(str(data,'utf8'),shell=True,stdout=subprocess.PIPE) #recv接收到的是bytes类型数据
                                                                           #需要转换为str后传给Popen
    cmd_result = obj.stdout.read() # 得到的结果是bytes类型的数据，可以直接send
    result_length = bytes(str(len(cmd_result)),'utf8')
    conn.sendall(result_length)
    conn.recv(1024) # 连续send的时候有可能发生粘包现象（第一次发送的数据量很小，可能会连同第二次的数据一起发送）
                    #使用一个recv来隔断相邻的send可以消除粘包现象
    conn.sendall(cmd_result)

