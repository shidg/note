:: 判断是否存在C:\avast_temp\ 如果存在则执行删除C:\lansecs_temp文件夹。如果不存在，则退出。
if exist C:\avast_temp\ ( rd /s /Q C:\avast_temp ) else ( goto exit )