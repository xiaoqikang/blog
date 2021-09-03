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
``` 

```c
// 4.19
SYSCALL_DEFINE5(mount,
  ksys_mount
    copy_mount_string // 从用户空间复制字符串
    copy_mount_options
    do_mount
      user_path // 挂载点
      do_new_mount
        get_fs_type
          __get_fs_type
            find_filesystem
              // TODO: file_systems 变量
        vfs_kern_mount
          mount_fs
            // type->mount
            nfs4_remote_mount
              nfs4_create_server
                nfs4_init_server
                  nfs4_set_client
                    nfs_get_client
                      nfs_match_client // 第一次找不到
                        list_for_each_entry
                        nfs_wait_client_init_complete // 如果找到，等到 client 初始化完成
                      // rpc_ops->alloc_client
                      nfs4_alloc_client
                        nfs_create_rpc_client
                          rpc_create
                            rpc_create_xprt
                              rpc_ping
                      nfs_match_client // 还找不到
                      list_add_tail // 加到链表中
                      // rpc_ops->init_client
                      nfs4_init_client
                        nfs4_discover_server_trunking
                          // ops->detect_trunking
                          nfs41_discover_server_trunking
                            nfs41_walk_client_list
                              nfs4_match_client
                                nfs_wait_client_init_complete
```

# open
```c
// 4.19
SYSCALL_DEFINE3(open,
  do_sys_open
    get_unused_fd_flags // 获取没有用的 fd
    do_filp_open
      // nameidata 在解析和查找路径的时候提供辅助作用
      set_nameidata
      path_openat
        alloc_empty_file
        path_init // 初始化 nameidata，准备开始节点路径查找
        link_path_walk // 路径查找
        do_last
          lookup_fast // 缓存中找
          lookup_open // 创建
            // dir_inode->i_op->lookup
            nfs_lookup
          vfs_open
            do_dentry_open
              // open = f->f_op->open
              nfs4_file_open
              file_ra_state_init // 初始化 file_ra_state
      restore_nameidata
    fd_install // fd 和 file 关联
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
