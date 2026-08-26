#!/bin/bash
# File Name: -- clear-osd.sh --
# author: -- shidegang --
# Created Time: 2024-08-23 17:21:03

yum install -y gdisk

#检查硬盘路径
fdisk -l
#删除硬盘分区信息
DISK="/dev/sdc"
sgdisk --zap-all $DISK

#清理硬盘数据（hdd硬盘使用dd，ssd硬盘使用blkdiscard，二选一）
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
oblkdiscard $DISK

#删除原osd的lvm信息（如果单个节点有多个osd，那么就不能用*拼配模糊删除，而根据lsblk -f查询出明确的lv映射信息再具体删除，参照第5项操作）
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
rm -rf /dev/ceph-*

#重启，sgdisk –zzap-all需要重启后才生效
reboot
