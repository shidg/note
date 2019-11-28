#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


import pymysql
import importlib

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

delimiter //
create trigger tri_1 before insert on student for each row # 对student表执行插入操作之前自动执行以下的SQL语句
begin
    IF NEW.sname == '西门庆庆' THEN   # NEW ,内部变量，封装了insert语句中的字段值，视为用户传入的参数
        insert into class (caption) values ('男',2,'西门吹雨');
    ENDIF
end
delimiter ;

delimiter //
create trigger tri_1 before delete on student for each row # 对student表执行删除操作之前自动执行以下的SQL语句
begin
    IF OLD.sname == '西门庆庆' THEN   # OLD ,内部变量，封装了delete语句将要删除的字段的值
        insert into class (caption) values ('男',2,'西门吹雨');
    ENDIF
end
delimiter ;