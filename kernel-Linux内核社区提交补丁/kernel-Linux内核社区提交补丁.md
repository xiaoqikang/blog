
# 163邮箱配置

此处以163邮箱为例，说明邮箱的配置方法，其他邮箱类似。
默认情况下，163邮箱只能在网页和网易邮箱大师登录。如果要用git通过163邮箱发送邮件需要进行配置则需要对163邮箱进行配置。

在[网页](mail.163.com)登录163邮箱，点击“设置 --> POP3/SMTP/IMAP”，

```shell
sudo yum install git-email -y
```

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
