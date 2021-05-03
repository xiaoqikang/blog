[toc]

# 第13章 虚拟文件系统

p212：DOS和Windows将文件的命名空间分类为驱动字母（如C:），这种将命名空间划分为设备和分区和做法，相当于把硬件细节“泄露”给文件系统抽象层，对用户而言，随意和混淆。

```c
// include/linux/fs.h
struct super_block {
	...
	const struct super_operations   *s_op;
	...
};

```

TODO p216