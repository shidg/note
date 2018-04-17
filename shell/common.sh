#! /bin/bash

set -u 

function ERRTRAP(){ 
    echo "[LINE :$1 ] Error: Command or functions exited with status $?"
    exit
}
function MENU {
	PS3="目标服务器: "
	select option in "TOMCAT1" "TOMCAT2" "TOMCAT3";do
	case $option in
    	TOMCAT1)
			REMOTE_SERVER=TOMCAT1
			break
		;;
    	TOMCAT2)
			REMOTE_SERVER=TOMCAT2
			break
		;;
    	TOMCAT3)
			REMOTE_SERVER=TOMCAT3
			break
		;;
        *)
       		clear
        	echo "Error! Wrong choice!"
        	exit
    	;;
	esac
	done
}


function GET_READY_FOR_MINA() {
    trap 'ERRTRAP $LINENO' ERR

    PS3="目标环境: "
	select option in "dev" "test" "prep" "product";do
	case $option in
        dev)
            REMOTE_ENV=dev
            sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_dev/" ${MINA_SOURCE_DIR}/config/config.properties
            sed -i "/^gateway.isReportToRegister=/ s/true/false/" ${MINA_SOURCE_DIR}/config/config.properties
        	break
        ;;
    	test)
        	REMOTE_ENV=test
            sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_test/" ${MINA_SOURCE_DIR}/config/config.properties
            sed -i "/^gateway.isReportToRegister=/ s/true/false/" ${MINA_SOURCE_DIR}/config/config.properties
        	break
    	;;
    	prep)
        	REMOTE_ENV=prep
            sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.172.164.152:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${MINA_SOURCE_DIR}/config/msgConfig.properties
	        PS3="目标服务器: "
	        select option in "prep_mina_server_1" "prep_mina_server_2";do
	        case $option in
                prep_mina_server_1)
                	sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_prep_s1/" ${MINA_SOURCE_DIR}/config/config.properties
            	     	sed -i "/^gateway.isReportToRegister=/ s/true/false/" ${MINA_SOURCE_DIR}/config/config.properties
                    	break
                ;;
                prep_mina_server_2)
                    	sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_prep_s2/" ${MINA_SOURCE_DIR}/config/config.properties
            	     	sed -i "/^gateway.isReportToRegister=/ s/true/false/" ${MINA_SOURCE_DIR}/config/config.properties
                    	break
                ;;
                *)
        	        clear
        	        echo "Error! Wrong choice!"
        	        exit
    	        ;;
            esac
            done
            break
        ;;
    
    	product)
        	REMOTE_ENV=product
            sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.172.191.112:61616,tcp:\/\/10.170.202.109:61616,tcp:\/\/10.171.57.30:61616)/" ${MINA_SOURCE_DIR}/config/msgConfig.properties
	        PS3="目标服务器: "
	        select option in "product_mina_server_1" "product_mina_server_2" "product_mina_server_3" "product_mina_server_4";do
	        case $option in
                product_mina_server_1)
                    sed -i "/^serverId=/ s/=.*/=mina_product_s1/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_2)
                    sed -i "/^serverId=/ s/=.*/=mina_product_s2/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_3)
                    sed -i "/^serverId=/ s/=.*/=mina_product_s3/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_4)
                    sed -i "/^serverId=/ s/=.*/=mina_product_s4/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                *)
        	        clear
        	        echo "Error! Wrong choice!"
        	        exit
    	        ;;
            esac
            done
            break
        ;;
    	*)
        	clear
        	echo "Error! Wrong choice!"
        	exit
    	;;
	esac
	done
}
function GET_READY_FOR_GATEWAY() {
    trap 'ERRTRAP $LINENO' ERR
	PS3="设备版本: "
	select option in "1.0" "2.0";do
	case $option in
    	1.0)
        	DEVICE_ENV=1.0
        	break
        ;;
    	2.0)
        	DEVICE_ENV=2.0
        	break
    	;;
    	*)
        	clear
        	echo "Error! Wrong choice!"
        	exit
    	;;
	esac
	done
}

function GET_READY_FOR_DM() {
    trap 'ERRTRAP $LINENO' ERR
	unalias cp
    cd ${DM_SOURCE_DIR}/device-manage-web/src/main/resources
	if [ -f "dubbo.properties" ];then
    	rm -f dubbo.properties
	fi

	if [ -f "gateway-deliver-config.properties" ];then
    	rm -f gateway-deliver-config.properties
	fi
	cp -f dubbo.properties.template dubbo.properties
	cp -f gateway-deliver-config.properties.template gateway-deliver-config.properties

	PS3="目标环境: "
	select option in "prep" "product";do
	case $option in
    	prep)
        	REMOTE_ENV=prep
			sed -i "/dubbo.registry.address/ s/=.*/=zookeeper:\/\/10.172.164.152:2181?client=zkclient/" dubbo.properties
			sed -i "/dubbo.protocol.port/ s/20018/20019/" dubbo.properties
			sed -i "/jdbc.url/ s/dev.feezu.cn/rds8ei10r74e6ey5j592.mysql.rds.aliyuncs.com/" gateway-deliver-config.properties
			sed -i "/jdbc.username/ s/test/mainuser/" gateway-deliver-config.properties
			sed -i "/jdbc.password/ s/test/OgVT2DokWhzm/" gateway-deliver-config.properties
			sed -i "/redis.host/ s/127.0.0.1/redis_01/" gateway-deliver-config.properties
        	break
        ;;
    	product)
        	REMOTE_ENV=product
			sed -i "/dubbo.registry.address/ s/=.*/=zookeeper:\/\/10.171.51.137:2181?backup=10.171.117.54:2181,10.44.52.77:2181/" dubbo.properties
			sed -i "/dubbo.protocol.port/ s/20018/20019/" dubbo.properties
			sed -i "/jdbc.url/ s/dev.feezu.cn/rdsk03oijx73u4fa8305.mysql.rds.aliyuncs.com/" gateway-deliver-config.properties
			sed -i "/jdbc.username/ s/test/device_clound/" gateway-deliver-config.properties
			sed -i "/jdbc.password/ s/test/uAVUgmAdbW5Vw6N/" gateway-deliver-config.properties
			sed -i "/redis.host/ s/127.0.0.1/10.165.119.188/" gateway-deliver-config.properties
        	break
    	;;
    	*)
        	clear
        	echo "Error! Wrong choice!"
        	exit
    	;;
	esac
	done
}

