#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#深浅copy（借助copy模块）
s = {}
#s.copy，浅copy（只复制第一层）复制一份数据，
#只能改第一层的（第一层独立），里面的嵌套数据改动会影响到被

#s.deepcopy，深copy，所有层都完全独立

n1 = {"k1": "wu", "k2": 123, "k3": ["alex", 678]}
#n2 = copy.copy(n1) # copy.copy() 浅拷贝
n2 = copy.deepcopy(n1) # copy.deepcopy() 深拷贝
n2['k1'] = 'liu'  # 浅拷贝时，修改第一层数据不影响n1
print(n1)
print(n2)

n2['k3'][1] = 7 #浅拷贝时，修改第二层数据会影响到n1，使用深拷贝可避免此问题
print(n1)
print(n2)