#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 分别监控"新建连接"和"已建立连接"

# 以下两种情况都要监听到，并作出相应处理：
# 有客户端发起新连接、已建立的连接发送了数据

# 如果是新建连接，则执行accept，得到conn(四元组)，添加到监听列表
# 如果是已建立连接在发送数据，则直接recv或send



import socket
import select
import time

sk=socket.socket()
sk.bind(("127.0.0.1",8801))
sk.listen(5)
inputs=[sk,]   # 建立一个列表，暂时只包含sk一个对象，这个列表会被select监听
               # 这个列表里最终存放的是sk和所有已经建立的连接（socket四元组）
               # 监听sk是为了发现新的客户端发起的新连接，监听四元组是为了发现已建立连接发来的数据。

while True:
    r,w,e=select.select(inputs,[],[],5)  # select监听
    print('len of r>>>',len(r))  # r包含的是监控列表中有变动的元素(新建连接、已建连接发送数据)，
                                 # 所以监控列表的长度一旦增加就不会再减少，r的长度在处理完成后就变为0

    for obj in r:
        if obj==sk:
            conn,add=obj.accept()
            print(conn)
            inputs.append(conn)  # 如果是新建连接，则将该连接的四元组添加到监听列表
        else:
            data_byte=obj.recv(1024)
            print(str(data_byte,'utf8'))
            inp=input('回答%s号客户>>>'%inputs.index(obj))
            obj.sendall(bytes(inp,'utf8'))

    print('>>',r)
    print('len of inputs >>>',len(inputs))
