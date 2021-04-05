作为程序员，使用google搜索当然是必不可少的，如果使用百度搜索在绝大多数情况下只会得到一些广告。

本文档的编写目的是为了下次重新搭建代理服务器时的查询。

v2ray的github项目为[v2ray-core](https://github.com/v2fly/v2ray-core)。

安装说明请参考[install.md](https://github.com/v2fly/manual/blob/master/zh_cn/chapter_00/install.md)。

# v2ray服务器安装与配置

使用以下命令安装：

```shell
bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

或下载编译好的安装包[v2ray-linux-64.zip](https://github.com/v2fly/v2ray-core/releases/download/v4.36.2/v2ray-linux-64.zip)。

将`/usr/local/etc/config.json`的内容替换成[server_config.json](https://github.com/lioneie/csdn/blob/master/v2ray%E4%BB%A3%E7%90%86%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%90%AD%E5%BB%BA/server_config.json)中的内容，并修改以下内容

```json
...
3 "port": 55555,	//可修改端口
...
8 "id": "e04ff980-2736-4a2c-853a-43e21bbd6dea",		//可自定义id
...
```

修改完配置文件后，需要重启v2ray服务：

```json
sudo systemctl restart v2ray
```

# linux系统客户端安装与配置

使用以下命令安装：

```shell
bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

或下载编译好的安装包[v2ray-linux-64.zip](https://github.com/v2fly/v2ray-core/releases/download/v4.36.2/v2ray-linux-64.zip)。

将`/usr/local/etc/config.json`的内容替换成[client_config.json](https://github.com/lioneie/csdn/blob/master/v2ray%E4%BB%A3%E7%90%86%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%90%AD%E5%BB%BA/client_config.json)中的内容，并修改以下内容：

```json
...
51        "address": "请填写服务器ip", // 服务器地址，请修改为你自己的服务器 ip 或域名
52        "port": 55555,  // 服务器端口
53        "users": [{ 
54			"id": "e04ff980-2736-4a2c-853a-43e21bbd6dea",	// 与服务器id一样
...
```

修改完配置文件后，需要重启v2ray服务：

```json
sudo systemctl restart v2ray
```

我用的操作系统是Fedora，配置如下图所示（其他Linux发行版也大同小异）：

![fedora v2ray客户端配置](https://img-blog.csdnimg.cn/20210405160238570.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center)

# macOS系统客户端安装与配置

macOS系统的v2ray客户端的github项目为[Cenmrev/V2RayX](https://github.com/Cenmrev/V2RayX)，包装包为[V2RayX.app.zip](https://github.com/Cenmrev/V2RayX/releases/download/v1.5.1/V2RayX.app.zip)。

安装完成后的配置如下图：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210405164155557.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpb241NDQzMDE=,size_16,color_FFFFFF,t_70#pic_center)

# Windows系统客户端安装与配置

sorry，我不用Windows系统。