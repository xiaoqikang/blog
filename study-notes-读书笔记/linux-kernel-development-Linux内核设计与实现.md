[toc]

# 第13章 虚拟文件系统

## 13.1 通用文件系统接口 

## 13.2 文件系统抽象层

## 13.3 Unix文件系统

p212：

DOS和Windows将文件的命名空间分类为驱动字母（如C:），这种将命名空间划分为设备和分区和做法，相当于把硬件细节“泄露”给文件系统抽象层，对用户而言，随意和混淆。

## 13.4 VFS对象及其数据结构

## 13.5 超级块对象

p214：

```c
// include/linux/fs.h
struct super_block {
	...
	const struct super_operations   *s_op;
	...
};

```

## 13.6 超级块操作

```c
// include/linux/fs.h
struct super_operations {
	struct inode *(*alloc_inode)(struct super_block *sb);
	void (*destroy_inode)(struct inode *);
	...
};
```

## 13.7 索引节点对象

```c
// include/linux/fs.h
struct inode {
	struct hlist_node       i_hash;
	struct list_head        i_list;         /* backing dev IO list */
	struct list_head        i_sb_list;
	...
};
```

## 13.8 索引节点操作



