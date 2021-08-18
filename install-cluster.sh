#!/bin/bash

if ! [ -e cluster.key ]; then
    echo "请在目录下先生成cluster.key，确保集群后续的节点都会用到这个密钥，如果你不知道该怎么做，可以执行下列指令..."
    echo "od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' > cluster.key"
    exit 1
fi

. ./sh/utils.sh
MasterNode=$(ipfs id | grep tcp | grep ip4 | grep $(getIp) | sed 's/,//g')

if [ -n "$1" ]; then
    MasterNode=$1
fi

detectCommand ipfs
ifExit $? 0

#安装ipfs-cluster
cd ./ipfs-cluster
export GO111MODULE=on # optional, if checking out the repository in $GOPATH.

commands=(ipfs-cluster-service ipfs-cluster-ctl ipfs-cluster-follow)

for cmd in ${commands[@]}; do
    detectCommand $cmd
    if [ $? -eq 0 ]; then
        go install ./cmd/$cmd
        detectCommand $cmd
    fi
done
cd ..

detectCommand ipfs-cluster-service
ifExit $? 0

uuid=$(cat cluster.key)
setEnv CLUSTER_SECRET=$uuid

ipfs-cluster-service init

echo "CLUSTER_SECRET=$uuid" >/etc/sysconfig/ipfs-clusterd

rm -rf /etc/systemd/system/ipfs-cluster.service
cp ipfs-cluster.service /etc/systemd/system/ipfs-cluster.service

commandPath=$(whereis $commands | sed -e s/$commands://g)
# 判断当前节点是否是主节点
include $MasterNode $(getIp)
if [ $? -eq 0 ]; then
    echo "启动节点ipfs-cluster-service，引导主节点$MasterNode"

    sed -i "7c ExecStart=$commandPath daemon --bootstrap $MasterNode" /etc/systemd/system/ipfs-cluster.service
    # ipfs-cluster-service daemon --bootstrap '$MasterNode'
else
    echo "启动主节点ipfs-cluster-service，$MasterNode"
    sed -i "7c ExecStart=$commandPath daemon" /etc/systemd/system/ipfs-cluster.service
    # ipfs-cluster-service daemon
fi

systemctlDaemon ipfs-cluster
