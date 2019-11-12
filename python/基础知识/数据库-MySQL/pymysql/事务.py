#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


# 事务写在存储过程中，用来将多个语句做为一个原子操作来执行，只要其中一个语句没有成功则回滚到原来的状态

# 定义一个存储过程，其中包含一个事务
#delimiter //
#CREATE PROCEDURE p13(
#    OUT res TINYINT
#)
#BEGIN
#    DECLARE exit HANDLER for SQLEXCEPTION    # 异常处理。定义SQL执行出错的时候如何处理
#    BEGIN
#        -- ERRORS
#        SET res = 1;
#        ROLLBACK;
#    END;
#
#    DECLARE EXIT HANDLER FOR SQLWARNING      # 异常处理，定义SQL执行出现警告的时候如何处理
#    BEGIN
#        -- WARNINGS
#        SET res = 2;
#        ROLLBACK;
#    END;
#
#    START TRANSACTION;  # 定义一个事务
#    DELETE from class WHERE cid = 8;     # 事务内容
#    INSERT INTO teacher(tname) VALUES('夏侯商元');  # 事务内容
#    COMMIT;  # 事务结束，提交
#
#    -- success
#    set res = 0;
#END //
#delimiter ;


import pymysql
import time
import random
import string

mysql_connect_dict = {
    'host':'127.0.0.1',
    'port':3306,
    'user':'root',
    'passwd':'admin',
    'db':'test',
    'charset':'utf8'
}

conn = pymysql.connect(**mysql_connect_dict)
cursor = conn.cursor(pymysql.cursors.DictCursor)

#cursor.callproc('p13', args=(0,))
#result1 = cursor.fetchall()
#print(result1)
#r2 = cursor.execute('select @_p13_0,@_p13_1,@_p13_2,@_p13_3')
#result = cursor.fetchall()
#print(result)

num = 0
while num < 10:
    name = 'tony' + str(num)
    email = 'tony00' + str(num) + 'qq.com'
    ctime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
    str1 = ''
    cursor.execute('insert into t11 (name,email,ctime,random) values (%s,%s,%s,%s)',
                    (
                        name,
                        email,
                        time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())),
                        str1.join(random.sample(string.ascii_letters + string.digits, 20))
                     )
                   )
    print('insert success: ',num)
    num += 1


conn.commit()
cursor.close()
conn.close()
