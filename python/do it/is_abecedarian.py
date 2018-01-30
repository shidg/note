#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
def is_abecedarian(word):
    i = 0
    while i < len(word) - 1:
        if word[i+1] < word[i]:
            return False
        i = i + 1
    return True

print(is_abecedarian('baccpgt'))
