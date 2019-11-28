#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


import pymysql

# 创建连接
mysql_connect_dict = {
    'host':'127.0.0.1',
    'port':32768,
    'user':'root',
    'passwd':'admincp',
    'db':'mysql',
    'charset':'utf8'
}
#conn = pymysql.connect(host = '127.0.0.1', port = 3306, user = 'root', passwd = 'admin', db = 'test',charset = 'utf8')
conn = pymysql.connect(**mysql_connect_dict)

# 创建游标
#cursor = conn.cursor() # 游标默认将返回值保存为元组，可以修改为字典
cursor = conn.cursor(pymysql.cursors.DictCursor) # 这样设置之后，返回的数据用字典存储

# 执行sql，返回值为受影响行数
#effect_row = cursor.execute('insert into student (gender,class_id,sname) values ("男",2,"小浪蹄子")')

# 参数传递
# 严禁使用字符串拼接的方式拼接sql语句
# inp  = input('>>>')
# cursor.execute('insert into class (caption) values(%s)',inp) # 变量替换的时候，pymysql自动添加单引号

# 传递多个参数(多个字段)
# cursor.execute('insert into student (gender,class_id,sname) values (%s,%s,%s)',('女',2,'鸭蛋'))

# 一次性插入多条数据
#I = [
#('女',2,'鸭蛋1'),
#('女',1,'鸭蛋2'),
#('女',2,'鸭蛋3'),
#('女',1,'鸭蛋4'),
#]
#cursor.executemany('insert into student (gender,class_id,sname) values (%s,%s,%s)',I)
# executemany  循环插入多条数据

# update
# cursor.execute('update student set sname = %s where sid=%s',('马达狗',2))

# delete

# cursor.execute('delete from class where caption = %s',('111',))

# select # select 不需要commit

r = cursor.execute('select * from user')
#print(r)  # execute的返回值是受影响的行数，并不是查询结果
result = cursor.fetchall() # 返回所有查询结果
##result = cursor.fetchone() # 返回第一条结果
#result = cursor.fetchmany(3) # 返回三条结果
for i in result:
    print(i['User'])
print(result)

# 获取新创建数据的自增ID
# new_rowid = cursor.lastrowid
#cursor.execute('insert into teacher (tname) values (%s)',('诸葛山珍',))
#new_rowid = cursor.lastrowid
#print(new_rowid)


# 提交
#conn.commit()

# 关闭游标
cursor.close()

# 关闭连接
conn.close()


#import random
#import string

#rand = ''.join(random.sample(string.ascii_letters + string.digits, 20))
#print('rand: ',rand)
