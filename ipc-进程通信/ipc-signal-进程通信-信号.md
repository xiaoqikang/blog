本文章的内容绝大多取材于以下书籍：

>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

信号是Unix和Linux系统响应某些条件而产生的一个事件。

查看信号列表使用以下命令：

```shell
kill -l
```

# 处理信号

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
        printf("我爱Linux内核，快按ctr+c\n\r");
        sleep(1);
    }
    return 0;
}
```

# 发送信号

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

struct sigaction
{
    union
    {   
    	__sighandler_t sa_handler;
    	void (*sa_sigaction) (int, siginfo_t *, void *); 
    }   
    __sigaction_handler;
    __sighandler_t sa_handler;
    __sigset_t sa_mask;
    int sa_flags;
    void (*sa_restorer) (void);
};  

```

# 信号集

信号集操作就不详细讲了，仅列出函数：

```c
#include <signal.h>

int sigaddset(sigset_t *set, int signo);
int sigemptyset(sigset_t *set);
int sigaddset(sigset_t *set);
int sigfillset(sigset_t *set);
int sigdelset(sigset_t *set, int signo);

int sigismember(sigset_t *set, int signo);
int sigprocmask(int how, const sigset_t *set, sigset_t *oset);
int sigpending(sigset_t *set);
int sigsuspend(sigset_t *sigmask);
```

