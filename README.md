

如果目录下没有go、ipfs、ipfs-cluster的安装包，可以执行

```
    download.sh 
```


如果没有安装go

```
    install-go.sh   
```

安装ipfs前必须先生成swarm.key 

```
    echo "/key/swarm/psk/1.0.0/" > swarm.key
    echo "/base16/" >> swarm.key
    od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' >> swarm.key

```

安装ipfs可以设置第一个参数，第一个参数为ipfs项目挂载点，
这个是可选的，如果没有的话就会挂载到根目录下

```
    install-ipfs.sh [/dev/sdb]
```
则等价于
```
    mount /dev/sdb /ipfs
    install-ipfs.sh
```
挂载目录始终为/ipfs/.ipfs


安装ipfs-cluster前确保必须先装好ipfs，同时生成cluster.key

```
    od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' > cluster.key
```

安装ipfs-cluster可以设置第一个参数，参数为bootstrap的引导节点，
这是可选的，如果没有的话则当前节点会被视作为主节点

```
    install-cluster.sh [/ip4/192.168.226.11/tcp/4001/p2p/12D3KooWPmpZg91xbfpnrBZRsMgGgzZsqzCUzQgYQXY46LLmA6yW]
```