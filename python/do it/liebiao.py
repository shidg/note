#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
names = ['zhangm','tony','jony','diss']
for name in names:
    print(name.title() + " Welcome!")

print(names[0])

names.append('tom')
print(names)

print("names[1] is " + names[1])

print("Then, insert jerry to names[1]")
names.insert(1,'jerry')

print("Now,names[1] is " + names[1])


# print(names)
