#!/usr/bin/env python
# -*- coding: utf-8 -*-#
'''
@Author: --- shidg ---
@Created at: 2019-12-24 14:46:48
@Version: 
@Modify by: 
'''

def application(environ,start_response):
    start_response('200 OK',[('Content-Type','text/html')])
    body = '<h1>Hello, %s!</h1>'%(environ['PATH_INFO'][1:] or 'web')
    return [body.encode('utf-8')]