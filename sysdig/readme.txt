#install

# sysdig提供的全自动安装脚本
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | bash 



# 手动yum安装
rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public
curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

rpm -ivh dkms-2.2.0.3-1.noarch.rpm
yum install kernel-devel
yum install sysdig


# sourcecode
# GCC/G++ > 4.4 (Linux) or Clang (for OSX)
# Linux kernel headers
# CMake > 2.8.2
# For Linux, the following kernel options must be enabled (usually they are, unless a custom built kernel is used):
# CONFIG_TRACEPOINTS
# CONFIG_HAVE_SYSCALL_TRACEPOINTS

yum install kervel-devel

git clone https://github.com/draios/sysdig sysdig
cd sysdig
mkdir build
cd build
cmake ..
make
make install
