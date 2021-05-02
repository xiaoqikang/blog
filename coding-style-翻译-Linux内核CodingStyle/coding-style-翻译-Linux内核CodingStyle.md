[toc]

> 本文是翻译自[内核源码](https://github.com/lioneie/linux)（forked from [torvalds/linux](https://github.com/torvalds/linux)）的[Documentation/process/coding-style.rst](https://github.com/lioneie/linux/blob/master/Documentation/process/coding-style.rst)（Latest commit [b7592e5](https://github.com/lioneie/linux/commit/b7592e5b82db19b72a34b471f3296ad3f651c8b9)  on 2021 Feb 12）。
>
> 网上虽然已经有很多人做了很好的翻译，但我还是想自己翻译一次最新的编码风格（当然，我借助了谷歌翻译），让自己加深印象。
>
> 注意：如果你在**CSDN**等网站上看到这篇文章，可能会看到一个Tabs键显示成4个字符宽度而不是8个字符的宽度。在[github](https://github.com/lioneie/blog/blob/master/coding-style-%E7%BF%BB%E8%AF%91-Linux%E5%86%85%E6%A0%B8CodingStyle/coding-style-%E7%BF%BB%E8%AF%91-Linux%E5%86%85%E6%A0%B8CodingStyle.md)上查看这篇文章时一个Tabs键就会是8个字符的宽度。

如果发现有看不懂的地方，不用怀疑，是我翻译得不对，请告诉我：lioneie@163.com。

注意，翻译进行中，还未全部完成。

# Linux内核编码风格

这是一个简短的文档，描述了Linux内核的首选编码样式。 编码风格非常个人化，我不会对任何人**强加**我的见解，但这是我必须要维护的代码（指Linux内核代码）的编码风格，对于其他项目代码，我也希望使用它。 写内核代码时请至少考虑本文提出的风格。

首先，我建议打印出GNU编码标准，然后不要阅读。 烧掉它们，这是一个很棒的象征性动作。

无论如何，我们开始：

## 1) 缩进

制表符（Tab键）是8个字符，因此缩进也是8个字符。 有一些异端做法试图使制表符变成4个（甚至2个！）字符，这类似于尝试将PI的值定义为3。

理由：缩进的目的是明确定义控制块的开始和结束位置。 特别是当您连续看了20个小时的屏幕后，如果缩进较大则作用更大（指更容易分辨缩进）。

现在，有些人会声称具有8个字符的缩进会使代码向右移得太远，并使得在80个字符的终端屏幕上难以阅读。 答案是，如果您需要三个以上的缩进级别，那么无论如何你的代码有问题了，应该修复程序。

简而言之，8字符缩进使内容更易于阅读，并具有在嵌套函数太深时发出警告的作用。 注意该警告。

缓解`switch`语句中多个缩进级别的首选方法是在同一列中对齐`switch`及其从属`case`标签，而不是对`case`标签进行两次缩进。 例如：

```c
switch (suffix) {
case 'G':
case 'g':
	mem <<= 30;
	break;
case 'M':
case 'm':
	mem <<= 20;
	break;
case 'K':
case 'k':
	mem <<= 10;
	fallthrough;
default:
	break;
}
```

除非要隐藏某些内容，否则不要在一行上放置多个语句：

```c
if (condition) do_this;
  do_something_everytime;
```

不要使用逗号来避免使用花括号：

```c
if (condition)
	do_this(), do_that();
```

始终对多个语句使用花括号：

```c
if (condition) {
	do_this();
	do_that();
}
```

也不要将多个赋值语句放在一行上。 内核编码风格非常简单。 避免使用棘手的表达式。

除了注释，文档和Kconfig外，空格都不用于缩进，前面的例子是故意的。

选用一个好的编辑器，不要在行尾留空格。

## 2) 把长的行和字符串打散


编码风格是关于使用通用工具来维持可读性和可维护性。

单行长度的首选限制是80列。

长度超过80列的语句应分为合理的片段，除非超过80列会显着提高可读性且不会隐藏信息。

后面的片段应该短于原来的语句，并且基本上位于靠右放置。 一个典型的例子是将后面的片段与函数左括号对齐。

这些相同的规则适用于带有长参数列表的函数头，如下所示：

```c
// 注意：这个例子是我（陈孝松）写的
void func(int a, int b, int c, int d, int e, int f, int g, int h, int i
          int j, int k)
{
	...
｝
```

但是，切勿破坏诸如printk消息之类的用户可见的字符串，因为这会破坏grep为它们显示的功能。

## 3) 大括号和空格的放置

### 3.1) 大括号

C样式中经常出现的另一个问题是大括号的位置。 与缩进尺寸不同，没有什么技术上的原因可以选择一种放置策略而不是另一种，但是正如Kernighan和Ritchie向我们展示的，首选方式是将起始大括号放在行尾，然后将结束大括号放在行首，所以：

```c
if (x is true) {
	we do y
}
```

这适用于所有非函数语句块（if, switch, for, while, do）。 例如：

```c
switch (action) {
case KOBJ_ADD:
	return "add";
case KOBJ_REMOVE:
	return "remove";
case KOBJ_CHANGE:
	return "change";
default:
	return NULL;
}
```

但是，有一个特殊情况，即函数：在下一行的开头放置起始大括号，因此：

```c
int function(int x)
{
	body of function
}
```

全世界的异端人士都声称这种不一致性是……嗯……是不一致的，但是所有思维健全的人都知道（a）K＆R是**正确**的，（b）K＆R是正确的。 此外，函数是很特殊的（在C语言中函数是不能嵌套的）。

> 陈孝松注：K & R：《The C Programming Language》一书的作者Kernighan和Ritchie

请注意，结束大括号单独一行，**除非**在其后跟着同一条语句的剩余部分，也就是`do`语句中的`while`，或者`if`语句中的`else`，例如：

```c
do {
	body of do-loop
} while (condition);
```

还有

```c
if (x == y) {
	..
} else if (x > y) {
	...
} else {
	....
}
```

理由：K＆R。

另外，请注意，这种大括号的放置方式还可以最大程度地减少空（或几乎空）行的数量，而不会损失任何可读性。 因此，由于屏幕上的新行是不可再生资源（请考虑25行的终端屏幕），因此您有更多的空行可以放置注释。

在单个语句使用的地方，不用加不必要的大括号。

```c
if (condition)
	action();
```

和

```c
if (condition)
	do_this();
else
	do_that();
```

如果条件语句的只有一个分支是单个语句，则不适用； 这时请在两个分支中都使用大括号：

```c
if (condition) {
	do_this();
	do_that();
} else {
	otherwise();
}
```

另外，当循环中包含了多个单行的简单语句时，请使用大括号：

```c
while (condition) {
	if (test)
		do_something();
}
```

### 3.2) 空格

Linux内核使用空格的方式（主要）取决于是用于函数还是关键字。 （大多数）在关键字之后加一个空格。 值得注意的例外是`sizeof`，`typeof`，`alignof`和**`attribute`**，它们看起来有点像函数（并且在Linux中通常与小括号一起使用，尽管它们在语言中不是必需的，例如：`struct fileinfo info;`声明后的`sizeof info`） 。

因此，在这些关键字之后加一个空格：

```c
if, switch, case, for, do, while
```

但不能在`sizeof`，`typeof`，`alignof`或**`attribute`**之后加空格。 例如：


```c
s = sizeof(struct file);
```

不要在小括号的表达式两侧（内部）添加空格。 这是**反例**：


```c
s = sizeof( struct file );
```

在声明指针数据类型或返回指针类型的函数时，`*`的首选用法是与数据名称或函数名称相邻，而不与类型名称相邻。 例子：


```c
char *linux_banner;
unsigned long long memparse(char *ptr, char **retptr);
char *match_strdup(substring_t *s);
```

在大多数二元和三元运算符的两侧（每边）使用一个空格，例如以下任意一个：

```c
=  +  -  <  >  *  /  %  |  &  ^  <=  >=  ==  !=  ?  :
```

但一元运算符后不要加空格：

```c
&  *  +  -  ~  !  sizeof  typeof  alignof  __attribute__  defined
```

后缀递增和递减一元运算符前没有空格：

```c
++  --
```

前缀递增和递减一元运算符后没有空格：

```c
++  --
```

`.`和`->`结构成员操作符前后没有空格。

不要在行尾留空格。 某些具有`智能`缩进的编辑器将在适当的情况下在新行的开头插入空格，因此您可以立即开始键入下一行代码。 但是，如果没有在这一行输入代码，则某些编辑器不会删除空格，就像你留下一个只有空白的行。 结果，行尾带有空格的行就产生了。

当git发现补丁包含了行尾空格的时候会警告你，并且可以有选择地为你去掉尾随空格； 但是，如果打一系列补丁，这样做会导致后面的补丁失败，因为你改变了补丁的上下文。

## 4) 命名

C是一种简朴的语言，你的命名也应是这样。 与Modula-2和Pascal程序员不同，C程序员不会使用诸如`ThisVariableIsATemporaryCounter`之类的可爱名称。 C程序员将该变量命名为`tmp`，该变量更容易编写，而且更容易理解。

但是，虽然不赞成使用大小写混合的名称，但全局变量还是需要使用具备描述性的名称。 把全局函数命名为`foo`是一种难以饶恕的错误。

**全局**变量（仅在**确实**需要它们时才使用）与全局函数一样，都需要具有描述性名称。 如果您有一个统计活动用户数量的函数，则应命名为`count_active_users()`或类似名称，而**不应该**命名为`cntusr()`。

在函数名中包含函数类型（所谓的匈牙利命名法）是愚蠢的 - 编译器知道类型而且能够检查类型，这样做只能把程序员弄糊涂。

> 陈孝松注：这里曾经还有一句话：**难怪微软总是制造出有问题的程序**。在2021年2月12日这句话被删除了。

**局部**变量名称应简短明了。 如果您有一些随机整数循环计数器，则应命名为`i`。 如果没有可能被误解，则命名为`loop_counter`是无用的。 同样，`tmp`可以用来命名任意类型的临时变量。

如果您害怕混淆您的局部变量名称，那么您会遇到另一个问题，称为叫做函数增长荷尔蒙失衡综合症（function-growth-hormone-imbalance syndrome）。 请参见第6章（函数）。

对于符号名称和文档，请避免引入“主/从”（或独立于“主”的“从”）和“黑名单/白名单”的新用法。

推荐的“主/从”（'master / slave'）替代方案是：

```
'{primary,main} / {secondary,replica,subordinate}' '{initiator,requester} / {target,responder}' '{controller,host} / {device,worker,proxy}' 'leader / follower' 'director / performer'
```

推荐的“黑名单/白名单”（'blacklist/whitelist'）替代方案是：

```
'denylist / allowlist' 'blocklist / passlist'
```

引入新用法的例外情况是维护用户空间ABI/API，或者更新用于强制使用这些术语的现有（截至2020年）硬件或协议规范的代码。 对于新规范，尽可能将术语的规范用法转换为内核编码标准。

## 5) typedef

请不要使用`vps_t`之类的东西。 对结构体和指针使用`typedef`是**错误**的。 当你看到


```c
vps_t a;
```

出现在代码中，是什么意思？ 相反，如果这样

```c
struct virtual_container *a;
```

你就知道`a`是什么了。

许多人认为`typedef`**有助于提高可读性**。 不是这样的。它们仅在下列情况下有用：

> 1. 完全不透明的对象（这时typedef主动用于**隐藏**对象是什么）。
>
>    例如：`pte_t`等不透明对象，您只能使用适当的访函数来访问他们。
>
>    注意：不透明和`访问函数`本身并不好。 之所以使用诸如`pte_t`等类型的原因在于真的是**完全没有任何**共用的可访问信息。
>
> 2. 清楚的整数类型，这层抽象**有助于**避免混淆到底是`int`还是`long`。
>
>    `u8/u16/u32`是没问题的`typedef`，不过它们更符合(4)而不是这里。
>
>    再次注意：需要有一个**原因**。 如果某个变量类型是`unsigned long`，则没有必要这样
>
>    ```c
>    typedef unsigned long myflags_t;
>    ```
>
>    但是，如果有明确的原因，比如有些情况可能是``unsigned int``，而在其他情况下可能是``unsigned long``，那么一定要继续使用`typedef`。
>
> 3. 当您使用`sparse`从字面上创建用于类型检查的**新类型**时。
>
>    > 陈孝松注：sparse 诞生于 2004 年, 是由linus开发的, 目的就是提供一个静态检查代码的工具, 从而减少linux内核的隐患。
>
> 4. 在某些特殊情况下，与标准C99类型相同的新类型。
>
>    尽管眼睛和大脑只需要很短的时间就习惯了``uint32_t``这样的标准类型，但是仍然有人反对使用它们。
>
>    因此，Linux特有的等同于标准类型的``u8/u16/u32/u64``类型和它们的有符号类型是被允许的 -- 尽管它们在您自己的新代码中不是必需的。
>
>    编辑已使用了某类型集的现有代码时，应遵循该代码中的现有选择。
>
> 5. 可以在用户空间中安全使用的类型。
>
>    在用户空间可见的某些结构体中，我们不能要求C99类型而且不能用上面提到的``u32``类型。 因此，我们在与用户空间共享的所有结构体中使用`__u32`和类似的类型。

也许还有其他情况，但是基本的规则应该**永远不要**使用`typedef`，除非您可以明确符合上述规则中的一个。

通常，指针或结构体中的元素可以合理被访问到，那么就不应该是`typedef`。

## 6) 函数

函数应该简短而漂亮，并且只完成一件事。 它们应该一屏或两屏显示完（众所周知，`ISO/ANSI`屏幕大小为`80x24`），并且可以做一件事并且做好。

函数的最大长度与该函数的复杂度和缩进级数成反比。 因此，如果您有一个理论上很简单的函数，只是一个很长（但很简单）的`case`语句，那么需要在每个`case`语句做很多小事情，这样的函数可以很长。

但是，如果功能很复杂，并且怀疑天分不是很高的一年级高中生甚至可能根本不了解该函数的功能，则应该更加严格地遵守长度限制。 使用具有描述性名称的辅助函数（如果您认为它们的性能至关重要，则可以让编译器内联它们，效果比写一个复杂的函数要好）。

函数的另一种衡量标准是局部变量的个数。 它们不应超过5-10个，否则函数就有问题了。 重新考虑一下函数的实现，并将其拆分为更小的函数。 人脑通常可以轻松地跟踪约7种不同的事物，如果更多的话就会变得混乱。 即使你再聪明，你也可能会记不清两个星期前做过的事。

在源文件中，用一个空行分隔函数。 如果导出了该函数，则该函数的`EXPORT`宏应紧跟在结束大括号的下一行。 例如：

```c
int system_is_up(void)
{
	return system_state == SYSTEM_RUNNING;
}
EXPORT_SYMBOL(system_is_up);
```

在函数原型中，最好包含参数名称和其数据类型。 尽管C语言没要求必须这样做，但在Linux中提倡这样做，因为这样可以很简单的给读者提供更多的有价值的信息。

请勿将`extern`关键字与函数原型一起使用，因为这会使行更长，并且并非绝对必要。

## 7) 集中的函数退出途径

尽管某些人认为已过时，但是`goto`语句的等价物经常以无条件跳转指令的形式被编译器使用。

> 陈孝松注：**equivalent of the goto statement** 翻译为**`goto`语句的等价物**似乎不大通顺，如果你有更好的翻译请告诉我。

当函数从多个位置退出并且必须执行一些常规工作（例如清理）时，goto语句会派上用场。 如果不需要清理，则直接返回。

选择标签名称，要能说明goto的功能或goto存在的原因。 如果`goto`中转到释放`buffer`的地方，则标签名字为`out_free_buffer:`将是一个很好的例子。 避免使用诸如``err1:`` 和 ``err2:``之类的GW-BASIC名称，因为如果您添加或删除出口路径，则必须重新编号它们，并且它们无论如何都会使正确性难以验证。

> 陈孝松注：GW-BASIC是BASIC的一个方言版本，这个版本的BASIC最早是微软在1984年为康柏（2002年康柏公司被惠普公司收购）开发的。

使用gotos的基本原理是：

- 无条件语句更易于理解和跟踪
- 嵌套程度减少
- 防止在进行修改时忘记更新某个单独的退出点而导致错误
- 节省了编译器的工作，以优化冗余代码;)

```c
int fun(int a)
{
	int result = 0;
	char *buffer;

	buffer = kmalloc(SIZE, GFP_KERNEL);
	if (!buffer)
		return -ENOMEM;

	if (condition1) {
		while (loop1) {
			...
		}
		result = 1;
		goto out_free_buffer;
	}
	...
out_free_buffer:
	kfree(buffer);
	return result;
}
```

要注意的一种常见错误是 ``one err bugs`` ，如下所示：

```c
err:
	kfree(foo->bar);
	kfree(foo);
	return ret;
```

此代码中的错误是在某些出口路径上`foo`为`NULL`。 通常，此问题的解决方法是将其分为两个错误标签``err_free_bar:`` 和err_free_foo:``：

```c
 err_free_bar:
	kfree(foo->bar);
 err_free_foo:
	kfree(foo);
	return ret;
```

理想情况下，您应该模拟错误以测试所有出口路径。

## 8) 注释

Comments are good, but there is also a danger of over-commenting.  NEVER
try to explain HOW your code works in a comment: it's much better to
write the code so that the **working** is obvious, and it's a waste of
time to explain badly written code.

Generally, you want your comments to tell WHAT your code does, not HOW.
Also, try to avoid putting comments inside a function body: if the
function is so complex that you need to separately comment parts of it,
you should probably go back to chapter 6 for a while.  You can make
small comments to note or warn about something particularly clever (or
ugly), but try to avoid excess.  Instead, put the comments at the head
of the function, telling people what it does, and possibly WHY it does
it.

When commenting the kernel API functions, please use the kernel-doc format.
See the files at :ref:`Documentation/doc-guide/ <doc_guide>` and
``scripts/kernel-doc`` for details.

The preferred style for long (multi-line) comments is:

.. code-block:: c

	/*
	 * This is the preferred style for multi-line
	 * comments in the Linux kernel source code.
	 * Please use it consistently.
	 *
	 * Description:  A column of asterisks on the left side,
	 * with beginning and ending almost-blank lines.
	 */

For files in net/ and drivers/net/ the preferred style for long (multi-line)
comments is a little different.

.. code-block:: c

	/* The preferred comment style for files in net/ and drivers/net
	 * looks like this.
	 *
	 * It is nearly the same as the generally preferred comment style,
	 * but there is no initial almost-blank line.
	 */

It's also important to comment data, whether they are basic types or derived
types.  To this end, use just one data declaration per line (no commas for
multiple data declarations).  This leaves you room for a small comment on each
item, explaining its use.

## 9) You've made a mess of it

That's OK, we all do.  You've probably been told by your long-time Unix
user helper that ``GNU emacs`` automatically formats the C sources for
you, and you've noticed that yes, it does do that, but the defaults it
uses are less than desirable (in fact, they are worse than random
typing - an infinite number of monkeys typing into GNU emacs would never
make a good program).

So, you can either get rid of GNU emacs, or change it to use saner
values.  To do the latter, you can stick the following in your .emacs file:

.. code-block:: none

  (defun c-lineup-arglist-tabs-only (ignored)
    "Line up argument lists by tabs, not spaces"
    (let* ((anchor (c-langelem-pos c-syntactic-element))
           (column (c-langelem-2nd-pos c-syntactic-element))
           (offset (- (1+ column) anchor))
           (steps (floor offset c-basic-offset)))
      (* (max steps 1)
         c-basic-offset)))

  (dir-locals-set-class-variables
   'linux-kernel
   '((c-mode . (
          (c-basic-offset . 8)
          (c-label-minimum-indentation . 0)
          (c-offsets-alist . (
                  (arglist-close         . c-lineup-arglist-tabs-only)
                  (arglist-cont-nonempty .
		      (c-lineup-gcc-asm-reg c-lineup-arglist-tabs-only))
                  (arglist-intro         . +)
                  (brace-list-intro      . +)
                  (c                     . c-lineup-C-comments)
                  (case-label            . 0)
                  (comment-intro         . c-lineup-comment)
                  (cpp-define-intro      . +)
                  (cpp-macro             . -1000)
                  (cpp-macro-cont        . +)
                  (defun-block-intro     . +)
                  (else-clause           . 0)
                  (func-decl-cont        . +)
                  (inclass               . +)
                  (inher-cont            . c-lineup-multi-inher)
                  (knr-argdecl-intro     . 0)
                  (label                 . -1000)
                  (statement             . 0)
                  (statement-block-intro . +)
                  (statement-case-intro  . +)
                  (statement-cont        . +)
                  (substatement          . +)
                  ))
          (indent-tabs-mode . t)
          (show-trailing-whitespace . t)
          ))))

  (dir-locals-set-directory-class
   (expand-file-name "~/src/linux-trees")
   'linux-kernel)

This will make emacs go better with the kernel coding style for C
files below ``~/src/linux-trees``.

But even if you fail in getting emacs to do sane formatting, not
everything is lost: use ``indent``.

Now, again, GNU indent has the same brain-dead settings that GNU emacs
has, which is why you need to give it a few command line options.
However, that's not too bad, because even the makers of GNU indent
recognize the authority of K&R (the GNU people aren't evil, they are
just severely misguided in this matter), so you just give indent the
options ``-kr -i8`` (stands for ``K&R, 8 character indents``), or use
``scripts/Lindent``, which indents in the latest style.

``indent`` has a lot of options, and especially when it comes to comment
re-formatting you may want to take a look at the man page.  But
remember: ``indent`` is not a fix for bad programming.

Note that you can also use the ``clang-format`` tool to help you with
these rules, to quickly re-format parts of your code automatically,
and to review full files in order to spot coding style mistakes,
typos and possible improvements. It is also handy for sorting ``#includes``,
for aligning variables/macros, for reflowing text and other similar tasks.
See the file :ref:`Documentation/process/clang-format.rst <clangformat>`
for more details.

## 10) Kconfig configuration files

For all of the Kconfig* configuration files throughout the source tree,
the indentation is somewhat different.  Lines under a ``config`` definition
are indented with one tab, while help text is indented an additional two
spaces.  Example::

  config AUDIT
	bool "Auditing support"
	depends on NET
	help
	  Enable auditing infrastructure that can be used with another
	  kernel subsystem, such as SELinux (which requires this for
	  logging of avc messages output).  Does not do system-call
	  auditing without CONFIG_AUDITSYSCALL.

Seriously dangerous features (such as write support for certain
filesystems) should advertise this prominently in their prompt string::

  config ADFS_FS_RW
	bool "ADFS write support (DANGEROUS)"
	depends on ADFS_FS
	...

For full documentation on the configuration files, see the file
Documentation/kbuild/kconfig-language.rst.

## 11) Data structures

Data structures that have visibility outside the single-threaded
environment they are created and destroyed in should always have
reference counts.  In the kernel, garbage collection doesn't exist (and
outside the kernel garbage collection is slow and inefficient), which
means that you absolutely **have** to reference count all your uses.

