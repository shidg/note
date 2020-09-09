如果既想获得 RHEL 的高质量、高性能、高可靠性，又需要方便易用(关键是免费)的软件包更新功能，那么 Fedora Project 推出的 EPEL(Extra Packages for Enterprise Linux)正好适合你。EPEL(http://fedoraproject.org/wiki/EPEL) 是由 Fedora 社区打造，为 RHEL 及衍生发行版如 CentOS、Scientific Linux 等提供高质量软件包的项目

## centos 7
yum install epel-release
yum repolist
yum --disablerepo="*" --enablerepo="epel" list available




###CentOS/RedHat 6
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6


###CentOS/RedHat 5

rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
rpm -ivh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL


# 内核升级
# 小版本升级
yum update kernel

# 大版本升级（elrepo源）
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*
yum --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml* --skip-broken

# 将新安装的内核设置为系统默认启动内核
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
