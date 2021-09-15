[toc]

openEuler nfs mount: https://gitee.com/src-openeuler/nfs-utils/issues/I46NSS?_from=gitee_search

fedora server 安装时， 根文件系统一定不能使用 LVM

```shell
sudo apt-get install libelf-dev libssl-dev -y
# 在 Virtual Machine Manager 中创建 qcow2 格式，会马上分配所有空间，所以需要在命令行中创建 qcow2
qemu-img create -f qcow2 fedora34-server.qcow2 512G
# allow virbr0
sudo vim /etc/qemu/bridge.conf
```

9p: https://wiki.qemu.org/Documentation/9psetup

```
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y (Optional)
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
CONFIG_PCI=y
CONFIG_VIRTIO_PCI=y
```

```shell
fallocate -l 10G 2
```

```shell
# 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak

# 格式化硬盘
mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb

[root@fedora ~]# cat /etc/exports
/root/ext4 *(rw,sync,fsid=0)

[root@fedora ~]# cat setup-nfs-svr.sh 
ulimit -n 65535
# iptables -F
exportfs -r
systemctl stop firewalld
setenforce 0
systemctl restart nfs-server.service
systemctl restart rpcbind

# nfsv4 挂载要用 192.168.122.87:/
mount -t nfs -o v4.1 192.168.122.87:/ nfs4/

# nfsv3 挂载
mount -t nfs -o v3 192.168.122.87:/root/ext4 nfs4/

# fedora26 安装 vim 前，先升级
sudo dnf update vim-common vim-minimal -y
```

```shell
[root@192 ~]# cat /lib/systemd/system/qemu-vm-setup.service
[Unit]
Description=QEMU VM Setup

[Service]
Type=oneshot
ExecStart=/root/qemu-vm-setup.sh

[Install]
WantedBy=default.target
```

```shell
[root@192 ~]# cat qemu-vm-setup.sh 
#!/bin/sh

dev=$(ip link show | awk '/^[0-9]+: en/ {sub(":", "", $2); print $2}')
ip=$(awk '/IP=/ { print gensub(".*IP=([0-9.]+).*", "\\1", 1) }' /proc/cmdline)

if test -n "$ip"
then
	gw=$(echo $ip | sed 's/[.][0-9]\+$/.1/g')
	ip addr add $ip/24 dev $dev
	ip link set dev $dev up
	ip route add default via $gw dev $dev
fi
```

挂载 qcow2
```shell
https://www.jianshu.com/p/6b977c02bfb2

sudo apt-get install qemu-utils


sudo qemu-nbd --connect=/dev/nbd0 fedora26-server.qcow2 
sudo fdisk /dev/nbd0 -l
sudo mount /dev/nbd0p1 mnt/
sudo umount mnt
sudo qemu-nbd --disconnect /dev/nbd0
```

xfstests:
yum -y install libtool -y
yum install libuuid-devel -y
yum install xfsprogs-devel -y
yum install libacl-devel -y