Reference counting means that you can avoid locking, and allows multiple
users to have access to the data structure in parallel - and not having
to worry about the structure suddenly going away from under them just
because they slept or did something else for a while.

Note that locking is **not** a replacement for reference counting.
Locking is used to keep data structures coherent, while reference
counting is a memory management technique.  Usually both are needed, and
they are not to be confused with each other.

Many data structures can indeed have two levels of reference counting,
when there are users of different ``classes``.  The subclass count counts
the number of subclass users, and decrements the global count just once
when the subclass count goes to zero.

Examples of this kind of ``multi-level-reference-counting`` can be found in
memory management (``struct mm_struct``: mm_users and mm_count), and in
filesystem code (``struct super_block``: s_count and s_active).

Remember: if another thread can find your data structure, and you don't
have a reference count on it, you almost certainly have a bug.

## 12) Macros, Enums and RTL

Names of macros defining constants and labels in enums are capitalized.

.. code-block:: c

	#define CONSTANT 0x12345

Enums are preferred when defining several related constants.

CAPITALIZED macro names are appreciated but macros resembling functions
may be named in lower case.

Generally, inline functions are preferable to macros resembling functions.

Macros with multiple statements should be enclosed in a do - while block:

.. code-block:: c

	#define macrofun(a, b, c)			\
		do {					\
			if (a == 5)			\
				do_this(b, c);		\
		} while (0)

