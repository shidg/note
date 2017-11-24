# install DKMS
yum  install dkms

#Auto-Build KPCRE with DKMS
git clone https://github.com/xnsystems/kpcre.git

mv kpcre /usr/src/kpcre-1.0.0

dkms add -m kpcre -v 1.0.0
dkms build -m kpcre -v 1.0.0
dkms install -m kpcre -v 1.0.0


dkms status | grep kpcre


##加载模块
modprobe ts_pcre


#删除模块
modprobe -r ts_pcre
