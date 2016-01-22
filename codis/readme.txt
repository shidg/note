##https://storage.googleapis.com/golang/go1.4.3.linux-amd64.tar.gz##

tar zxvf go1.4.1.linux-amd64.tar.gz -C /usr/local

echo >> /etc/profile <<EOF
#for golang
GOROOT=/usr/local/go
GOPATH=/usr/local/codis
PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GOROOT GOPATH PATH
EOF

mkdir /usr/local/codis

source /etc/profile

# test golang
echo >> /tmp/hello.go <<EOF
package main
 
import "fmt"
 
func main() {
    fmt.Printf("Hello World!\n")
}
EOF

go run /tmp/hello.go

# install codis
go get github.com/wandoulabs/codis

# install godep
go get github.com/tools/godep

cd /usr/local/codis/src/github.com/wandoulabs/codis/

make

make gotest

# now,$PWD is  /usr/local/codis/src/github.com/wandoulabs/codis/

echo > config.ini << EOF
coordinator=zookeeper
zk=10.170.186.91:2181,10.172.190.124:2181
product=feezu_1
dashboard_addr=localhost:18087
#连接后端codis-server是否需要密码,若开启此项，则后端codis-server要以相同密码启动(requirepass  xxxx)
password=xxxxxxxxxx

backend_ping_period=5
session_max_timeout=1800
session_max_bufsize=131072
session_max_pipeline=1024
zk_session_timeout=30000
proxy_id=proxy_1
EOF


# dashboard start
./bin/codis-config dashboard > /dev/null &

# slot init
./bin/codis-config slot init

# create codis groups
# (创建两个group,名为1、2，每个组中添加两个codis-server实例，只能一主，可以多从)
./bin/codis-config server add 1 10.172.18.56:6379 master
./bin/codis-config server add 1 10.172.132.126:6380 slave
./bin/codis-config server add 2 10.172.132.126:6379 master
./bin/codis-config server add 2 10.172.18.56:6380 slave

# 将0~1023共计1024个slot分配到不同的组中
./bin/codis-config slot range-set 0 511 1 online
./bin/codis-config slot range-set 512 1023 2 online

#codis-proxy start
./bin/codis-proxy -L /Data/logs/codis/codis-proxy.log --log-level=error --cpu=2 --addr=:9000 --http-addr=:9001  > /dev/null &

#启动的codis-proxy默认为offline状态，通过以下命令使其online
./bin/codis-config proxy online proxy_1
