本文章的内容绝大多取材于以下书籍：

>深入Linux内核-第3版 -- DANIEL P.BOVET & MARCO CESATI 著   陈莉君 张琼声  张宏伟 译
>
>Linux程序设计 第4版 -- [英] Neil Matthew & Richard Stones 著   陈健  宋健建 译

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