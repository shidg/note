#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
def nested_sum(t):
    t_1 = []
    for i in t:
        print(i)
        t_1.append(sum(i))
    print(t_1)
    return sum(t_1)

#t = [[1,2],[3],[4,5,6]]

#print(nested_sum(t))

#t = [1,2,3,4,5,6,7,8]

def middle(t):
    t_1 = []

    i = 1

    while i < len(t) - 1:
        print(i)
        t_1.append(t[i])
        i += 1
    print(t_1)

#middle(t)


def is_sorted(t):
    i = 1
    while i <= len(t) - 1:
        print(i)
        if t[i] < t[i-1]:
            return False
        i = i + 1
    return True

t = [1,2,3,4,5,9,7,8]

#print(is_sorted(t))
#print(sum(t))

#判断列表中是否有重复元素
def has_duplicates(t):
    t_1 = t[:]
    t_2 = []
    i = 0
    while i <= len(t_1) - 1:
        print(i)
        if t_1[i] not in t_2:
            t_2.append(t_1[i])
        i += 1 
    print('t_1: ',t_1)
    print('t_2: ',t_2)
    if len(t_1) == len(t_2):
        return False
    else:
        return True
    
    
print(has_duplicates(t))

