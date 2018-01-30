#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

file_name = 'words.txt'
#with open(file_name) as fin:
#    for line in fin:
#        if len(line.strip()) > 20:
#            print(line)


def has_no_e(filename):
    count = 0
    total = 0
    with open(filename) as fin:
        for line in fin:
            total = total + 1
            if 'e' in line.strip():
                pass
            else:
                count = count + 1
        print(count/total)

#has_no_e('words.txt')

def avoids(word,strs):
    for i in strs:
        if i in word:
            return False
    print("Has no")

print(avoids('phpchina','u'))
