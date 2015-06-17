yum update

yum install glibc glibc-devel gcc python python-devel libacl-devel krb5-workstation krb5-libs pam_krb5 gnutls-devel compat-openldap apr-util-ldap openldap-devel python-ldap openldap -y

mkdir samba4dc
git clone git://git.samba.org/samba.git samba-master

cd samba4dc/samba-master
./configure --prefix=/Data/app/samba --sysconfdir=/etc/samba --enable-debug --enable-selftest
make
make install


#AD
samba-tool domain provision --interactive --use-ntvfs

smbclient -L localhost -U%


