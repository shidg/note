#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#a = (x**2 for x in range(10))  ## 区别于 a = [x**2 for x in range(10)](列表生成式)
#print(a) # a是一个生成器对象，


#b =  range(5)
#print(type(b))

# 与列表生成式的区别是：生成器并不会像列表解析那样，将所有数据计算出来并放进内存，而是在需要的时候再计算数据
# 避免内存使用过多

# 但是生成器对象取数据只能按照顺序逐一取，无法像列表一样取任意位置的数据
#print(next(a))  # 从生成器对象中取数据
#print(next(a))  # 从生成器对象中取下一个数据


# 生成器对象是迭代器,可以使用for循环来取值
# 与列表的区别在于，列表是所有数据放在内存待取用，全部数据都在内存中
# 生成器在for循环的过程中是取完数据即销毁，一直只有一个数据在内存中
#for i in a:
#    print(i)
#

# 将函数做为生成器

def foo():
    print('hello!')
    yield 3

    print('bye')
    yield 4

c = foo()  # 对于带yield的函数，调用该函数时返回的是一个生成器对象，并不会执行任何操作，直到对该对象执行next()方法
next(c)  # 第一次对生成器对象执行next()方法，执行print('hello')语句后停止,返回值是3
next(c)  # 第一次对生成器对象执行next()方法，执行print('bye')语句后结束，返回值是4


#
#print(foo()) #该函数的执行结果是一个生成器对象 <generator object foo at 0x103d4b4d0>
#g = foo() # 该对象赋值给g
#next(g)  # 执行函数第一步操作,并获得返回值 1
#next(g)  # 执行第二步操作,并获得返回值 2

#for i in g:  # 依次执行函数中的步骤
#    i

# 菲波那切数列
#def fibo(n):
#    a = 1
#    b = 1
#    while a < n:
##        print(a)
#        yield a
#        a,b = b, a+b
##
#g = fibo(10)
##
#print(g)
##
#for i in g:
#    print(i)



#def foo():
#    res = yield 1
#    print('res: ',res)
#    yield 2

#g = foo()
#print(next(g))
#print(g.send('s'))
