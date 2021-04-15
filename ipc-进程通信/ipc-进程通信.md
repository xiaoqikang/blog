本文章的内容绝大多取材于以下书籍：

>深入Linux内核-第3版 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译
>
>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

先介绍进程间的几种通信方式，最后再介绍线程的同步方式。

# 信号

信号是Unix和Linux系统响应某些条件而产生的一个事件。

查看信号列表使用以下命令：

```shell
kill -l
```

可以使用`signal`库函数来处理信号：

```c
#include <signal.h>
// 第二个参数也可以是SIG_IGN(忽略信号)、SIG_DFL(恢复默认行为)
void (*signal(int sig, void (*func)(int)))(int);
```

说实话，我看到上面这个函数的定义也晕，不怕，来个例子就简单了：

```c
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

// 信号处理函数
void ouch(int sig)
{
    printf("我靠！我捕获到一个信号：%d\n\r", sig);
    // 以下语句表示恢复默认行为，也就是下次再按ctr+c就会终止程序
    // 如果要忽略信号，可以使用(void)signal(SIGINT, SIG_IGN);
    (void)signal(SIGINT, SIG_DFL);
}

int main()
{
   	(void)signal(SIGINT, ouch);
    while(1)
    {
        printf("我爱Linux内核，但我还没捕获到信号\n\r");
        sleep(1);
    }
    return 0;
}
```

如果要向其他进程（当然也可以是自己）发送一个信号，可以使用以下函数：

```c
#include <sys/types.h>
#include <signal.h>
// 发送成功返回0
int kill(pid_t pid, int sig);
```

用户态的闹钟功能就用到了信号：

```c
#include <unistd.h>
unsigned int alarm(unsigned int seconds);
```

pause函数会把进程挂起直到有一个信号出现：

```c
#include <unistd.h>
int pause(void);
```

X/Open和Unix规范推荐了一个更健壮的接口：

```c
#include <signal.h>
int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);
```

信号集操作就不详细讲了，仅列出函数：

```c
#include <signal.h>
int sigaddset(sigset_t *set, int signo);
sigemptyset、sigaddset、sigfillset、sigdelset
sigismember、sigprocmask、sigpending、sigsuspend
```

# 管道

管道只能在相关的程序之间传递数据：

```c
#include <stdio.h>
FILE *popen(const char *command, const char *open_mode);
int pclose(FILE *stream_to_close);
```

底层提供的`pipe`函数不需要启动一个shell来解释请求的命令，提供对读写数据的更多控制：

```c
#include <unistd.h>
// pipe函数的作用是创建一个管道
// 写到 file_descriptor[1]的所有数据都可以从 file_descriptor[0]读回来
// 如把1，2，3顺序写到 file_descriptor[1], 从 file_descriptor[0] 读取到的数据也是1，2，3的顺序
// 使用read和write读写file_descriptor[0]和file_descriptor[1];
int pipe(int file_descriptor[2]);
```

可以使用`dup`和`dup2`系统调用把管道用作标准输入和标准输出：

```c
#include <unistd.h>
// 返回值为新创建的文件描述符
// 创建的新文件描述符与 oldfd 指向同一个文件（或管道），新文件描述符取最小的可用值
// 如果 标准输入描述符0 已经关闭[close(0)]，则调用dup后新的文件描述符就是0
int dup(int oldfd);
// 返回值为新创建的文件描述符
// 新创建的文件描述符数值与newfd相同，或是第一个大于newfd的可用值
int dup2(int oldfd, int newfd);
```

# 命名管道：FIFO

TODO

# 信号量

TODO

# 共享内存

TODO

# 消息队列

TODO

# 套接字

TODO

# POSIX线程同步

TODO