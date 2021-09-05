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

// TODO
module_init(init_nfs_v4
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
            nfs_fs_mount
              nfs_alloc_parsed_mount_data
              nfs_alloc_fhandle
              nfs_validate_mount_data
                nfs4_validate_mount_data
                  return NFS_TEXT_DATA;
              nfs_validate_text_mount_data // 字符串解析
                nfs_parse_mount_options // 挂载选项解析
                nfs_verify_server_address // 校验服务器地址
                port = NFS_PORT; // 默认端口 2049
                nfs_validate_transport_protocol // 校验协议
                nfs4_validate_mount_flags // 校验标志
                nfs_set_port // 设置端口
                nfs_parse_devname // 解析 192.168.122.88:/ 冒号后的路径
              get_nfs_version // 获取版本
              // nfs_mod->rpc_ops->try_mount
              nfs4_try_mount
                nfs_do_root_mount
                  vfs_kern_mount
                    mount_fs
                    // type->mount
                    nfs4_remote_mount // 见后面的分析
                nfs_follow_remote_path // 后面的路径
                  nfs_referral_loop_protect // 引用计数保护？
                  mount_subtree
                    create_mnt_ns
                    vfs_path_lookup
                      filename_lookup
                  nfs_referral_loop_unprotect
            security_sb_kern_mount // 安全相关？
            free_secdata
          list_add_tail // 添加到链表
        put_filesystem // 减小引用计数
        mount_too_revealing // 可见？
        do_add_mount // 添加到 tree
          check_mnt
          d_is_symlink // 不能是 symlink
          graft_tree
      path_put // 减小引用计数
    kfree // 释放内核空间字符串


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
  nfs_fs_mount_common
    sget // 得到 super block
    // mount_info->fill_super
    nfs_fill_super ?
    nfs_get_cache_cookie
    nfs_get_root
      nfs_fhget
        inode->i_flags |= S_NOATIME|S_NOCMTIME;
    mount_info->set_security
```

# open
```c
// 4.19
// nfs
// open("nfs4/thanos", O_RDONLY)           = 3
SYSCALL_DEFINE3(open,
  // TODO: 干啥的？
  force_o_largefile
  do_sys_open
    getname // 获取 struct filename
    get_unused_fd_flags // 获取未使用的文件描述符
    do_filp_open
      // nameidata 在解析和查找路径的时候提供辅助作用
      set_nameidata
      // rcu-walk, 使用 RCU 保护散列桶的链表,使用 序列号保护目录
      // 其他处理器可以并行地修改目录, RCU 查找方式速度最快
      path_openat(..., flags | LOOKUP_RCU)
        alloc_empty_file
        path_init // 初始化 nameidata，准备开始节点路径查找
        link_path_walk // 路径查找
        do_last // 最后一步
          handle_dots
          lookup_fast // 缓存中找
            __d_lookup_rcu
            __d_lookup // 非rcu
            d_revalidate
              // dentry->d_op->d_revalidate
              nfs4_lookup_revalidate
                // reval
                nfs4_do_lookup_revalidate
            follow_managed
          mnt_want_write // 写权限
            __mnt_want_write
              mnt_is_readonly // 如果只读，返回 -EROFS
          lookup_open // 创建
            d_lookup // 寻找 dentry
            atomic_open
              // dir->i_op->atomic_open
              // 第一次打开文件时会执行到这里，且不执行后面的 nfs4_file_open
              // 第二次打开文件不会执行到这里
              nfs_atomic_open 
                nfs_check_flags // 只有 nfs 实现了 check_flags 方法
                create_nfs_open_context 分配 struct nfs_open_context
                // NFS_PROTO(dir)->open_context(
                nfs4_atomic_open
                  nfs4_do_open
                    _nfs4_do_open
                      nfs4_get_state_owner
                      nfs4_opendata_alloc
                      _nfs4_open_and_get_state
                        _nfs4_proc_open
                          nfs4_run_open_task
                            nfs4_init_sequence
                            rpc_run_task
                              rpc_execute
                            rpc_wait_for_completion_task
                          nfs_fattr_map_and_free_names // idmap ?
                        _nfs4_opendata_to_nfs4_state
                          nfs4_opendata_find_nfs4_state
                            nfs4_opendata_get_inode
                              nfs_fhget
                                inode->i_flags |= S_NOATIME|S_NOCMTIME
                        d_exact_alias // alias
                        d_splice_alias // alias
                        nfs4_opendata_access // 权限检查
                nfs_finish_open
              d_lookup_done
              fsnotify_create
            // dir_inode->i_op->lookup
            nfs_lookup // 未执行到这里，atomic_open 执行完就退出
          follow_managed
          may_open // 检查
          vfs_open
            do_dentry_open
              // open = f->f_op->open
              // 第一次打开文件不会执行到这里
              // 第二次打开文件时会执行到这里，且不执行前面的 nfs_atomic_open
              nfs4_file_open
                // NFS_PROTO(dir)->open_context
                nfs4_atomic_open
                nfs_file_set_open_context
                nfs_fscache_open_file
              file_ra_state_init // 初始化 file_ra_state
        terminate_walk
      // ref-walk, 使用 RCU 保护散列桶的链表,使用自旋锁保护目录，并且把目录的引用计数加1
      // 引用查找方式速度比较慢
      path_openat(..., flags)
      // 二次解析发现信息过期，返回错误号 -ESTALE，那么第三次解析传入标志 LOOKUP_REVAL
      // 表示需要重新确认信息是否有效
      path_openat(..., flags | LOOKUP_REVAL)
      restore_nameidata
    fsnotify_open // 通知
    fd_install // fd 和 file 关联
    putname // 减小 struct filename 引用计数
```

# close


# read

```c
// nfs
// 4.19
SYSCALL_DEFINE3(read,
  ksys_read
    file_pos_read // 读取当前位置
    vfs_read
      access_ok // 权限
      rw_verify_area // 检查区域
      __vfs_read
        new_sync_read
          call_read_iter
            // file->f_op->read_iter
            nfs_file_read
              generic_file_read_iter
                // if (iocb->ki_flags & IOCB_DIRECT) {
                file_accessed // 不更新 access time
                  touch_atime
                    atime_needs_update
                      if (inode->i_flags & S_NOATIME) // 在 nfs_fhget 中设置
                      return false;
                // mapping->a_ops->direct_IO
                nfs_direct_IO
                  nfs_file_direct_read
                    get_nfs_open_context
                    nfs_start_io_direct
                    nfs_direct_read_schedule_iovec
                      nfs_pageio_add_request
                        nfs_pageio_add_request_mirror
                          __nfs_pageio_add_request
                            nfs_pageio_do_add_request
                            nfs_pageio_doio
                              // desc->pg_ops->pg_doio
                              nfs_generic_pg_pgios
                                nfs_initiate_pgio
                                  // hdr->rw_ops->rw_initiate
                                  nfs_initiate_read
                                  rpc_run_task
                                  rpc_wait_for_completion_task
                          nfs_do_recoalesce
                    nfs_end_io_direct
                    nfs_direct_wait
                // 缓存
                generic_file_buffered_read
                  page_cache_sync_readahead
                  find_get_page
                  // 如果第一次找缓存页就找到, 且继续预读
                  // TODO: PageReadahead 找不到定义
                  page_cache_async_readahead // 异步预读
                  copy_page_to_iter // 从内核缓存页拷贝到用户内存空间
                  // mapping->a_ops->readpage
                  nfs_readpage
                    nfs_readpage_async
                      nfs_pageio_add_request
                        nfs_pageio_setup_mirroring
                        nfs_pageio_add_request_mirror
                          __nfs_pageio_add_request
                            nfs_pageio_do_add_request
                            nfs_pageio_doio
                              // desc->pg_ops->pg_doio
                              nfs_generic_pg_pgios
                          nfs_do_recoalesce
      fsnotify_access
    file_pos_write // 更新位置
```

```c
// 3.10
// nfs
SYSCALL_DEFINE3(read,
  vfs_read
    do_sync_read
      // filp->f_op->aio_read
      nfs_file_read
        generic_file_aio_read
          do_generic_file_read
            // mapping->a_ops->readpage
            nfs_readpage
              nfs_readpage_from_fscache
              nfs_readpage_async
                nfs_pageio_add_request
                  __nfs_pageio_add_request
                    nfs_pageio_do_add_request
                    nfs_pageio_doio
                      // desc->pg_ops->pg_doio
                      nfs_generic_pg_readpages
                        nfs_do_multiple_reads
                          nfs_do_read
                            nfs_initiate_read
                  nfs_do_recoalesce
            lock_page_killable
              __lock_page_killable
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
