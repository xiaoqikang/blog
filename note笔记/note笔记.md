[toc]

本文章没有什么高大上的内容，只是一些笔记，方便日后查询。

# git仓库迁移

git远程仓库迁移时，当有多个分支时，需要一个一个分支上传，不仅耗时又容易出错。

可以使用脚本批量操作，执行命令 `bash git_push_all_branch.sh 远程仓库路径`，脚本`git_push_all_branch.sh`如下：

```shell
case "$1" in
	"")
		echo "Usage: bash $0 { url }"
		exit 2
	;;
esac

git remote set-url origin "$1"

for branch in `git branch -a | grep remotes | grep -v HEAD`; do
	git branch --track ${branch##*/} $branch
done

git push origin --mirror
```

# 修改git的默认编辑器为vim

`git config --global core.editor vim`

# fedora33无法ssh到低版本系统（如centos4.8）

在Fedora33系统下`vim ~/.ssh/config` 添加以下内容

```
Host *
KexAlgorithms +diffie-hellman-group1-sha1
```

然后再更改权限：`sudo chmod 600 config`

或者使用命令: `ssh -oHostKeyAlgorithms=+ssh-dss -oKexAlgorithms=+diffie-hellman-group1-sha1  root@192.168.122.40`

# shell ctrl+s锁死解决办法

shell搜索历史命令，ctrl+r搜索更早的历史命令，但ctrl + s搜索更新的历史命令会锁死，可输入**`stty -ixon`**解决。

# 内核告警修复

安装[coccinelle](https://coccinelle.gitlabpages.inria.fr/website/)：

```shell
$ sudo yum install coccinelle -y
```

执行检查：

```shell
# M=目录名
$ make coccicheck -j16 M=kernel/sched/ > tmp
```

[syzkaller.appspot.com/upstream](https://syzkaller.appspot.com/upstream)

# 查看cpu核数

```shell
[sonvhi@localhost ~]$ lscpu
Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
Address sizes:                   48 bits physical, 48 bits virtual
# 逻辑cpu个数 = 物理cpu个数 * 每颗物理cpu的核数 * 超线程数
CPU(s):                          16
On-line CPU(s) list:             0-15
# 超线程数（每个核心线程）
Thread(s) per core:              2
# 每颗物理cpu的核数（每个cpu插槽核数）
Core(s) per socket:              8
# 物理cpu个数（cpu插槽数）
Socket(s):                       1
...
```

# 编译内核

```shell
# menuconfig错误时需要安装
sudo yum install ncurses-devel -y
make oldconfig
make bzImage
make modules
make modules_install
make install

# 以下内容可能不需要
# 2.6.34在这里要建立/boot/config的软链接
# 后面的2.6.10表示/lib/modules下面的一个目录-也就是版本号，2.6.34编译 去掉-o，用-v
mkinitrd -o /boot/initrd.img-2.6.10 2.6.10
vim /boot/grub/menu.lst
```

# ubuntu老版本-ubuntu5.04

镜像源：[http://old-releases.ubuntu.com](http://old-releases.ubuntu.com)。

ubuntu5.04安装ncurses_devel（源码下载：[http://ftp.gnu.org/gnu/ncurses/ncurses-5.4.tar.gz](http://ftp.gnu.org/gnu/ncurses/ncurses-5.4.tar.gz)）：

```shell
./configure --with-shared --without-debug --without-ada --enable-overwrite
make
make install
```

ubuntu5.04挂载nfs：

```shell
sudo apt-get install nfs-kernel-server -y
# 服务端（ubuntu5.04）配置：
# 添加内容：开始/ *(insecure,rw,no_root_squash,no_all_squash,sync)结束
# 也可以尝试： 开始 / client ip(insecure,rw,no_root_squash,no_all_squash,sync)  结束
sudo vim /etc/exports 
# 客户端：
sudo mount -o v3 -t nfs server ip:/ ./ldd3/ -o nolock
# 遇到过nfs很久连不上（但最后可以连上），如果重启真实机可能可以(不确定，可以尝试)
```

# ubuntu18.04在kvm qemu中无法分配ip

ifconfig -a 查看网卡名称

在/etc/netplan/50-cloud-init.yaml把网卡名称修改成正确名称

sudo netplan apply

# fedora33无法访问小米手机

报错unable to open mtp device

sudo yum install simple-mtpfs -y

# TODO：用栈实现加减乘除

TODO

# TODO：跳跃链表

TODO

# TODO：TCP三次握手和四次挥手

TODO

# TODO：systemd配置文件

type

TODO

# TODO：＃pragma

TODO