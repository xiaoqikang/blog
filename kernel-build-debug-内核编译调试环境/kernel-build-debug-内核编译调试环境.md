[toc]

fedora server 安装时， 根文件系统一定不能使用 LVM

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
# 删除 zram 的配置文件
mv /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bak
```