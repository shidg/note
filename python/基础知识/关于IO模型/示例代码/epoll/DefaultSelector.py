#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

from selectors import DefaultSelector, EVENT_READ, EVENT_WRITE
from urllib.parse import urlparse
import socket

selector = DefaultSelector()
urls = []
stop = False

class HTTPSelector(object):
    """使用select或epoll完成http请求"""

    def __init__(self, url):
        self.url = url
        self.domain = urlparse(url).netloc
        self.path = urlparse(url).path
        self.data = b""
        urls.append(self.url)
        if self.path == "":
            self.path = "/"

        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # 设置为非阻塞
        self.client.setblocking(0)

        try:
            self.client.connect((self.domain, 80))
        except BlockingIOError:
            pass

        # 注册写事件
        selector.register(self.client.fileno(), EVENT_WRITE, self.connect)


    def connect(self, key):
        """连接http服务器"""

        # 解除注册写事件, 如果未解除则出现异常
        selector.unregister(key.fd)
        request_data = """GET {0} HTTP/1.1\r\nHost: {1}\r\nConnection: close\r\n\r\n""".format(self.path, self.domain).encode("utf8")
        self.client.send(request_data)
        # 注册读事件
        selector.register(self.client.fileno(), EVENT_READ, self.read)

    def read(self, key):
        """接收http响应"""
        data = b""
        # 这里没有使用循环读取响应数据，原因在于select仅处理socket文件描述符状态发生变化
        # 的socket实例，此外，该程序只有一个client实例，所以其接收到的数据是属于整个HTML数据的一部分，
        # 就需要数据累加
        # while 1:
        #     try:
        #         cur_data = self.client.recv(1024)
        #     except BlockingIOError as e:
        #         pass
        #     else:
        #         if cur_data:
        #             data += cur_data
        #         else:
        #             break
        cur_data = self.client.recv(1024)
        if cur_data:
            self.data += cur_data
        else:
            selector.unregister(key.fd)
            data = data.decode("utf8")
            print(data)
            #html_data = data.split("\r\n\r\n")[1]
            html_data = data
            print(html_data)
            urls.remove(self.url)
            if not urls:
                global stop
                stop = True
            self.client.close()

def loop():
    # 1.selector本身不支持register模式
    # 需要手动开启事件循环，需要由程序员自己来完成
    while not stop:
        ready = selector.select()
        for key, mask in ready:
            call_back = key.data
            call_back(key)

if __name__ == '__main__':
    test = HTTPSelector("https://www.baidu.com")
    loop()
 