Things to avoid when using macros:

1) macros that affect control flow:

.. code-block:: c

	#define FOO(x)					\
		do {					\
			if (blah(x) < 0)		\
				return -EBUGGERED;	\
		} while (0)

is a **very** bad idea.  It looks like a function call but exits the ``calling``
function; don't break the internal parsers of those who will read the code.

2) macros that depend on having a local variable with a magic name:

.. code-block:: c

	#define FOO(val) bar(index, val)

might look like a good thing, but it's confusing as hell when one reads the
code and it's prone to breakage from seemingly innocent changes.

3) macros with arguments that are used as l-values: FOO(x) = y; will
bite you if somebody e.g. turns FOO into an inline function.

4) forgetting about precedence: macros defining constants using expressions
must enclose the expression in parentheses. Beware of similar issues with
macros using parameters.

.. code-block:: c

	#define CONSTANT 0x4000
	#define CONSTEXP (CONSTANT | 3)

5) namespace collisions when defining local variables in macros resembling
functions:

.. code-block:: c

	#define FOO(x)				\
	({					\
		typeof(x) ret;			\
		ret = calc_ret(x);		\
		(ret);				\
	})

ret is a common name for a local variable - __foo_ret is less likely
to collide with an existing variable.

The cpp manual deals with macros exhaustively. The gcc internals manual also
covers RTL which is used frequently with assembly language in the kernel.

