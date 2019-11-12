#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 字符串在Python内部的表示是unicode编码，
# 因此，在做编码转换时，通常需要以unicode作为中间编码，
# 即先将其他编码的字符串解码（decode）成unicode，再从unicode编码（encode）成另一种编码
# 1，字符存硬盘，要变成bytes ,硬盘只能存储2进制
# 2，网络传输，字符要变成bytes类型
#gbk / utf8 - --> > decode(解码）---> > unicode
#Unicode - --> > encode(编码）---> > gbk / utf8(2进制）
#文字 - -》utf - 8 / gbk --> > 2进制
#图片 - -》jpg / png --> > 2进制
#音乐 - -》mp3 / wav --> > 2进制
#视频 - -》mp4 / mov --> > 2进制
#bytes类型，以16进制形式表示，2个16进制数（如0x5）构成一个byte（字节），以‘b’来标识
#1byte = 8bit
#python3文件的默认编码是utf - 8（pycharm默认加载文件都是用utf8编码）
#eg：f = open('bytes.txt', 'w', encoding='gbk')  # 自己指定编码
#eg：f = open('bytes.txt', 'wb')  # 以2进制模式就不用指定编码

# 'wb'-----二进制写（必须是二进制）
# 'w'------文件写（必须是字符串）


# 编码（unicode--->二进制）
s = '快放假了'
#s = s.encode(encoding='utf8') # 以utf8编码成bytes类型(二进制)
#print(s)
s = bytes(s,encoding='utf8') #以utf8编码成bytes类型(二进制)
#print(s)


# 解码 （二进制----> unicode）
s = '快放假了'
s = s.encode(encoding='utf8')
print(s)
#s = s.decode(encoding='utf8') # 将bytes类型数据（二进制数据）以utf8解码成unicode字符串
s = str(s,encoding='utf8')    # 将bytes类型数据（二进制数据）以utf8解码成unicode字符串
print(s)
