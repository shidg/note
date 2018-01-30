#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
#s = '1234567'
#print(s[3:6])

import math
# a = ['1','2','3','4','5','6','7']
# b = a[1:3]
#print(b)

# enum_obj = enumerate('abcd')
#for index,ele in enum_obj:
#    print(index,ele)

#s = '123456'
#s1 = s.replace('123', 'abc')
#print(s1)

#s = "I  love you"
#print(s.split(" "))

# s = " I love you "
# s1 = s.lstrip()
# s2 = s.rstrip()
# s3 = s.strip()
# print(s1,"\n",s2,"\n",s3)
# print(s3)



#s1=s.replace('o','1').lstrip()
#print(s1)

#add = lambda x,y: x + y
#print(add(4,5))

#def add(x, y):
#    return x + y
#print(add(4,5))


#lst = list(range(5))
#for i in lst:
#    print(i)

def big_or_small(x, y):
    if x > y:
        print('1')
    elif x < y:
        print('-1')
    else:
        print('0')

#big_or_small(6,6)


def san_j(x, y):
    z = x**2 + y**2
    a = math.sqrt(z)
    return int(a)

print(san_j(3, 4))
