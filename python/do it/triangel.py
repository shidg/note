#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
def is_triangel(a, b, c):
    if a < b +c and b < a + c and c < a + b:
        print("YES")
    else:
        print("No")

#is_triangel(15, 5, 7)

s = []

def input_3(n):
    if n < 1:
        pass
    else:
        a = input("输入一个长度:\n")
        s.append(int(a))
        input_3(n-1)

input_3(3)

print(s[0], s[1], s[2])

is_triangel(s[0], s[1], s[2])
