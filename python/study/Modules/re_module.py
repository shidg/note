#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

################### 匹配指定模式的字符串 #################


####### 自带的匹配方法（完全匹配）
#s.find('ll')  ##返回查找的字符串第一次出现的位置，查找对象被当做一个整体处理（视为一个字符）
#s.rfind('ll')  ##返回查找的字符串最后一次出现的位置，查找对象被当做一个整体处理（视为一个字符）

#s.replace('ll','ww') ## ll替换为ww,返回一个新的字符串对象，s并未被修改

#s.split('w')  # 以w为分隔符，字符串被分隔成两部分，返回值是一个列表


#### 正则完成的模糊匹配

import re


#res = re.findall('w\w+d',s)
#print(res)

# 元字符
## 元字符默认都是匹配前边紧挨着它的一个字符，比如?是指重复它前边的一个字符。如果要重复多个，用小括号括起来
#res = re.findall('(hel){2,}',s)

# 1.   通配符 . 匹配换行符之外的任意一个字符

# 2.   ^ 匹配字符串开头

# 3.   $ 匹配字符串结尾

# 4.   * 重复匹配（零次或多次） ------->   {0,}

# 5.   + 重复匹配（一次或多次） ------->   {1,}

# 6.   ? 零次或一次           ------->   {0,1}

# 7.   {} 重复复指定次数,可以是一个范围
#      res = re.findall('hel{2,}',s)

# 8.   [] 字符集,满足字符集中的任意一个模式即视为匹配，

#      ######################## 记住[]永远是单个匹配,包括取反的时候 ###########################
#      另外[]还取消元其他字符的特殊功能：比如*放到[]中就是一个普通的*，不再是元字符
    #s = '123yGhHFAHPG'
    #res = re.findall('[0-9][a-z][A-Z]',s)
    #res = re.findall('[^23]',s) # 非2或非3
    #res = re.findall('[^(2|3)]',s) # 非2或非3
    #res = re.findall('^(1|3)',s) # 开头位置找1或3
    #res = re.findall('[GhH]',s)  # []中写多个字符也是单个匹配，分别匹配G 、h、H，不会吧GhH当做一个整体模式去匹配
    #print(res)

# 9.   |  或

# 10.  \  转义，去除元字符特殊意义，  或与某些普通字符组合实现一些特殊功能
        ##### 在正则表达式中 ######
#       \d ----- [0-9]
#       \D ----- [^0-9]
#       \s -----  任意空白字符  [\t\n\r\f\v]等
#       \S -----  任意非空白字符 [^\t\n\r\f\v]
#       \w -----  任意字母或数字 [a-zA-Z0-9]
#       \W -----  任意非字母或数字  [^a-zA-Z0-9]
#       \b -----  匹配单词边界，也就是单词和特殊字符间的位置
        #s = 'hello, I am a LIST'
        #re.findall(r'I\b',s)  ## 第一个I
        #s = 'hello, I am a LI$T'
        #re.findall(r'I\b',s)   ## 两个I

# 11.  ()  表达式分组,并给组命名，可以使用组名提取匹配到的值
#s = 'fajio123anflaobp'
#res = re.search('(?P<id>\d+)(?P<name>\w+p)',s)
#print(res)
#print(res.group())
#print(res.group('id'))
#print(res.group('name'))


#s = '123yGhHFAHPG'
#t = 'baidu.com,http://sohu.com,fafafeeg.com/faefifa'
#res = re.findall('[0-9][a-z][A-Z]',s)
#res = re.findall('[^23]',s) # 非2非3
#res = re.findall('[^(2|3)]',s) # 非2非3
#res = re.findall('^(1|3)',s) # 开头位置找1或3
#res = re.findall('(http://\w+.com|.cn)',t)


#s = '123yGhHFD\\nHPG'
#res = re.search('G',s) # 只匹配第一个，返回值是一个对象
#print(res)  # <re.Match object; span=(4, 5), match='G'>
#print(res.group()) # 取出对象里的值
#res = re.search('G',s).group()

#res = re.search(r'\\n',s)

#print(res.group())

#mm="c:\\ab\\bc\\cd\\"
#print (mm)
#r=re.match("c:\\\\ab",mm)
#print (r.group())
#r=re.match(r"c:\\ab",mm).group()
#print (r)


### 总结

# re.findall() 所有结果返回为一个列表

# re.search()  只匹配第一个，并返回为对象。可调用group()取出匹配到的值

# re.match()    只在字符串开头匹配，返回为对象,可调用group(),开头匹配不上则返回空对象.

# re.split()   可以指定多个分隔符
#s = 'jiagjioal'
#res = re.split('[g,o]',s)   #先以g为分隔符分开为两部分，之后以o为分隔符分别对两部分再次进行分割
#print(res)


# re.sub()  替换
#s = 'hello python'
#res = re.sub('p\w+n','linux',s)
#print(res)



# re.compile()   将正则编译为一个对象，可以被其他表达式重复引用

#c = re.compile('\w+3')
#res1 = c.match('hua3fopjafa')
#res2 = c.match('fau3amofjea')
#print(res1.group())
#print(res2.group())
#
#d = re.compile('\.com')
#res3 = d.findall('www.baidu.comjapofjep.faefafa')
#res4 = d.findall('www.sohu.com,/lsohu.com\japfa.comofjep.faefafa')
#print(res3)
#print(res4)

#s = '1 +   4*  4-3+ 54 + 2'
#a = re.sub('\s+','',s)
#print(a)

#s = '5*5'
#res = re.split('\*',s)
#print(res)

