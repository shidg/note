#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

## socket 是应用层和传输层之间的一个抽象层，将复杂的TCP/IP协议抽象为几个接口供应用层调用。

import socket

#socket.socket(family=AF_INET,type=SOCK_STREAM)
# family=AF_INET  服务器间通信，默认值
# family=AF_INET6  ipv6
# family=AF_UNIX  不同进程间通信

# type=SOCK_STREAM  TCP通信，默认值
# type=SOCK_DGRAM   UDP通信

sk = socket.socket() #使用默认参数实例化一个socket对象
addr = ('127.0.0.1',9090)
sk.bind(addr)

sk.listen(3) # 允许的排队人数

while True:
    conn, addr = sk.accept()
    while True:
        try:
            data = conn.recv(1024)
        except ConnectionResetError as e: # 客户端强行关闭连接
            break
        if not data:
            break
        print(str(data,'utf8'))
        inp = input('>>>')
        conn.send(bytes(inp,'utf8'))
        #conn.send(bytes(inp,'utf8')) # send的内容必须是bytes类型


