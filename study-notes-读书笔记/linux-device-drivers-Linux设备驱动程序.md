ldd3代码：[https://resources.oreilly.com/examples/9780596005900/](https://resources.oreilly.com/examples/9780596005900/)

centos4.8找不到内核解决办法：`ln -s /usr/src/kernels/2.6.10/ /lib/modules/2.6.10/build`

centos4.8发行版下载网站：[https://vault.centos.org/4.8/](https://vault.centos.org/4.8/)

centos4.8安装包下载网址：[https://vault.centos.org/4.8/os/SRPMS/](https://vault.centos.org/4.8/os/SRPMS/)

centos4.8安装Development Tools: 

```shell
# 如果报错解决方法：rpm -e redhat-lsb-3.0-8.EL
sudo yum --enablerepo=c4-media --noplugins groupinstall "Development Tools" -y
```

