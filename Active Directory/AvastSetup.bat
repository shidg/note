@echo off 
::检查进程中是否存在 avastsvc.exe 进程，如果存在则 errorlevel 的返回值为0    
tasklist /nh|find /i "avastsvc.exe"  

:: 如果 errorlevel 的值为 0，则退出脚本（即本机已经安装该程序）。否则则执行以下命令 
if %errorlevel%==0 ( exit ) else (     

:: 在本地创建临时文件夹 
md c:\avast_temp 

:: 间隔时间 2 秒。该命令用于设置时间间隔，无其他意义，下同     
ping -n 2 127.1>c:\avast_temp\null   

echo 内网安全软件更新维护中…… 
echo  请勿关闭此对话框。
ping -n 2 127.1>c:\avast_temp\null

:: 打开网络共享连接，其中\\10.10.8.15\shared\avast为网络共享的文件夹，administrator 为共享用户名，Ywx*12345为密码。192.168.10.19 该地址在此脚本中无意义，用于格式要求
net use \\10.10.8.15\shared\avast  jira*12345 /user:feezu\jira

ping -n 4 127.1>c:\avast_temp\null

:: 拷贝静默安装包到本地文件夹
copy \\10.10.8.15\shared\avast\avast_free_setup_offline.exe c:\avast_temp>c:\avast_temp\null   

ping -n 4 127.1>c:\avast_temp\null
echo  请耐心等待，更新时间约 10 分钟……
:: 执行nmap.exe程序
start c:\avast_temp\avast_free_setup_offline.exe     

ping -n 2 127.1>c:\avast_temp\null

:: 断开网络共享文件夹的连接。有的服务器会有连接数限制，此命令是为了避免过多的连接导致共享目录无法访问的问题
net use * /delete   

ping -n 50 127.1>c:\avast_temp\null
exit    
)
