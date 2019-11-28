#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import  pymysql

mysql_connect_dict = {
    'host':'127.0.0.1',
    'port':3306,
    'user':'root',
    'passwd':'admin',
    'db':'test',
    'charset':'utf8'
}

conn = pymysql.connect(**mysql_connect_dict)  # 各行数据以字典形式存储在一个列表中
cursor = conn.cursor(pymysql.cursors.DictCursor)



current_last_nid = 0
current_first_nid = 0

while True:
    inp = input('请选择 1. 上一页  2. 下一页\n')
    if inp == '2':
        is_next = True
        cursor.execute('select * from t11 where nid > %s limit 10', current_last_nid)
        result = cursor.fetchall()
        print(result)
        for i in result:
            print(i)
            current_last_nid = result[-1]['nid']
            current_first_nid = result[0]['nid']
        print(current_first_nid, current_last_nid)
    else:
        is_next = False
        cursor.execute('select * from t11 where nid < %s order by nid desc limit 10',current_first_nid)
        result = cursor.fetchall()
        for i in result.__reversed__():
            print(i)
            current_first_nid = result[-1]['nid']
            current_last_nid = result[0]['nid']
        print(current_first_nid,current_last_nid)





