#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import configparser

config = configparser.ConfigParser()

#######手写一份全新的配置，然后写入一个配置文件###########
#config['DEFAULT'] = {
#    'ServerAliveInterval':'45',
#    'Compression':'yes',
#    'CompressionLevel':'9',
#    'ForwardX11':'yes'
#}
#
#config['bitbucket.org'] = {
#    'user':'hg'
#}
#config['topsecret.server.com'] = {
#    'Host port':'5122',
#    'ForwardX11':'no'
#}

#with open('config.ini_1','w') as f_obj:
#    config.write(f_obj)



######### 读取一个现有的配置文件，然后对其进行修改 ################
config.read('config.ini')

# 读取DEFAULT之外的配置项
print(config.sections())

# 读取DEFAULT下的配置项
print(config.defaults())


# 删
# config.remove_section('topsecret.server.com') # 删除一整块配置
# config.remove_option('topsecret.server.com','Host port') #删除一块配置下的某个配置项
#config.write('config.ini','w') # 将修改写入文件。注意是完全重写该文件，并不是只修改指定项
# 改
config.set('bitbucket.org','user','tom')


