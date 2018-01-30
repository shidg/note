#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
def find(word,letter,begin):
    index = int(begin)
    while index < len(word):
        if word[index] == letter:
            print(str(letter) + "'s index is " + str(index))
            #return index
        print(index)
        index = index + 1
    return -1
#find('123456','6','3')

def count(strs,word):
    total = 0
    for letter in strs:
        if letter == word:
            total = total + 1
        print(letter)
    print(total)

count('phpchina','p')
    
