#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import socketserver

obj  = socketserver.ThreadingTCPServer()
# 类的实例化会完成两个操作
# 1. 创建对象,这里的obj
# 2. 自动查找并执行__init__() 子类没有__init_则查找父类，父类也没有则不执行，一旦找到就不再向上查找

obj.serve_forever()

