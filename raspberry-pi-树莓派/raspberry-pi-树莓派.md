[toc]

# 安装系统

从[网站](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)下载“Raspberry Pi OS with desktop and recommended software”。

向SD卡烧录系统：
```shell
sudo dd bs=4M if=解压之后的img of=/dev/sdb
```

# 软件安装

```shell
# 解决git无法显示中文
git config --global core.quotepath false

# 安装五笔，需要重启
sudo apt-get update -y
sudo apt install ibus*wubi* -y

# 安装firefox
sudo apt update -y
sudo apt-get install iceweasel -y

sudo apt update -y
# 安装emacs
sudo apt install emacs -y
# 安装gvim
sudo apt install vim-gtk3 -y
```

# firefox预览markdown

```shell
mkdir ~/.local/share/mime/packages/ -p
```
`~/.local/share/mime/packages/text-markdown.xml`文件内容：
```
<?xml version="1.0"?>
<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
  <mime-type type="text/plain">
    <glob pattern="*.md"/>
    <glob pattern="*.mkd"/>
    <glob pattern="*.markdown"/>
  </mime-type>
</mime-info>
```
```shell
update-mime-database ~/.local/share/mime
```
