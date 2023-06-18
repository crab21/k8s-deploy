# apt offline

## make offline package

```sh
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances socat conntrack iptables | grep "^\w" | sort -u)

mkdir archives

dpkg-scanpackages ./ /dev/null | gzip > ./archives/Packages.gz -r

tar jcvf ../apt.tar.bz2 .
```

## install on offline machine

after upload the bz2 from step above,

```sh
mkdir /tmp/apt && tar jxvf apt.tar.bz2 -C /tmp/apt

mv /etc/apt/sources.list /etc/apt/sources.list.bak

echo "deb [trusted=yes] file:///tmp/apt/ archives/" > /etc/apt/sources.list

apt update && apt install -y socat conntrack iptables

mv /etc/apt/sources.list.bak /etc/apt/sources.list
```
