# setuid，setuid的作用是让执行该命令的用户以该命令拥有者的权限去执行，比如普通用户执行passwd时会拥有root的权限，这样就可以修改/etc/passwd这个文件了。它的标志为：s，会出现在u的x处，例：-rwsr-xr-x  。

# setgid只对目录有效，此目录下创建的文件继承该目录的所属组属性，它的标志为s, 出现在g的x处

# 沾滞位是针对目录来说的，如果该目录设置了stick  bit(粘滞位)，则该目录下的文件除了该文件的创建者和root用户可以删除和修改/tmp目录下的stuff，别的用户均不能动别人的

如何设置UID、GID、STICK_BIT：

SUID：置于 u 的 x 位，原位置有执行权限，就置为 s，没有了为 S .

chmod u+s  xxx # 设置setuid权限

chmod 4551 file // 权限： r-sr-x—x

 

 SGID：置于 g 的 x 位，原位置有执行权限，就置为 s，没有了为 S .

 chmod g+s  xxx # 设置setgid权限

 chmod 2551 file // 权限： r-xr-s--x

  

  STICKY：粘滞位，置于 o 的 x 位，原位置有执行权限，就置为 t ，否则为T .

  chmod o+t  xxx # 设置stick bit权限，针对目录

  chmod 1551 file // 权限： r-xr-x--t



