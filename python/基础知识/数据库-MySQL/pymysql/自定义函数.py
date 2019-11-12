#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


# mysql的自定义函数不支持返回结果集（select * from xxx）
delimiter //
create function f1(
    i1 int,
    i2 int
)

returns int
begin
    declare num int;
    set num = i1 + i2;
    return(num)
end //

delimiter ;

select f1(1,2)


