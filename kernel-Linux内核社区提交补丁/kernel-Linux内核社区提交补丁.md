[toc]

# 内核社区

Linux内核主要以邮件交流为主。

[社区主页](https://www.kernel.org/)

[patchwork](https://lore.kernel.org/patchwork/project/lkml/list/)

[按模块划分的patchwork](https://patchwork.kernel.org/)

[bugzilla](https://bugzilla.kernel.org/)

git clone linux-next仓库代码：
```shell
git clone https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
```

# git发送patch

## 163邮箱配置

此处以163邮箱为例，说明邮箱的配置方法，其他邮箱类似。

默认情况下，163邮箱只能在网页和网易邮箱大师登录。如果要用git通过163邮箱发送邮件则需要对163邮箱进行配置。

在[网页](mail.163.com)登录163邮箱，点击“设置 --> POP3/SMTP/IMAP”，开启SMTP服务，会弹出授权密码窗口，记下这个授权密码（也可以在下方新增授权密码或删除），如下图所示：

![163邮箱配置](https://gitee.com/lioneie/blog/raw/master/kernel-Linux%E5%86%85%E6%A0%B8%E7%A4%BE%E5%8C%BA%E6%8F%90%E4%BA%A4%E8%A1%A5%E4%B8%81/163%E9%82%AE%E7%AE%B1%E9%85%8D%E7%BD%AE.png)

## 生成patch

以下命令会生成补丁文件：
```shell
# 最后一次commit，next表示linux-next仓库（非必须）
git format-patch --subject-prefix="PATCH next" -1

# 指定commit号
git format-patch --subject-prefix="PATCH next" -1 commit号

# 如果是第2个版本或第3个版本，需要指定v2或v3
git format-patch --subject-prefix="PATCH next,v2" -1

# 如果内容不变，重新发送（比如加一个抄送的人）
git format-patch --subject-prefix="PATCH next,resend,v2" -1

# 从指定的commit号数向前3个，共生成3个补丁
git format-patch --subject-prefix="PATCH next,resend,v2" -3 commit号

# 生成补丁集
git format-patch --subject-prefix="PATCH next,resend,v2" -3 commit号 --cover-letter
# 编辑0000-cover-letter.patch, 可参考patchwork上其他补丁的写法
vim 0000-cover-letter.patch
```

## git发送邮件

安装：
```shell
sudo yum install git-email -y
```
`vim ~/.gitconfig`：
```
[user]
	email = lioneie@163.com
	name = ChenXiaoSong
[core]
	editor = vim 
	quotepath = false
[sendemail]
	from = lioneie@163.com
	smtpserver = smtp.163.com
	smtpuser = lioneie@163.com
	smtpencryption = ssl 
	smtppass = 此处填写163邮箱的授权密码
	smtpserverport = 994 
```
获取maintainer邮箱：
```shell
./scripts/get_maintainer.pl 补丁文件
```
发送邮件：
```shell
git send-email -to 收件人 -cc 抄送人 补丁文件（可多个）
```
