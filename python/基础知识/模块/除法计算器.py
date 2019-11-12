#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import re

# 定义了几种匹配模式
two_module = re.compile('\d+\.?\d*/\d+\.?\d*')

int_type_module = re.compile(
    '^\d+\.0+$'
)

float_type_module = re.compile(
    '^\d+\.\d+$'
)

# 过滤非法字符
def str_filter(string):
    flag = True
    if re.search('[a-pr-zA-PR-Z]',string):
        flag = False
    if re.search('\d\.\d+\.+',string):
        flag = False
    if re.match('^[.*]+',string): # 以点开头
        flag = False
    if re.search('\.+\*',string):
        flag = False
    if re.search('\*\.',string):
        flag = False
    if re.search('\d\.\.+',string):
        flag = False
    if re.search('\*\*+',string):
        flag = False
    return flag

# 格式化 （处理整形、浮点型及类似4.0000这样多余的0）
def check_type(x,y):
    if int_type_module.match(x):
        x = re.sub('\.0+', '', x)
        x = float(x)
    elif float_type_module.match(x):
        x = float(x)
    else:
        x = float(x)
    if int_type_module.match(y):
        y = re.sub('\.0+', '', y)
        y = float(y)
    elif float_type_module.match(y):
        y = float(y)
    else:
        y = float(y)
    return x,y

# 将a*b*c*d逐步替换为ab*c*d ---> abc*d ---> abcd,最终返回的是一个abcd相乘得到的积，(字符串)

def multiplication(string):
    string_full = string
    while two_module.search(string):
        str1 = two_module.search(string).group()
        x,y = re.split('/',str1)
        x,y = check_type(x,y)
        str2 = x/y
        string = two_module.sub(str(str2),string,1)
    else:
        result = string # 这里得到的其实是一个字符串，可以使用int()转换为整形
    print('你输入的算式是： {0}\n计算结果是: {1}'.format(string_full,result))
    #print('你输入的算式是： {}\n计算结果是: {}'.format(string_full,result))
    #print('你输入的算式是： {a}\n计算结果是: {b}'.format(a=string_full,b=result))

while True:
    source = input("乘法运算器,输入q退出:\n")
    source = re.sub('\s+','',source)
    if source == 'q':
        break
    if str_filter(source):
        multiplication(source)
    else:
        print('非法字符串')
        break
