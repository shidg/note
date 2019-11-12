#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import pymysql
import importlib

# 视图
# 视图中的数据只能查询，不能删除或修改
# 执行时才获取数据

# 在mysql中创建视图
# create view v1 as
# select student_id,sname from score left join student on score.student_id = student.sid;

# pymysql调用视图

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

#cursor.execute('select a.student_id,a.num,b.tname from score a  left join v2 b on a.course_id = b.cid ')
#result = cursor.fetchall()
#print(result)
#conn.commit()
#cursor.close()
#conn.close()


# mysql中创建存储过程
#delimiter //    # 修改mysql的终止符为 "//"，防止存储过程不能完整提交
                # 因为存储过程可能有多个sql语句，在创建的过程中单条的sql语句不应该被执行
#create procedure p1()
#BEGIN
#    select * from class;
#    select * from teacher;
#END //

#delimiter ; # 存储过程提交完成后恢复终止符

# pymysql 调用存储过程

#rew = cursor.callproc('p1')
#result = cursor.fetchall()
#print(result)

#delimiter //
#create procedure p1(
#    in i1 int,
#    in i2 int,
#    inout i3 int,
#    out r1 int
#)
#BEGIN
#    DECLARE temp1 int;
#    DECLARE temp2 int default 0;
#    set temp1 = 1;
#    set r1 = i1 + i2 + temp1 + temp2;
#    set i3 = i3 + 100;
#END //
#delimiter ;


#cursor.callproc('p2', args=(1,2,4,5))  # 调用存储过程的时候，存储过程中的select或其他执行语句已经执行完毕，结果集已经返回，
                                       # 其他返回值（自定义的变量，传递的参数）保存进MySQL变量中,但是并不会返回。
#result1 = cursor.fetchall()   # 第一次fetchall，获取到的只有sql语句的结果集，并没有返回值
#print(result1)
#r2 = cursor.execute('select @_p2_0,@_p2_1,@_p2_2,@_p2_3') # 该语句用来获取存储过程中的返回值（自定义的变量）
#result2 = cursor.fetchall() # 再次执行fetchall，拿到返回值
#print(result2)

# 通过Pymysql调用存储过程其实做了两件事
# 1. 返回结果集，并将返回值保存在MySQL
# 2. 如果需要返回值，使用execute(select)去获取

# 使用存储过程动态执行SQL语句

#delimiter //
#DROP procedure IF EXISTS prod_sql//
#
#CREATE procedure prod_sql()
#BEGIN
#declare p1 int;
#set p1 = 11;
#set @p1 = p1;
#PREPARE prod FROM 'select * from student where sid >?';
#EXECUTE prod USING @p1;
#DEALLOCATE prepare prod;
#END
#
#delimiter;


#delimiter //
#DROP procedure IF EXISTS prod_sql//
#
#CREATE procedure prod_sql(
# in i1 varchar(255),
# in i2 int
# )
#BEGIN
#set @sql =  i1;
#set @p1 = i2;
#PREPARE prod FROM @sql;
#EXECUTE prod USING @p1;
#DEALLOCATE prepare prod;
#END
#
#delimiter;

#cursor.callproc('prod_sql',)
cursor.callproc('prod_sql_1', args = ('select * from student where sid>?',10))
result = cursor.fetchall()
print(result)


