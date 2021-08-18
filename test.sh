function getIp() {
    for line in $(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:"); do
        echo $line
        break
    done
}

commands=ipfs-cluster-service

commandPath=$(whereis $commands | sed -e s/$commands://g)

echo $commandPath

# echo $ip

sed -i "7c ExecStart=$commandPath daemon" /etc/systemd/system/ipfs-cluster.service
