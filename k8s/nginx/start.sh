#!/bin/bash
# File Name: -- start.sh --
# author: -- shidegang --
# Created Time: 2024-08-19 15:57:00
trap_oom() {
    while true
    do
        sleep 1
        echo 111>>/tmp.txt
    done
}

trap_oom &

nginx -g "daemon off;"
