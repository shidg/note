#!/usr/bin/python
# -*- coding: utf-8 -*- #
'''
author: -- shidegang --
Created Time: 2019-12-29 21:32:11
'''
import redis
from flask import Flask
app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return "Hello World! I have been seen {} times.\n".format(count)