## 13) Printing kernel messages

Kernel developers like to be seen as literate. Do mind the spelling
of kernel messages to make a good impression. Do not use incorrect
contractions like ``dont``; use ``do not`` or ``don't`` instead. Make the
messages concise, clear, and unambiguous.

Kernel messages do not have to be terminated with a period.

Printing numbers in parentheses (%d) adds no value and should be avoided.

There are a number of driver model diagnostic macros in <linux/device.h>
which you should use to make sure messages are matched to the right device
and driver, and are tagged with the right level:  dev_err(), dev_warn(),
dev_info(), and so forth.  For messages that aren't associated with a
particular device, <linux/printk.h> defines pr_notice(), pr_info(),
pr_warn(), pr_err(), etc.

Coming up with good debugging messages can be quite a challenge; and once
you have them, they can be a huge help for remote troubleshooting.  However
debug message printing is handled differently than printing other non-debug
messages.  While the other pr_XXX() functions print unconditionally,
pr_debug() does not; it is compiled out by default, unless either DEBUG is
defined or CONFIG_DYNAMIC_DEBUG is set.  That is true for dev_dbg() also,
and a related convention uses VERBOSE_DEBUG to add dev_vdbg() messages to
the ones already enabled by DEBUG.

Many subsystems have Kconfig debug options to turn on -DDEBUG in the
corresponding Makefile; in other cases specific files #define DEBUG.  And
when a debug message should be unconditionally printed, such as if it is
already inside a debug-related #ifdef section, printk(KERN_DEBUG ...) can be
used.

