#!/bin/bash
. ./sh/utils.sh

# 如果有参数就覆盖安装
if ! [ -n "$1" ]; then
    # 检查是否安装了，安装了就退出
    detectCommand go
    ifExit $? 1
    createDir /.go/workspace/
    gopath=/.go/workspace/
else
    detectCommand go
    createDir $1
    gopath=$1
fi

rm -rf /usr/local/go/

tar -C /usr/local -zxvf go1.17.linux-amd64.tar.gz

setEnv GOROOT=/usr/local/go
setEnv GOPATH=$1

setEnv GOPROXY=https://goproxy.io,direct
setEnv 'PATH=$PATH:$GOROOT/bin:$GOPATH/bin'

source /etc/profile
export GOPATH=$1
