#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socketserver

class MyServer(socketserver.BaseRequestHandler):
    def handle(self):
        while True:
            print('服务端已启动')
            conn = self.request
            client_addr = self.client_address
            print('连接已建立，请求来自',client_addr)
            while True:
                client_data = conn.recv(1024)
                print(str(client_data,'utf8'))
                conn.sendall(client_data)
            conn.close()

if __name__ == '__main__':
    server = socketserver.ThreadingTCPServer(('127.0.0.1',9091),MyServer)
    #server.serve_forever()
    server.handle_request()


# 创建一个socketserver.BaseRequestHandler类的子类，并且改写父类的handle方法

# 使用socketserver.ThreadingTCPServer类实例化一个对象，并且将ip & port 和上一步中的自定义类做为参数传入。

# 调用第二步中实例化出的对象的server_forever方法，python按照已经封装好的步骤去逐步执行，最终会调用到handle方法。


 