## 14) Allocating memory

The kernel provides the following general purpose memory allocators:
kmalloc(), kzalloc(), kmalloc_array(), kcalloc(), vmalloc(), and
vzalloc().  Please refer to the API documentation for further information
about them.  :ref:`Documentation/core-api/memory-allocation.rst
<memory_allocation>`

The preferred form for passing a size of a struct is the following:

.. code-block:: c

	p = kmalloc(sizeof(*p), ...);

The alternative form where struct name is spelled out hurts readability and
introduces an opportunity for a bug when the pointer variable type is changed
but the corresponding sizeof that is passed to a memory allocator is not.

Casting the return value which is a void pointer is redundant. The conversion
from void pointer to any other pointer type is guaranteed by the C programming
language.

The preferred form for allocating an array is the following:

.. code-block:: c

	p = kmalloc_array(n, sizeof(...), ...);

The preferred form for allocating a zeroed array is the following:

.. code-block:: c

	p = kcalloc(n, sizeof(...), ...);

Both forms check for overflow on the allocation size n * sizeof(...),
and return NULL if that occurred.

These generic allocation functions all emit a stack dump on failure when used
without __GFP_NOWARN so there is no use in emitting an additional failure
message when NULL is returned.

## 15) The inline disease

There appears to be a common misperception that gcc has a magic "make me
faster" speedup option called ``inline``. While the use of inlines can be
appropriate (for example as a means of replacing macros, see Chapter 12), it
very often is not. Abundant use of the inline keyword leads to a much bigger
kernel, which in turn slows the system as a whole down, due to a bigger
icache footprint for the CPU and simply because there is less memory
available for the pagecache. Just think about it; a pagecache miss causes a
disk seek, which easily takes 5 milliseconds. There are a LOT of cpu cycles
that can go into these 5 milliseconds.

