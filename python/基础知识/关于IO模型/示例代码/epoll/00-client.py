#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socket, sys

messages = [b'This is the message. ',
            b'It will be sent ',
            b'in parts.',
            ]
server_address = ('localhost', 9999)

# 创建100个 TCP/IP socket实例
socks = [socket.socket(socket.AF_INET, socket.SOCK_STREAM) for i in range(100)]

# 连接服务端
print('connecting to %s port %s' % server_address)
for s in socks:
    s.connect(server_address)

for message in messages:

    # 发送消息至服务端
    for s in socks:
        print('%s: sending "%s"' % (s.getsockname(), message))
        s.send(message)

    # 从服务端接收消息
    for s in socks:
        data = s.recv(1024)
        print('%s: received "%s"' % (s.getsockname(), data))
        if not data:
            print(sys.stderr, 'closing socket', s.getsockname())
 