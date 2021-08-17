[toc]

本文是基于 Linux 5.10.59 代码（5805e5eec901）

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
SYSCALL_DEFINE5(mount,
    do_mount
        path_mount
            do_new_mount
                do_new_mount_fc

```