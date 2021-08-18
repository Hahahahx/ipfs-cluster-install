#!/bin/bash

function ifExit() {
    if [ $1 -eq $2 ]; then
        echo "退出"
        exit 1
    fi
}

function detectCommand() {
    if hash $1 2>/dev/null; then
        echo "=> $1已经安装 √"
        return 1
    else
        echo "=> $1尚未安装 ×"
        # ipfs not found
        return 0
    fi
}

function setEnv() {
    echo "export $1" >>/etc/profile
    source /etc/profile
    echo "=> 添加环境变量$1"
}

function systemctlDaemon() {
    systemctl daemon-reload
    systemctl enable $1
    systemctl start $1
    systemctl status $1
}

function getIp() {
    for line in $(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:"); do
        echo "$line"
        ip=$line
        break
    done
}

function include() {
    echo "$1 ~= $2"
    if [[ $1=~$2 ]]; then
        return 1
    else
        return 0
    fi
}

function createDir() {
    if ! [ -d $1 ]; then
        mkdir -p $1
    fi
}