function GET_READY_FOR_DL() {
    trap 'ERRTRAP $LINENO' ERR
	unalias cp
    cd ${GATEWAY_SOURCE_DIR}/devicelb/src/main/resources
	if [ -f "application.properties" ];then
    	rm -f application.properties
	fi

	cp -f application.properties.template application.properties

	PS3="目标环境: "
	select option in "prep" "product";do
	case $option in
    	prep)
        	REMOTE_ENV=prep
			#sed -i "/tcp-server.port/ s/=.*/=9981/" application.properties
			sed -i "/tcp-server.id/ s/=.*/=devicelb_pre/" application.properties
            sed -i "/mq.broker-url/ s/=.*/=failover:(tcp:\/\/10.172.164.152:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" application.properties
			sed -i "/spring.dubbo.registry.address/ s/=.*/=zookeeper:\/\/10.172.164.152:2181/" application.properties
        	break
        ;;
    	product)
        	REMOTE_ENV=product
	        PS3="目标服务器: "
	        select option in "server1" "server2";do
	        case $option in
                server1)
			        sed -i "/tcp-server.port/ s/=.*/=9981/" application.properties
			        sed -i "/tcp-server.id/ s/=.*/=devicelb_pro_s1/" application.properties
			        sed -i "/mq.broker-url/ s/=.*/=tcp:\/\/10.165.119.188:61616/" application.properties
			        sed -i "/spring.dubbo.registry.address/ s/=.*/=zookeeper:\/\/10.171.51.137:2181?backup=10.171.117.54:2181,10.44.52.77:2181/" application.properties
			        sed -i "/spring.dubbo.protocol.port/ s/=.*/=20880/" application.properties
        	        break
    	        ;;

                server2)
			        sed -i "/tcp-server.port/ s/=.*/=9981/" application.properties
			        sed -i "/tcp-server.id/ s/=.*/=devicelb_pro_s2/" application.properties
			        sed -i "/mq.broker-url/ s/=.*/=tcp:\/\/10.165.119.188:61616/" application.properties
			        sed -i "/spring.dubbo.registry.address/ s/=.*/=zookeeper:\/\/10.171.51.137:2181?backup=10.171.117.54:2181,10.44.52.77:2181/" application.properties
			        sed -i "/spring.dubbo.protocol.port/ s/=.*/=20880/" application.properties
        	        break
    	        ;;

    	        *)
        	        clear
        	        echo "Error! Wrong choice!"
        	        exit
    	        ;;
	        esac
	        done
            break
        ;;
    	*)
        	clear
        	echo "Error! Wrong choice!"
        	exit
    	;;
	esac
	done
}

function DEFINE_VARIABLES() {
    trap 'ERRTRAP $LINENO' ERR
    : ${MANAGE_SOURCE_DIR:="/Data/source/Platform/platform"} ${MINA_SOURCE_DIR:="/Data/source/Mina/mina"} ${WZC_SOURCE_DIR:="/Data/source/Mina/mina/wzc"} ${GATEWAY_SOURCE_DIR:="/Data/source/device-gateway"} ${CONF_DIR:="src/main/resources"} ${SYNC_USER:="rsync_user"} ${SSH_PORT:="5122"} ${RSYNC_MODULE:="platform"} ${DM_SOURCE_DIR:="/Data/source/device-manage"} ${SETUP_SOURCE_DIR:="/Data/source/setup"} ${TOMCAT1:="10.51.84.95"} ${TOMCAT2:="10.172.234.162"} ${TOMCAT3:="10.47.138.177"}  

    export MANAGE_SOURCE_DIR MINA_SOURCE_DIR WZC_SOURCE_DIR NETTY_SOURCE_DIR  CONF_DIR SYNC_USER SSH_PORT RSYNC_MODULE GATEWAY_SOURCE_DIR DM_SOURCE_DIR SETUP_SOURCE_DIR TOMCAT1 TOMCAT2 TOMCAT3
}

function EXIT_CONFIRMATION() {
    echo -ne "Confirm to exit?[Y/N]"
	read -n 1 answer
	case $answer in
	    Y|y)
		echo
		echo "The script is about to exit..."
		sleep 1
		exit
		;;
		N|n)
		echo
		echo "The script will continue..."	
		;;
		*)
		echo
		EXIT_CONFIRMATION
		;;
	esac
}
