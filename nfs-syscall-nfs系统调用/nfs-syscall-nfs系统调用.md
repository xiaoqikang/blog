[toc]


# mount

```c
// fs/nfs/inode.c
module_init(init_nfs_fs)
  init_nfs_fs
    register_nfs_fs // 注册 nfs 文件系统
      register_filesystem // nfs
      register_nfs4_fs // nfsv4
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
// mount("192.168.122.88:/", "/root/nfs4", "nfs", 0, "vers=4.2,addr=192.168.122.88,cli"...) = 0
SYSCALL_DEFINE5(mount,
  ksys_mount
    copy_mount_string // 从用户空间复制字符串
    copy_mount_options
    do_mount
      user_path // 挂载点, 得到 struct path
        user_path_at_empty
          filename_lookup
            set_nameidata
              p->saved = old; // 保存旧的数据
            path_lookupat
              path_init
              link_path_walk // 循环解析路径
              lookup_last // 最后一级
              trailing_symlink // 处理符号链接
              complete_walk // 解析完成
              terminate_walk // 结束
            restore_nameidata // 恢复旧的数据
      do_new_mount
        get_fs_type
          __get_fs_type
            find_filesystem
              // TODO: file_systems 变量
        vfs_kern_mount
          alloc_vfsmnt // 分配内存
          mount_fs
            alloc_secdata // 安全相关？
            security_sb_copy_data // 安全相关？
            // type->mount
            nfs4_remote_mount
              nfs4_create_server
                nfs_alloc_server // 分配
                  rpc_init_wait_queue // 优先级队列
                nfs4_init_server
                  nfs_init_timeout_values // 超时时间
                  nfs4_set_client
                    rpc_get_port // 端口
                    nfs_get_client // 根据 ip 和 协议版本号 获取 client
                      nfs_match_client // 第一次找不到
                        list_for_each_entry // 从链表中找
                        refcount_inc // 先增加引用
                        nfs_wait_client_init_complete // 如果找到，等到 client 初始化完成
                        nfs_put_client // 减小引用
                        rpc_cmp_addr_port // 对比
                      // rpc_ops->alloc_client
                      nfs4_alloc_client // 分配
                        nfs_alloc_client
                          // TODO: cookie 怎么理解？
                          nfs_fscache_get_client_cookie
                        // TODO: idr 不理解
                        nfs_get_cb_ident_idr
                        rpc_init_wait_queue // 优先级队列
                        nfs_create_rpc_client // 创建 rpc client
                          rpc_create
                            xprt_create_transport
                            rpc_create_xprt
                              rpc_new_client
                              rpc_ping // 检测网络是否通，不会永远卡住
                                err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
                        // TODO: idmap 怎么用?
                        nfs_idmap_new
                      nfs_match_client // 还找不到
                      list_add_tail // 加到链表中
                      // rpc_ops->init_client
                      nfs4_init_client
                        nfs4_init_client_minor_version // 次版本号，4.1
                          // clp->cl_mvops->init_client
                          nfs41_init_client
                            nfs4_alloc_session
                            nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING); // 正在初始化
                        nfs4_discover_server_trunking
                          nfs4_get_clid_cred // 凭据
                          // ops->detect_trunking
                          nfs41_discover_server_trunking
                            // TODO: 这里是要干啥？
                            nfs4_proc_exchange_id
                            nfs41_walk_client_list
                              nfs4_match_client
                                nfs_wait_client_init_complete
                              nfs4_check_serverowner_major_id
                            nfs4_schedule_state_manager // 异步状态管理
                              kthread_run(nfs4_run_state_manager,
                            nfs_wait_client_init_complete
                  nfs_init_server_rpcclient // general RPC client
                nfs4_server_common_setup // rpc client
                  nfs_alloc_fattr
                  nfs4_init_session
                  server->caps |= NFS_CAP_UIDGID_NOMAP; // idmap
                  nfs4_get_rootfh // file handle
                    nfs4_proc_get_rootfh // 从 server 获取
                  nfs_probe_fsinfo
                    nfs_server_set_fsinfo
                  nfs4_session_limit_rwsize // 限制大小
                  nfs_server_insert_lists // 加到链表中
              nfs_fs_mount_common // i am here
                sget // 得到 super block
            security_sb_kern_mount // 安全相关？
            free_secdata
          list_add_tail // 添加到链表
        put_filesystem // 减小引用计数
        mount_too_revealing // 可见？
        do_add_mount // 添加到 tree
      path_put // 减小引用计数
    kfree // 释放内核空间字符串
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
