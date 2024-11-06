#! /bin/bash

#source ./stage_functions.sh
#source ./ansible_functions.sh

## 定义菜单函数
# 一级菜单
menu_main() {
#echo << EOF
echo "============================ 选择需要的功能 ============================"
echo "[0] 生成ansible所需的hosts文件"
echo "[1] 运行环境部署(服务器初始化、k8s集群部署)"
echo "[2] 基础软件安装(安装数据库、nginx)"
echo "[3] 底层服务部署(部署转码、截图、统一用户管理等底层服务)"
echo "[4] 上层业务部署(部署上层服务)"
echo "[5] 其他辅助工具"
echo "[q] 退出脚本"
#EOF
    read -r -p "请选择所需功能【1-6】: " input_main
    case $input_main in
        0)
            make_hosts
            ;;
        1)
            run_env_deploy
            ;;
        2)
            base_software_deploy
            ;;
        3) 
            base_service_deploy
            ;;
        4)
            service_full_deploy
            ;;
        5)
            menu_tools
            ;;
        q) 
            exit
            ;;
        *) 
            echo -e "\033[35m Wrong input!!!\033[0m"
            echo -e "\033[35m Please enter choose[1-3] or enter q to exit\033[0m" 
            sleep 2
            ;;
    esac
}

# 维护工具选择菜单
menu_tools() {
cat << EOF
============================ 选择要使用的工具 ============================
[1]  主机连通性测试
[2]  外网出网测试
[3]  获取磁盘信息
[4]  获取全部服务器主机名
[5]  扩容k8s集群的node节点               
[6]  磁盘分区、格式化、挂载等
[q]  返回主菜单
EOF
    read -r -p "请选择所需工具【1-8】: " input_tools
    case $input_tools in
        1)
            ping_test
            ;;
        2)  access_internet
            ;;
        3)
            get_hdinfo
            ;;
        4)
            list_hostname
            ;;
        5)
            expand_k8s_node_server
            ;;
        6)
            disk_server
            ;;
        q)  
            clear
            menu_main 
            ;;
        *) 
            echo -e "\033[35m Wrong input!!!\033[0m"
            echo -e "\033[35m Please enter choose[1-8] or enter q to exit\033[0m" 
            sleep 2
            menu_tools
            ;;
    esac
}

menu_main
