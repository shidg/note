#! /bin/bash
function MENU() {
	PS3="选择目标服务器: "
	select option in "TOMCAT1" "TOMCAT2" "TOMCAT3" "TOMCAT2and3";do
	case $option in
    	TOMCAT1)
        	REMOTE_SERVER=$TOMCAT1
        	TYPE="TOMCAT1"
        	break
        ;;
    	TOMCAT2)
        	REMOTE_SERVER=$TOMCAT2
        	TYPE="TOMCAT2"
        	break
    	;;
    	TOMCAT3)
       		REMOTE_SERVER=$TOMCAT3
        	TYPE="TOMCAT3"
        	break
    	;;
    	TOMCAT2and3)
        	REMOTE_SERVER=($TOMCAT2 $TOMCAT3)
        	TYPE="TOMCAT2&3"
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
: ${SOURCE_DIR:="/Data/source/Platform/platform"} ${SYNC_USER:="rsync_user"} ${TOMCAT1:="10.51.84.95"} ${TOMCAT2:="10.172.234.162"} ${TOMCAT3:="10.47.138.177"} ${SSH_PORT:="5122"} ${RSYNC_MODULE:="platform"}

export SOURCE_DIR SYNC_USER TOMCAT1 TOMCAT2 TOMCAT3 SSH_PORT RSYNC_MODULE
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
