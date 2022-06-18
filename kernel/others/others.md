[toc]

# 缓存与脏页

```shell
echo 1 > /proc/sys/vm/drop_caches # 清空缓存
/proc/sys/vm/dirty_background_ratio # 默认总内存的 10%
# 脏页最大时长,默认 3000 厘秒 = 30 秒
/proc/sys/vm/dirty_expire_centisecs
/proc/sys/vm/dirty_background_bytes # 单位: 字节
```

# FILE 和 文件描述符

```c
FILE *fp = fopen("file");
int fd = fileno(fp);
fsync(fd);

int fd = open("file", O_CREAT | O_RDWR, 0700);
FILE *fp = fdopen(fd, "r"); // mode 字符串格式请参考 fopen()
```

# tcpdump

```shell
tcpdump -B 20480 -w cli.cap # 默认4KB, 单位 KB, 20480 代表 20MB
# 先用 sysctl -a | grep net.core.rmem 查看
sysctl net.core.rmem_default=xxx
sysctl net.core.rmem_max=xxx
```

# perf

```shell
perf ftrace -a -G nfs_getattr > ftrace # 查看调用时间
```

# hung task

```shell
/proc/sys/kernel/hung_task_warning
/proc/sys/kernel/hung_task_panic
/proc/sys/kernel/hung_task_timeout_secs
```

```c
check_hung_task
```