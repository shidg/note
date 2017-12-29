#! /bin/bash

function GET_READY_FOR_MINA() {
	PS3="目标环境: "
	select option in "dev" "test" "final" "prep" "product";do
	case $option in
    	dev)
        	REMOTE_ENV=dev
            sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_dev/" ${MINA_SOURCE_DIR}/config/config.properties
        	break
        ;;
    	test)
        	REMOTE_ENV=test
            sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_test/" ${MINA_SOURCE_DIR}/config/config.properties
        	break
    	;;
        final)
        	REMOTE_ENV=final
            sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_final/" ${MINA_SOURCE_DIR}/config/config.properties
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
                    break
                ;;
                prep_mina_server_2)
                    sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_prep_s2/" ${MINA_SOURCE_DIR}/config/config.properties
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
                    sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_product_s1/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_2)
                    sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_product_s2/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_3)
                    sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_product_s3/" ${MINA_SOURCE_DIR}/config/config.properties
        	        break
                ;;
                product_mina_server_4)
                    sed -i "/^serverId=/ s/=.*/=mina_${VERSION_NUMBER}_product_s4/" ${MINA_SOURCE_DIR}/config/config.properties
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
function GET_READY_FOR_NETTY() {
	PS3="目标环境: "
	select option in "dev" "test" "final" "prep" "product";do
	case $option in
    	dev)
        	REMOTE_ENV=dev
            sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_dev/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	break
        ;;
    	test)
        	REMOTE_ENV=test
            sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_test/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	break
    	;;
        final)
        	REMOTE_ENV=final
            sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_final/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	break
    	;;
    	prep)
        	REMOTE_ENV=prep
            sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.172.164.152:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
	        PS3="目标服务器: "
	        select option in "prep_netty_server_1" "prep_netty_server_2";do
	        case $option in
                prep_netty_server_1)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_prep_s1/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
                    break
                ;;
                prep_mina_server_2)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_prep_s2/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
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
            sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.172.191.112:61616,tcp:\/\/10.170.202.109:61616,tcp:\/\/10.171.57.30:61616)/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
	        PS3="目标服务器: "
	        select option in "product_netty_server_1" "product_netty_server_2" "product_netty_server_3" "product_netty_server_4";do
	        case $option in
                product_netty_server_1)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_product_s1/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	        break
                ;;
                product_netty_server_2)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_product_s2/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	        break
                ;;
                product_netty_server_3)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_product_s3/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
        	        break
                ;;
                product_netty_server_4)
                    sed -i "/^serverId=/ s/=.*/=hwgw_${VERSION_NUMBER}_product_s4/" ${NETTY_SOURCE_DIR}/${CONF_DIR}/config.properties
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
: ${MANAGE_SOURCE_DIR:="/Data/source/Platform/platform"} ${MINA_SOURCE_DIR:="/Data/source/Mina/mina"} ${WZC_SOURCE_DIR:="/Data/source/Mina/mina/wzc"} ${NETTY_SOURCE_DIR:="/Data/source/Platform/platform/hardware-gateway"} ${CONF_DIR:="src/main/resources"} ${SYNC_USER:="rsync_user"} ${SSH_PORT:="5122"} ${RSYNC_MODULE:="platform"}

export MANAGE_SOURCE_DIR MINA_SOURCE_DIR WZC_SOURCE_DIR NETTY_SOURCE_DIR  CONF_DIR SYNC_USER SSH_PORT RSYNC_MODULE
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