A reasonable rule of thumb is to not put inline at functions that have more
than 3 lines of code in them. An exception to this rule are the cases where
a parameter is known to be a compiletime constant, and as a result of this
constantness you *know* the compiler will be able to optimize most of your
function away at compile time. For a good example of this later case, see
the kmalloc() inline function.

Often people argue that adding inline to functions that are static and used
only once is always a win since there is no space tradeoff. While this is
technically correct, gcc is capable of inlining these automatically without
help, and the maintenance issue of removing the inline when a second user
appears outweighs the potential value of the hint that tells gcc to do
something it would have done anyway.

## 16) Function return values and names

Functions can return values of many different kinds, and one of the
most common is a value indicating whether the function succeeded or
failed.  Such a value can be represented as an error-code integer
(-Exxx = failure, 0 = success) or a ``succeeded`` boolean (0 = failure,
non-zero = success).

Mixing up these two sorts of representations is a fertile source of
difficult-to-find bugs.  If the C language included a strong distinction
between integers and booleans then the compiler would find these mistakes
for us... but it doesn't.  To help prevent such bugs, always follow this
convention::

	If the name of a function is an action or an imperative command,
	the function should return an error-code integer.  If the name
	is a predicate, the function should return a "succeeded" boolean.

For example, ``add work`` is a command, and the add_work() function returns 0
for success or -EBUSY for failure.  In the same way, ``PCI device present`` is
a predicate, and the pci_dev_present() function returns 1 if it succeeds in
finding a matching device or 0 if it doesn't.

