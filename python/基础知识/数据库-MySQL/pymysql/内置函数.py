#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

char_length(str) # 字符长度

concat(str1,str2)  # 字符拼接,有任何一个为null,则结果为null

concat_ws(separator,str1,str2) # 字符拼接，自定义连接符。不会忽略任何空字符串，但是会忽略null

conv(N，from_base,to_base) # 进制转换

select conv('a',16,2) # 16进制转2进制

format(x,d) # 将数字x格式转换为#,###,###.##格式（每三位用逗号分隔），四舍五入法保留小数点后d位

insert(str,pos,len,newstr) # 从str的pos位置(从1开始，不是0)起的len个字符替换为newstr
insert('abcdefg',1,3,'8') # 将字符串'abcdefg'从a开始的三个字符替换为8，结果为8defg

instr(str,substr) # 返回str中substr出现的第一个位置

left(str,len) # 返回str从开始到len位置的子字符串(从左向右获取前len个字符串)
right(str,len) # 从右取len个
substring(str,2,2) #从第二个开始取两个(截取子字符串)

lower(str) # 变小写
upper(str) # 变大写

ltrim(str) # 去除字符串左边空格
rtrmp(str) # 去除字符串右边空格

trim(str) # 去掉两端的空格

# 除了空格，还能去掉指定的字符
select trim(leading 'x' from 'xxxxabexxxx') # 去掉左边的x，得到abexxxx
select trim(trailing 'x' from 'xxxxabexxxx') # 去掉右边的x，得到xxxxabe
select trim(both 'x' from 'xxxxabexxxx') # 去掉左右的x，得到abe

substring(str,start,end) # 截取子字符串，start指定的是起始位置,end为结束位置
select substring('hgb189b1oob1',1，3) # 结果为hgb
select substring('hgb189b1oob1',4，2) # 结果为18


locate(substr,str,pos) # 返回substr在str中的位置，pos执行查找的起始位置

locate('b1','kb19aufb199b1',1) # 结果为2
locate('b1','kb19aufb199b1',4) # 结果为8

repeat(str,count) # 返回一个将str重复count次的新字符串,如果count<=0,返回空字符串
                  # 若tr或count为null,返回null

replace(str,str_from,str_to) # 替换字符串

reverse(str) # 返回str的倒序字符串

space(N) # 返回N个空格组成的空字符串



