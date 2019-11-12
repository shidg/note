#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#res = 1
#for i in range(1,6):
#    res = res * i
#print(res)

# 阶乘函数实现以上功能

def fact(n):
    if n == 1:
        return 1
    return n*fact(n-1)
#
print(fact(20))

# 斐波那契数列  1 1 2 3 5 8 13 21 34 55
#def fibo(n):
#    before = 1
#    after = 1
#    for i in range(n-1):
#        ret = before + after
#        before = after
#        after = ret
#    return ret

#print(fibo(8))


# 递归实现的斐波那契数列  1 1 2 3 5 8 13 21 34 55

#jdef fib(n):
#    a, b = 1, 1
#    while a < n:
#        print(a, end=' ')
#        a, b = b, a + b
#fib(1000)  # 输出的是100以内的斐波那契数列
#
#i = 1
#j = 1
#print(i,'\n',j)
#for x in range(2, 100):
#    if x == i + j:
#        print(x)
#        j = i
#        i = x