All EXPORTed functions must respect this convention, and so should all
public functions.  Private (static) functions need not, but it is
recommended that they do.

Functions whose return value is the actual result of a computation, rather
than an indication of whether the computation succeeded, are not subject to
this rule.  Generally they indicate failure by returning some out-of-range
result.  Typical examples would be functions that return pointers; they use
NULL or the ERR_PTR mechanism to report failure.

## 17) 使用bool

Linux内核的bool类型是C99 _Bool类型的别名。 bool值只能是0或1，并且隐式或显式转换为bool，会自动将值转换为true或false。 使用布尔型时，!!不需要结构体，从而消除了一类错误。

使用布尔值时，应使用true和false定义，而不是1和0。

在适当的时候使用可以使用bool返回类型的函数和堆栈变量。 鼓励使用布尔值来提高可读性，并且在存储boolean值时通常比使用"int"类型更好。

如果cache line layout或size of the value很重要，请不要使用bool，因为其大小和对齐方式会根据编译的体系结构而变化。 针对对齐和大小进行了优化的结构不应使用布尔值。

如果结构体具有许多true/false，请考虑将它们合并到具有1个位成员的位域中，或使用适当的固定宽度类型（例如`u8`）。

类似地，对于函数参数，可以将许多true/false值合并为单个按位的'flags'参数，并且如果调用位置具有裸露的true/false常量，则'flags'通常是更具可读性的替代方法。

否则，在结构体和参数中限制使用bool可以提高可读性。

## 18) 不要重新发明内核宏

头文件`include/linux/kernel.h`包含许多您应该使用的宏，而不要自己写一些它们的变种。 例如，如果您需要计算数组的长度，请利用宏：

```c
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
```

同样，如果需要计算某些结构成员的大小，请使用：

```c
#define sizeof_field(t, f) (sizeof(((t*)0)->f))
```

如果需要，还有`min()` 和 `max()`宏会进行严格的类型检查。 你可以自己看看那个头文件里还定义了什么你可以拿来用的宏，如果有定义的话，你就不应在你的代码里自己重新定义。

