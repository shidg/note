#屏蔽snmp系统日志,只记录0-3级别的日志
# /etc/sysconfig/snmpd
OPTIONS="LS0-3d -Lf /dev/null -p /var/run/snmpd.pid -a"  
