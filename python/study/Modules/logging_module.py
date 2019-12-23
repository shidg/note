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

# 调用日志器的各个方法（接口）生成日志信息
logger.debug('debug')
logger.info('info')
logger.warning('warning')
logger.error('error')
logger.critical('critical')


# 一个日志器(logger)可以绑定多个处理器(handler),将同一份日志发送到不同地方，比如同时发送到终端和日志文件。
# 而不同的处理器可以定义不同的日志级别，就可以实现发送到文件的内容和发送到终端的内容是不同的



# 可用的变量
变量	         格式	              变量描述
asctime	         %(asctime)s`	      日志生成时间，默认精确到毫秒，可以额外指定 datefmt 参数来指定该变量的格式
name	         %(name)	      日志对象的名称
filename	 %(filename)s	      不包含路径的文件名
pathname	 %(pathname)s	      包含路径的文件名
funcName	 %(funcName)s	      日志记录所在的函数名
levelname	 %(levelname)s	      日志的级别名称
message	         %(message)s	      具体的日志信息
lineno	         %(lineno)d	      日志记录所在的行号
pathname	 %(pathname)s	      完整路径
process	         %(process)d	      当前进程ID
processName	 %(processName)s      当前进程名称
thread	         %(thread)d	      当前线程ID
threadName	 %threadName)s	      当前线程名称
