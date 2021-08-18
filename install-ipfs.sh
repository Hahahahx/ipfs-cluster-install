#!/bin/bash

. ./sh/utils.sh

if ! [ -e swarm.key ]; then
    echo "请在目录下先生成swarm.key，确保集群后续的节点都会用到这个密钥，如果你不知道该怎么做，可以执行下列指令..."
    echo "go get -u github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen"
    echo "ipfs-swarm-key-gen > swarm.key"
    exit 1
fi

# 检查是否安装了，安装了就退出
detectCommand ipfs
ifExit $? 1

# 挂载磁盘目录（非必须）
MountDisk=$2

# GO111MODULE=on go get github.com/ipfs/ipfs-update
# detectCommand ipfs-update
# ipfs-update install latest

tar zxvf go-ipfs.gz
sh ./go-ipfs/install.sh

if ! [ $IPFS_PATH ]; then
    echo "=> 已经配置了IPFS_PATH=$IPFS_PATH"
else
    if [ -n "$MountDisk" ]; then
        mkdir /ipfs
        mount $MountDisk /ipfs
        echo "=> 挂载磁盘到 /ipfs"
    fi

    if ! [ -d "/ipfs/.ipfs" ]; then
        mkdir -p /ipfs/.ipfs
    fi

    setEnv IPFS_PATH=/ipfs/.ipfs
fi

ipfs init
cp swarm.key $IPFS_PATH

ipfs bootstrap rm --all

# 主节点不添加引导配置
# result=$(include $MasterNode $ip)

# echo $result

# if [ result == 0 ]; then
while read line; do
    include $line $(getIp)
    if [ $? -eq 0 ]; then
        ipfs bootstrap add $line
        echo "=> 添加引导：ipfs bootstrap add $line"
    fi
done <bootstrap.txt
# fi

export LIBP2P_FORCE_PENT=1

ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"*\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials "[\"true\"]"
ipfs config --json Addresses.API '"/ip4/0.0.0.0/tcp/5001"'
ipfs config --json Addresses.Gateway '"/ip4/0.0.0.0/tcp/8080"'
ipfs config --json Swarm.EnableRelayHop "true"

# 必须要加上该文件
# systemd读取不了/etc/profile中的环境变量
rm -rf /etc/sysconfig/ipfsd
cp ipfsd /etc/sysconfig/ipfsd

rm -rf /etc/systemd/system/ipfs.service
cp ipfs.service /etc/systemd/system/ipfs.service

systemctlDaemon ipfs
