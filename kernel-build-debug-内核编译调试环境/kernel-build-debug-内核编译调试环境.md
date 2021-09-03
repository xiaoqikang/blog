[toc]

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

qemu-system-x86_64 \
        -enable-kvm \
        -smp 8 \
        -m 4096 \
        -kernel bzImage \
        -device virtio-scsi-pci \
        -net nic,model=virtio,macaddr=DE:AD:BE:EF:00:00 \
        -net bridge,br=virbr0 \
        -drive file=fedora34-server.img,if=none,cache=none,id=root,format=raw,file.locking=off \
        -device virtio-blk,drive=root,id=d_root \
        -append "quiet console=ttyS0 IP=192.168.122.2 root=/dev/vda1 rw kmemleak=on" \
        -nographic
```

```shell
# 启动的时候等待： A start job is running for /dev/zram0，解决办法：删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak

mkfs.ext4 -b 4096 -F /dev/sda
mkfs.ext4 -b 4096 -F /dev/sdb
```