## 19) 编辑器模式行（配置信息）和其他内容

一些编辑器可以解释用特殊标记表示的嵌入在源文件中的配置信息。 例如，emacs解释标记如下的行：

```c
-*- mode: c -*-
```

或者这样的：

```c
/*
Local Variables:
compile-command: "gcc -DMAGIC_DEBUG_FLAG foo.c"
End:
*/
```

Vim解释如下标记：

```c
/* vim:set sw=8 noet */
```

不要在源文件中包含任何这些。 人们具有自己的个人编辑器配置，并且您的源文件不应覆盖它们。 这包括用于缩进和模式配置的标记。 人们可以使用他们自己定制的模式，或者使用其他可以产生正确的缩进的巧妙方法。

## 20) 内联汇编

在特定于体系结构的代码中，您可能需要使用内联汇编与CPU或平台功能交互。 必要时不要犹豫。 但是，当C可以完成这项工作时，请不要随意使用内联汇编。 您可以并且应该在可能的情况下用C操作硬件。

考虑编写简单的辅助函数，这些函数包装内联汇编的常用位，而不是重复编写稍有变化的函数。 请记住，内联汇编可以使用C参数。

大型的，非平凡（大量的）的汇编函数应放在.S文件中，并在C头文件中定义相应的C原型。 汇编函数的C原型应使用`asmlinkage`。

您可能需要将asm语句标记为`volatile`，以防止GCC在未发现任何副作用的情况下将其删除。 但是，您不一定总是需要这样做，因为这样做可能会限制优化。

当编写包含多个指令的单个内联汇编语句时，将每条指令放在单独的行中，放在单独的带引号的字符串中，用``\n\t`` 结束除最后一个字符串以外的每个字符串，以正确缩进汇编输出中的下一条指令：

```c
asm ("magic %reg1, #42\n\t"
     "more_magic %reg2, %reg3"
     : /* outputs */ : /* inputs */ : /* clobbers */);
```

## 21) 条件编译

尽可能不要在`.c`文件中使用预处理条件（`#if, #ifdef`）； 这样做会使代码更难阅读，逻辑也更难遵循。 而是在头文件中使用此类条件，以定义在那些`.c`文件中使用的函数，在`#else`情况下提供no-op（无操作） stub版本，然后从`.c`文件中无条件调用这些函数。 编译器将避免为stub calls生成任何代码，从而产生相同的结果，但是逻辑将易于遵循。

最好编译出整个函数，而不是编译部分函数或表达式的一部分。 不要将`ifdef`放入表达式中，而是将部分或全部表达式封装成函数，然后调用该函数。

如果您具有在特定配置中可能未使用的函数或变量，并且编译器会警告其定义未使用，请将该定义标记为`__maybe_unused`，而不是将其包装在预处理条件中。 （但是，如果函数或变量**始终**不使用，请将其删除。）

在代码内，在可能的情况下，使用`IS_ENABLED`宏将Kconfig符号转换为C布尔表达式，并在普通的C条件中使用它：

```c
if (IS_ENABLED(CONFIG_SOMETHING)) {
	...
}
```

编译器将不断折叠条件，并像`#ifdef`一样包含或排除代码块，因此这不会增加任何运行时开销。 但是，这种方法仍然允许C编译器查看块中的代码，并检查其是否正确（语法，类型，符号引用等）。 因此，如果块内的代码引用了如果不满足条件将不存在的符号，则仍然必须使用`#ifdef`。

在任何重要的`#if`或`#ifdef`代码块的末尾（多行），在同一行的`#endif`后面放置注释，并注明所使用的条件表达式。 例如：

```c
#ifdef CONFIG_SOMETHING
...
#endif /* CONFIG_SOMETHING */
```

## 附录 I) 参考

The C Programming Language, Second Edition by Brian W. Kernighan and Dennis M. Ritchie. Prentice Hall, Inc., 1988. ISBN 0-13-110362-8 (paperback), 0-13-110370-9 (hardback).

The Practice of Programming by Brian W. Kernighan and Rob Pike. Addison-Wesley, Inc., 1999. ISBN 0-201-61586-X.

GNU manuals - where in compliance with K&R and this text - for cpp, gcc, gcc internals and indent, all  available from [https://www.gnu.org/manual/](https://www.gnu.org/manual/)

WG14 is the international standardization working group for the programming language C, URL: [http://www.open-std.org/JTC1/SC22/WG14/](http://www.open-std.org/JTC1/SC22/WG14/)

Kernel :ref:`process/coding-style.rst <codingstyle>`, by greg@kroah.com at OLS 2002: [http://www.kroah.com/linux/talks/ols_2002_kernel_codingstyle_talk/html/](http://www.kroah.com/linux/talks/ols_2002_kernel_codingstyle_talk/html/)
