#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import hashlib

#a = hashlib.md5()
#a.update('hello'.encode('utf8'))
#print(a.hexdigest())
#a = hashlib.sha256()
#a.update('hello'.encode('utf8'))
#print(a.hexdigest())

passwords = [
    '123456',
    'qweasd',
    'qazwsx',
    '098765'
]

def make_passwds_dict(passwds):
    passwd_dict = {}
    for passwd in passwds:
        m = hashlib.sha256()
        m.update('一行白鹭上青天'.encode('utf8')) # 密码加盐
        m.update(passwd.encode('utf8'))
        passwd_dict[passwd] = m.hexdigest()
    return passwd_dict
def break_code(userhash,passwd_dict):
    for k, v in passwd_dict.items():
        if userhash == v:
            print('passwd is {0}'.format(k))

user_hash = 'a0f3a328333f4cc6578dc163aede7f18d5a440ecf5c70b93c6476e944318eebc'
pass_dict = make_passwds_dict(passwords)
break_code(user_hash,pass_dict)
