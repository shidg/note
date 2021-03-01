# get software
# wget ftp://ftp.isc.org/isc/bind9/9.10.2/bind-9.10.2.tar.gz

./configure --prefix=/usr/local/bind/ --with-openssl=/usr/ --sysconfdir=/etc/ --with-libtool --enable-threads


--prefix=/usr/local/bind                          #ָ��bind9�İ�װĿ¼,Ĭ����/usr/local

--enable-threads                                  #�������̵߳�֧�֣�������ϵͳ�ж��CPU����ô����ʹ�����ѡ��

--disable-openssl-version-check                   #�ر�openssl�ļ��

--with-openssl=/usr/local/openssl                 #ָ��openssl�İ�װ·��

--sysconfdir=/etc/                           #����named.conf�����ļ����õ�Ŀ¼��Ĭ����--prefixѡ��ָ����Ŀ¼�µ�/etc��

--localstatdir=/var                               #���� run/named.pid ���õ�Ŀ¼��Ĭ����--prefixѡ��ָ����Ŀ¼�µ�/var��

--with-libtool                                    #BIND�Ŀ��ļ�����Ϊ��̬������ļ������ѡ��Ĭ����δѡ��ġ� �����ѡ���ѡ���ô������named�����Ƚϴ�libĿ¼                                                     �еĿ��ļ�����.a��׺�� 


--disable-chroot                                  #����chroot��������ʹ�ã�Ĭ�Ͽ����˹���


make && make install


#���ϵͳ����

vi  ~/.bash_profile

PATH=$PATH:$HOME/bin:/usr/local/bind/bin:/usr/local/bind/sbin  #�޸ı���

source ~/.bash_profile  #ʹ�޸���Ч
 
#��������û�

useradd -r named  # -r ���ϵͳ�û�

#����chroot

mkdir  -p /var/named/chroot/{var,etc,dev}
mkdir /var/named/chroot/var/run

#���������豸

cd /var/named/chroot/dev

mknod random c 1 8 
mknod zero c 1 5 
mknod null c 1 3

#�޸�runĿ¼����
chown -R named:named  /var/named/chroot/var/run   #named Ҫ��runĿ¼д��pid�ļ�


#����rndc.conf ���Ա�ʹ��rndc�������bind
rndc-confgen > /etc/rndc.conf

�����ɵ����ݷֱ�д��/etc/named.conf��/etc/rndc.conf 
#�����ڲ����У�named.conf��д��chroot֮���etc��rndc.confд��chroot֮���etcȴ��ʾ�Ҳ�����д����ʵ��/etc��������

#���������ļ�

vi /var/named/chroot/etc/named.conf

key "rndc-key" {
       algorithm hmac-md5;
       secret "BM+rI8Ra3mpKKtIlYpGEAQ==";
 };

controls {
       inet 127.0.0.1 port 953
       allow { 127.0.0.1; } keys { "rndc-key"; };
};
options {
    directory "/var";
    pid-file  "/var/run/named.pid";
    version   "bind 9.9.3";
    allow-query {any;};
    forwarders {                 #�������dnsͬʱ���Խ�����������ʹ��forward���ܣ�
    	192.168.1.253;
    };

};

zone "." IN {
    type hint;
    file "named.root";
};

zone "lxy.com" IN {
        type master;
        file "named.lxy.com";
};
















vi /etc/rndc.conf

key "rndc-key" {
       algorithm hmac-md5;
       secret "BM+rI8Ra3mpKKtIlYpGEAQ==";
};
options {
        default-key "rndc-key";
        default-server 127.0.0.1;
        default-port 953;
};


#ZONE�ļ����ݣ�

#named.root
wget --user=ftp --password=ftp ftp://ftp.rs.internic.net/domain/db.cache -O /var/named/chroot/var/named.root



##named.lxy.kk
vi /var/named/chroot/var/named.lxy.kk     #��������zone���������dns���Խ����������Ͳ�Ҫ����.com�ȺϷ��򣬲�Ȼ����ͼ�����Ϸ�������ʱ����������ڱ���Ѱ�Ҽ�¼����Ȼ���Ҳ����ģ�����������Ҳ�����������ȥ��forward����

$TTL    86400
@    IN    SOA    lxy.kk. root.lxy.kk. (
                    2008080804    ;
                    28800        ;
                    14400        ;
                    3600000        ;
                    86400    )    ;
@        IN    NS   dns.lxy.kk.
@        IN    MX    10    mail.lxy.kk.
dns      IN    A    192.168.127.129
mail     IN    A    192.168.127.130
www            IN    A     192.168.127.129


vi /var/named/chroot/named.127.0.0    #���������zone

$TTL    86400
@    IN    SOA    dns.lxy.kk. root.lxy.kk. (
                    2008080804    ;
                    28800        ;
                    14400        ;
                    3600000        ;
                    86400    )    ;
@        IN    NS   dns.lxy.kk.
1    IN     PTR     localhost.



#��������

named  -c /etc/named.conf -t /var/named/chroot -u named  #ע�������/etc/ʵ��ָ����chroot�µ�etc,��Ϊ�Ѿ�ʹ��-tָ����chroot����Ŀ¼��named����chrootΪ��Ŀ¼


#rndc

rndc reload | status��
