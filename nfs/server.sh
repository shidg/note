#安装
# yum install portmap # 从centos6开始 portmap 变成rpcbind
yum install nfs-utils

#centos6 安装

yum install nfs-utils rpcbind
#设置共享目录，共享参数是重点，这些参数中有部分参数在CENTOS6的新版本NFS中不再可用，比如no_root_suqash no_hide，应该是出于安全性考虑
vi  /etc/exports
/data/nfs  10.0.8.2(rw,ro,sync,async,secure,insecure,root_suqash,no_root_suqash,all_suqash,anonuid=,anongid=,hide,no_hide,subtree_check,no_subtree_check) #注意这里是空格  *(ro)

#anonuid  anongid这两个参数指定了匿名访问nfs目录的用户uid,当在客户端用root访问挂载的nfs目录是，root的身份会被自动映射为一个普通用户，默认这个用户是nfsnobody,如果服务端的exports文件设置了anonuid参数，则root会映射为anonuid指定的那个用户

#启动服务
service portmap/rpcbind start
service nfs start

#管理
showmount -e  localhost #显示共享信息
exportfs -ar  #重新加载exprots文件，使新的挂载参数生效



访问权限选项

设置输出目录只读：ro
设置输出目录读写：rw
用户映射选项

  all_squash：将远程访问的所有普通用户及所属组都映射为匿名用户或用户组（nfsnobody）；
  no_all_squash：与all_squash取反（默认设置）；
  root_squash：将root用户及所属组都映射为匿名用户或用户组（默认设置）；
  no_root_squash：与rootsquash取反；
  anonuid=xxx：将远程访问的所有用户都映射为匿名用户，并指定该用户为本地用户（UID=xxx）；
  anongid=xxx：将远程访问的所有用户组都映射为匿名用户组账户，并指定该匿名用户组账户为本地用户组账户（GID=xxx）；

其它选项

  secure：限制客户端只能从小于1024的tcp/ip端口连接nfs服务器（默认设置）；
  insecure：允许客户端从大于1024的tcp/ip端口连接服务器；
  sync：将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性；
  async：将数据先保存在内存缓冲区中，必要时才写入磁盘；
  wdelay：检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率（默认设置）；
  no_wdelay：若有写操作则立即执行，应与sync配合使用；
  subtree：若输出目录是一个子目录，则nfs服务器将检查其父目录的权限(默认设置)；
  no_subtree：即使输出目录是一个子目录，nfs服务器也不检查其父目录的权限，这样可以提高效率；
