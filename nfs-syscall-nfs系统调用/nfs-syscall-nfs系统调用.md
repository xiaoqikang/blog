[toc]


# mount

```c
// fs/nfs/inode.c
module_init(init_nfs_fs)
	init_nfs_fs
		register_nfs_fs
			register_nfs4_fs
				register_filesystem
```

```c
// 5.10
SYSCALL_DEFINE5(mount,
	do_mount
		path_mount
			do_new_mount
				do_new_mount_fc
``` 

```c
// 4.19
SYSCALL_DEFINE5(mount,
	ksys_mount
		do_mount
			do_new_mount
				vfs_kern_mount
					mount_fs
						// type->mount
						nfs4_remote_mount
```

# open
```c
// 4.19
SYSCALL_DEFINE3(open,
	do_sys_open
		get_unused_fd_flags
		do_filp_open
			set_nameidata
			path_openat
				alloc_empty_file
				path_init
				link_path_walk
				do_last
					lookup_fast // 缓存中找
					lookup_open // 创建
						// dir_inode->i_op->lookup
						inode_operations
					vfs_open
						do_dentry_open
							// open = f->f_op->open
							nfs4_file_open
							file_ra_state_init
			restore_nameidata
		fd_install
```

# close


# read

```c
SYSCALL_DEFINE3(read,
	ksys_read
		vfs_read
			__vfs_read
				new_sync_read
					call_read_iter
						//.file->f_op->read_iter
						// TODO: 找不到 nfs4_file_operations 中的 .read_iter
						nfs_file_read
							generic_file_read_iter
								mapping->a_ops->direct_IO
									nfs_file_direct_read
										// TODO: nfs block io
									generic_file_buffered_read
										page_cache_sync_readahead
										find_get_page
										// 如果第一次找缓存页就找到, 且继续预读
										// TODO: PageReadahead 找不到定义
										page_cache_async_readahead // 异步预读
										copy_page_to_iter // 从内核缓存页拷贝到用户内存空间
```

# write

```c
SYSCALL_DEFINE3(write,
	ksys_write
		vfs_write
```
