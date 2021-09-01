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
// nfs
// 4.19
SYSCALL_DEFINE3(read,
	ksys_read
		vfs_read
			__vfs_read
				new_sync_read
					call_read_iter
						// file->f_op->read_iter
						// TODO: 找不到 nfs4_file_operations 中的 .read_iter
						nfs_file_read
							generic_file_read_iter
								// if (iocb->ki_flags & IOCB_DIRECT) {
								// mapping->a_ops->direct_IO
								nfs_direct_IO
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

```c
// ext4
// 4.19
SYSCALL_DEFINE3(read,
	ksys_read
		vfs_read
			__vfs_read
				new_sync_read
					call_read_iter
						// file->f_op->read_iter
						ext4_file_read_iter
							generic_file_read_iter
								// if (iocb->ki_flags & IOCB_DIRECT) {
								// mapping->a_ops->direct_IO
								ext4_direct_IO
									ext4_direct_IO_read
										__blockdev_direct_IO
											do_blockdev_direct_IO
								// 缓存读
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
// ext4
// 4.19
SYSCALL_DEFINE3(write,
	ksys_write
		vfs_write
			new_sync_write
				call_write_iter
					// file->f_op->write_iter
					ext4_file_write_iter
						__generic_file_write_iter
							// if (iocb->ki_flags & IOCB_DIRECT) {
							generic_file_direct_write
								// mapping->a_ops->direct_IO
								ext4_direct_IO
									ext4_direct_IO_read
										__blockdev_direct_IO
											do_blockdev_direct_IO
							// 缓存写
							generic_perform_write
								// a_ops->write_begin
								ext4_write_begin
									grab_cache_page_write_begin
										pagecache_get_page
								iov_iter_copy_from_user_atomic
									kmap_atomic
									kunmap_atomic
								// a_ops->write_end
								ext4_write_end
									block_write_end
										__block_commit_write
											mark_buffer_dirty
									ext4_journal_stop
										__ext4_journal_stop
								balance_dirty_pages_ratelimited
									balance_dirty_pages
										wb_start_background_writeback
											wb_wakeup
												mod_delayed_work
													// wb_init
													// INIT_DELAYED_WORK(&wb->dwork, wb_workfn);
													wb_workfn
														wb_do_writeback
															wb_writeback
																writeback_sb_inodes
																	__writeback_single_inode
																		do_writepages
```
