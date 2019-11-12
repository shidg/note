#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
import logging

########### 使用封装好的函数 #############

#logging.basicConfig(
#    level = logging.DEBUG,
#    format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
#    datefmt = '%a,%d %b %Y %H:%M:%S',
#    filename = 'test.log',  ##指定将日志写入文件，默认打印到标准输出
#    filemode = 'a'
#)
#
#logging.debug('debug message')
#logging.info('info message')
#logging.warning('warning message')
#logging.error('error message')
#logging.critical('critical message')
#
#



##### 使用logging.getLogger 自定义对象 ############

# 定义一个logger（日志器）对象
logger = logging.getLogger()

# 日志器要处理的日志等级
logger.setLevel(logging.ERROR)

# 或者使用logging.Logger来创建对象，并在创建的同时设置日志级别
# logger = logging.Logger('shidg', level=logging.INFO)


# 定义handler I(日志由谁来发送),同一日志器可以有多个handler
file_handler = logging.FileHandler('test.log',encoding='utf8')
consle_handler = logging.StreamHandler()


# 日志以什么格式发送
formatter = logging.Formatter(
    fmt="%(asctime)s %(module)s %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %X"
)


# 将格式应用于handler，毕竟最终日志是由handler发送的
file_handler.setFormatter(formatter)
consle_handler.setFormatter(formatter)


# handler定义好了，也应明确了发送的目的地、发送的格式，可以交给日志器使用了
logger.addHandler(file_handler)
logger.addHandler(consle_handler)


# 自定义的日志器可以开始工作了

#  定义日志器并设置日志级别 logging.getLogger() / setLevel() ----> 定义handler  logger.xxHandler ---->
#  定义日志格式并交给handler使用 logging.Formatter  setFormatter() --- > 日志器添加handler addHandler()
logger.debug('debug')
logger.info('info')
logger.warning('warning')
logger.error('error')
logger.critical('critical')
