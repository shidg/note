#!/bin/bash
# File Name: -- backend.sh --
# author: -- shidegang --
# Created Time: 2024-10-16 13:37:16


#for ip  in 100 101 102 103 104 105
#for ip in {100..105}
#for ip in `seq 100 105`
for ip in $(seq 100 105)
    do
    { 
        #ping -c3 10.203.43.$ip >/dev/null
        #if [[ $? -eq 0 ]];then
        if  ping -c3 10.203.43.$ip >/dev/null;then
            echo "$ip is OK"
        else
            echo "$ip is  Not OK"
        fi
    } &
    done
wait   # 等待所有后台进程运行结束
echo -e "\r"

