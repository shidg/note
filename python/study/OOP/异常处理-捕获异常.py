#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

while True:
    try:
        inp = input('请输入序号： ')
        inp = int(inp)
    except IndexError as inderr:  # 出错按照顺序执行except
        print('IndexError: ',inderr)
    except ValueError as valerr:
        print('ValueError: ', valerr)
    except Exception as e:  ## Exception 捕获所有的错误
        inp = 1
    else: ## 不出错执行
        print(inp)
    finally:  # 无论出错与否都会执行
        print('some thing')

# IndexError  ValueError等细分错误，是Exception的子类，捕获特定的错误

#### 按照错误类型进行不同的处理,可以通过使用多个except来实现 ####