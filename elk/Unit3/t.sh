#!/bin/bash
# File Name: -- t.sh --
# author: -- shidegang --
# Created Time: 2024-10-17 10:10:40

while true
    do
        ss -tnl | grep 80
        sleep 30
    done
