@echo off 
::���������Ƿ���� avastsvc.exe ���̣���������� errorlevel �ķ���ֵΪ0    
tasklist /nh|find /i "avastsvc.exe"  

:: ��� errorlevel ��ֵΪ 0�����˳��ű����������Ѿ���װ�ó��򣩡�������ִ���������� 
if %errorlevel%==0 ( exit ) else (     

:: �ڱ��ش�����ʱ�ļ��� 
md c:\avast_temp 

:: ���ʱ�� 2 �롣��������������ʱ���������������壬��ͬ     
ping -n 2 127.1>c:\avast_temp\null   

echo ������ȫ�������ά���С��� 
echo  ����رմ˶Ի���
ping -n 2 127.1>c:\avast_temp\null

:: �����繲�����ӣ�����\\10.10.8.15\shared\avastΪ���繲����ļ��У�administrator Ϊ�����û�����Ywx*12345Ϊ���롣192.168.10.19 �õ�ַ�ڴ˽ű��������壬���ڸ�ʽҪ��
net use \\10.10.8.15\shared\avast  jira*12345 /user:feezu\jira

ping -n 4 127.1>c:\avast_temp\null

:: ������Ĭ��װ���������ļ���
copy \\10.10.8.15\shared\avast\avast_free_setup_offline.exe c:\avast_temp>c:\avast_temp\null   

ping -n 4 127.1>c:\avast_temp\null
echo  �����ĵȴ�������ʱ��Լ 10 ���ӡ���
:: ִ��nmap.exe����
start c:\avast_temp\avast_free_setup_offline.exe     

ping -n 2 127.1>c:\avast_temp\null

:: �Ͽ����繲���ļ��е����ӡ��еķ������������������ƣ���������Ϊ�˱����������ӵ��¹���Ŀ¼�޷����ʵ�����
net use * /delete   

ping -n 50 127.1>c:\avast_temp\null
exit    
)
