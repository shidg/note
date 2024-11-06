## 文件描述符 fd  文件句柄数  最大打开的文件数
### Linux哲学: 一切皆文件

###/proc伪文件系统


### Linux配置系统最大打开文件描述符个数

##系统级限制

```shell
echo "xxxx" > /proc/sys/fs/file-max #即时生效，但是重启后会丢失
```

```shell
echo "fs.file-max = 52706963" >> /etc/sysctl.conf && sysctl -p #永久修改
```

##进程级限制

```shell
echo "xxx" >  /proc/sys/fs/nr_open
```

```shell
echo "fs.nr_open=xxxx" >> /etc/sysctl.conf && sysctl -p
```

##用户级限制

```shell
ulimit -n #查看当前限制
```

```shell
ulimit -SHn # 即时生效，但是非永久
```

```shell
/etc/security/limits.conf # 永久生效
```

### file-nr

```shell
cat /proc/sys/fs/file-nr
```

当前系统的文件句柄数统计，打印出的三个值分别为已分配的，空闲的，允许的最大值(file-max)

