# file-max
# 内核能够分配的文件句柄数，系统级别的限制
# 修改此值
echo 6553560 > /proc/sys/fs/file-max #临时修改
echo "fs.file-max=6553560" >> /etc/sysctl.conf # 永久修改

# ulimit
# 单个用户能打开的文件句柄数，进程级别的限制
# 修改此值
ulimit -SHn 65536 # 临时修改，仅对当前shell生效
/etc/security/limits.conf # 永久修改
*  soft nofile  65535
*  hard nofile  65535
# nofile的最大值不能超过nr_open的值

# nr_open
# 单进程能打开的最大文件数
cat /proc/sys/fs/nr_open
echo "fs.nr_open=xxxx" >> /etc/sysctl.conf


# file-nr
# 当前系统的文件句柄数统计，打印出的三个值分别为已分配的，空闲的，允许的最大值(file-max)

# 查看某一进程打开的文件数
ls /proc/$PID/fdinfo | wc -l
