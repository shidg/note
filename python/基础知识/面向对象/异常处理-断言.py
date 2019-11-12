#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

print(123)
assert 1 == 2 # assert后加条件，条件满足则继续向下执行，不满足则报错退出。强制服从，否则报错
print(456)

## 一般用于硬性要求，必须满足条件才能运行，否则不予执行。这种类型的错误信息不需要捕获处理，直接报错即可
