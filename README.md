

如果目录下没有go、ipfs、ipfs-cluster的安装包，可以执行

```
    download.sh 
```


如果没有安装go，第一个参数是可选的，它可以让你在安装时指定工作目录，如果没有指定则在根目录下
创建/.go/workspace，go get与go install都会将包存在该工作目录下

```
    install-go.sh  [gopathdir]
```

安装ipfs前必须先生成swarm.key 

```
    echo "/key/swarm/psk/1.0.0/" > swarm.key
    echo "/base16/" >> swarm.key
    od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' >> swarm.key

```

安装ipfs可以设置第一个参数，第一个参数为ipfs项目挂载点，
这个是可选的，如果没有的话就会挂载到根目录下，创建/ipfs/.ipfs/，ipfs所有的数据都存在该目录下

```
    mount /dev/sdb /ipfs-data
    install-ipfs.sh /ipfs-data/.ipfs/
```
如果
```
    install-ipfs.sh
```
则挂载目录为/ipfs/.ipfs


安装ipfs-cluster前确保必须先装好ipfs，同时生成cluster.key

```
    od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' > cluster.key
```

安装ipfs-cluster可以设置第一个参数，参数为bootstrap的引导节点，
这是可选的，如果没有的话则当前节点会被视作为主节点

```
    install-cluster.sh [/ip4/192.168.226.11/tcp/4001/p2p/12D3KooWPmpZg91xbfpnrBZRsMgGgzZsqzCUzQgYQXY46LLmA6yW]
```