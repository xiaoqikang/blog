# quiet: 不打印信息
# -append "quiet console=ttyS0 IP=192.168.122.2 root=/dev/vda1 rw kmemleak=on" \
qemu-system-x86_64 \
	-enable-kvm \
	-smp 8 \
	-m 2048 \
	-kernel bzImage \
	-device virtio-scsi-pci \
	-net nic,model=virtio,macaddr=DE:AD:BE:EF:00:03 \
	-net bridge,br=virbr0 \
	-drive file=centos7.9-ext4.qcow2,if=none,cache=none,id=root,format=qcow2,file.locking=off \
	-device virtio-blk,drive=root,id=d_root \
	-drive file=1,if=none,format=raw,id=dd_1 \
	-device scsi-hd,drive=dd_1,id=disk_1 \
	-drive file=2,if=none,format=raw,id=dd_2 \
	-device scsi-hd,drive=dd_2,id=disk_2 \
	-append "console=ttyS0 IP=192.168.122.3 root=/dev/vda1 rw kmemleak=on" \
	-nographic \
	--virtfs local,id=kmod_dev,path=/home/sonvhi/chenxiaosong/code/,security_model=none,mount_tag=modules
