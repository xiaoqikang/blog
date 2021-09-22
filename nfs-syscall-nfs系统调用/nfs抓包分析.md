[toc]

```shell
tcpdump -i any -w file.cap
```

# mount 抓包分析

```shell
strace -f -v -o strace mount -t nfs -o vers=4.1 192.168.122.88:/s_test /tmp/test/
# mount("192.168.122.88:/s_test", "/tmp/test", "nfs", 0, "vers=4.1,addr=192.168.122.88,cli"...) = 0
```

```shell
  11 [  141.794829] CPU: 5 PID: 604 Comm: mount.nfs Not tainted 4.19.206+ #7
  12 [  141.795311] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.13.0-1ubuntu1.1 04/01/2014
  13 [  141.796009] Call Trace:
  14 [  141.796205]  dump_stack+0xac/0xe6
  15 [  141.796463]  rpc_run_task+0x78/0x5a0
  16 [  141.796741]  ? rpc_clnt_swap_deactivate_callback+0x70/0x70
  17 [  141.797157]  rpc_call_sync.cold+0xd/0x63
  18 [  141.797458]  ? rpc_shutdown_client+0x2b0/0x2b0
  19 [  141.797799]  ? rpc_unregister_client+0x280/0x280
  20 [  141.798152]  rpc_ping+0xaf/0xf0
  21 [  141.798396]  ? rpc_call_sync+0xe0/0xe0
  22 [  141.798685]  ? rpc_new_client+0x795/0xb20
  23 [  141.798995]  rpc_create_xprt+0x289/0x330
  24 [  141.799297]  rpc_create+0x2cc/0x4d0
  25 [  141.799566]  ? rpc_create_xprt+0x330/0x330
  26 [  141.799889]  ? generic_create_cred+0x2de/0x4b0
  27 [  141.800233]  ? _raw_spin_lock+0x13/0x40
  28 [  141.800530]  ? rpcauth_lookup_credcache+0x35a/0xa50
  29 [  141.800901]  ? rpcauth_cache_shrink_scan+0xb0/0xb0
  30 [  141.801271]  nfs_create_rpc_client+0x342/0x480
  31 [  141.801613]  ? nfs_mark_client_ready+0x60/0x60
  32 [  141.801953]  ? rpc_lookup_machine_cred+0xf9/0x140
  33 [  141.802313]  ? __rpc_init_priority_wait_queue+0x251/0x380
  34 [  141.802702]  nfs4_alloc_client+0x6da/0x910
  35 [  141.802988]  ? nfs40_shutdown_client+0x90/0x90
  36 [  141.803332]  ? find_next_zero_bit+0xdd/0x110
  37 [  141.803660]  ? find_next_bit+0xc9/0xf0
  38 [  141.803957]  ? pcpu_next_unpop+0x91/0x100
  39 [  141.804298]  ? pcpu_block_refresh_hint+0x1e2/0x260
  40 [  141.804644]  ? pcpu_next_unpop+0x100/0x100
  41 [  141.804936]  ? pcpu_find_block_fit+0x2f1/0x380
  42 [  141.805228]  nfs_get_client+0x518/0xeb0
  43 [  141.805481]  ? find_next_zero_bit+0xdd/0x110
  44 [  141.805766]  ? cpumask_next+0x4e/0x70
  45 [  141.806011]  nfs4_set_client+0x24c/0x3b0
  46 [  141.806267]  ? nfs4_set_ds_client+0x2e0/0x2e0
  47 [  141.806555]  ? __rpc_init_priority_wait_queue+0x251/0x380
  48 [  141.806905]  nfs4_create_server+0x4d5/0xbb0
  49 [  141.807178]  ? nfs4_find_client_sessionid+0x560/0x560
  50 [  141.807504]  ? pcpu_find_block_fit+0x380/0x380
  51 [  141.807792]  ? __kmalloc_track_caller+0x1b9/0x240
  52 [  141.808102]  nfs4_remote_mount+0x4b/0x90
  53 [  141.808359]  mount_fs+0x9d/0x2f0
  54 [  141.808569]  vfs_kern_mount.part.0+0x60/0x390
  55 [  141.808847]  vfs_kern_mount+0x41/0x60
  56 [  141.809083]  nfs_do_root_mount+0x8c/0xd0
  57 [  141.809336]  nfs4_try_mount+0xf1/0x1b0
  58 [  141.809578]  nfs_fs_mount+0x2045/0x3040
  59 [  141.809827]  ? nfs_show_stats+0xe60/0xe60
  60 [  141.810085]  ? nfs_clone_super+0x400/0x400
  61 [  141.810347]  ? nfs_remount+0x1770/0x1770
  62 [  141.810600]  ? memcpy+0x35/0x50
  63 [  141.810805]  mount_fs+0x9d/0x2f0
  64 [  141.811016]  vfs_kern_mount.part.0+0x60/0x390
  65 [  141.811296]  do_mount+0x3ce/0x22b0
  66 [  141.811518]  ? copy_mount_string+0x40/0x40
  67 [  141.811784]  ? copy_mount_options+0x1bc/0x2e0
  68 [  141.812068]  ? copy_mount_options+0x21c/0x2e0
  69 [  141.812352]  ksys_mount+0xa0/0x100
  70 [  141.812574]  __x64_sys_mount+0xbf/0x160
  71 [  141.812823]  do_syscall_64+0xc5/0x3d0
  72 [  141.813059]  ? prepare_exit_to_usermode+0x11a/0x1a0
  73 [  141.813373]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
```

# touch 抓包分析

```shell
strace -f -v -o strace touch /tmp/test/file
# open("/tmp/test/file", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK, 0666) = 3
```

# echo 抓包分析

```shell
strace -f -v -o strace echo abcdef > /tmp/test/file
# write(1, "abcdef\n", 7)                 = 7
```

# cat 抓包分析

```shell
strace -f -v -o strace cat /tmp/test/file
# open("/tmp/test/file", O_RDONLY)  = 3
# read(3, "abcdef\n", 262144)       = 7
```