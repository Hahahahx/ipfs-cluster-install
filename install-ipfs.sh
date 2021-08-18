#!/bin/bash

. ./sh/utils.sh

if ! [ -e swarm.key ]; then
    echo "请在目录下先生成swarm.key，确保集群后续的节点都会用到这个密钥，如果你不知道该怎么做，可以执行下列指令..."
    echo "echo \"/key/swarm/psk/1.0.0/\" > swarm.key"
    echo "echo \"/base16/\" >> swarm.key"
    echo "od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' >> swarm.key"
    exit 1
fi

# 检查是否安装了，安装了就退出
detectCommand ipfs
ifExit $? 1

# GO111MODULE=on go get github.com/ipfs/ipfs-update
# detectCommand ipfs-update
# ipfs-update install latest

tar zxvf go-ipfs.gz
sh ./go-ipfs/install.sh

if ! [ $IPFS_PATH ]; then
    echo "=> 已经配置了IPFS_PATH=$IPFS_PATH"
else
    # 判断是否自定义了挂载目录
    if [ -n "$1" ]; then
        createDir $1
        setEnv IPFS_PATH=$1
    else
        createDir /ipfs/.ipfs
        setEnv IPFS_PATH=/ipfs/.ipfs
    fi

fi

ipfs init
cp swarm.key $IPFS_PATH

ipfs bootstrap rm --all

# 添加引导配置
while read line; do
    # 过滤当前节点
    include $line $(getIp)
    if [ $? -eq 0 ]; then
        ipfs bootstrap add $line
        echo "=> 添加引导：ipfs bootstrap add $line"
    fi
done <bootstrap

export LIBP2P_FORCE_PENT=1

ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"*\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials "[\"true\"]"
ipfs config --json Addresses.API '"/ip4/0.0.0.0/tcp/5001"'
ipfs config --json Addresses.Gateway '"/ip4/0.0.0.0/tcp/8080"'
# 允许作为中间节点转发数据
ipfs config --json Swarm.EnableRelayHop "true"
# 允许被中间节点发现转发数据
ipfs config --json Swarm.EnableAutoRelay "true"

# 必须要加上该文件
# systemd读取不了/etc/profile中的环境变量
# 配置启动时需要的环境参数
echo "IPFS_PATH=/ipfs/.ipfs" >/etc/sysconfig/ipfsd
echo "LIBP2P_FORCE_PENT=1" >>/etc/sysconfig/ipfsd

cat ipfs.service >/etc/systemd/system/ipfs.service

systemctlDaemon ipfs
