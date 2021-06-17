:orphan:

Making Filesystems Exportable
=============================

本文是基于Documentation/filesystems/nfs/exporting.rst以下提交记录:

.. code-block:: shell
	commit 7f84b488f9add1d5cca3e6197c95914c7bd3c1cf
	Author: Jeff Layton <jeff.layton@primarydata.com>
	Date:   Mon Nov 30 17:03:16 2020 -0500

	nfsd: close cached files prior to a REMOVE or RENAME that would replace target

Overview
--------

使文件系统可导出所有文件系统操作都需要一个（或两个）dentry 作为起点。本地应用程序通过打开的文件描述符或 cwd/root 对合适的 dentry 进行引用计数保留。然而，通过远程文件系统协议（如 NFS）访问文件系统的远程应用程序可能无法保存这样的引用，因此需要一种不同的方式来引用特定的 dentry。由于替代的引用形式需要在重命名、截断和服务器重启时保持稳定（除其他外，尽管这些往往是最有问题的），因此没有像“文件名”这样的简单答案。

此处讨论的机制允许每个文件系统实现指定如何为任何 dentry 生成不透明（文件系统之外）字节字符串，以及如何为任何给定的不透明字节字符串找到合适的 dentry。这个字节串将被称为“文件句柄片段”，因为它对应于 NFS 文件句柄的一部分。

支持文件句柄片段和 dentries 之间映射的文件系统将被称为“可导出”。


Dcache Issues
-------------

dcache 通常包含任何给定文件系统树的适当前缀。 这意味着如果任何文件系统对象在 dcache 中，那么该文件系统对象的所有祖先也在 dcache 中。 由于正常访问是通过文件名，这个前缀是自然创建的并且很容易维护（通过每个对象维护其父对象的引用计数）。

但是，当通过解释文件句柄片段将对象包含到 dcache 中时，不会自动为对象创建路径前缀。 这导致了正常文件系统访问不需要的 dcache 的两个相关但不同的功能。

1. dcache 有时必须包含不属于正确前缀的对象。 即没有连接到根。
2. dcache 必须为新发现的（通过 ->lookup）目录准备好已经有（未连接的）dentry，并且必须能够将该 dentry 移动到位（基于 ->lookup 中的父级和名称） . 这对于目录尤其需要，因为目录只有一个 dentry 是 dcache 不变的。

为了实现这些功能，dcache 具有：

a. 一个 dentry 标志 DCACHE_DISCONNECTED，它被设置在任何可能不是正确前缀的一部分的 dentry 上。 这在创建匿名 dentry 时设置，并在注意到 dentry 是正确前缀中的 dentry 的子项时清除。 如果设置了此标志的 dentry 上的 refcount 变为零，则立即丢弃该 dentry，而不是保留在 dcache 中。 如果文件句柄重复访问不在 dcache 中的 dentry（如 NFSD 可能会这样做），则将为每次访问分配一个新的 dentry，并在访问结束时丢弃。

   请注意，这样的 dentry 可以在不丢失 DCACHE_DISCONNECTED 的情况下获取子项、名称、祖先等 - 只有当子树成功重新连接到根时才会清除该标志。 在此之前，只有在存在引用时才会保留此类子树中的 dentry； refcount 达到零意味着立即驱逐，与未散列的 dentry 相同。 这保证了我们不需要在 umount 上追捕它们。

b. A primitive for creation of secondary roots - d_obtain_root(inode).
   Those do _not_ bear DCACHE_DISCONNECTED.  They are placed on the
   per-superblock list (->s_roots), so they can be located at umount
   time for eviction purposes.

c. Helper routines to allocate anonymous dentries, and to help attach
   loose directory dentries at lookup time. They are:

    d_obtain_alias(inode) will return a dentry for the given inode.
      If the inode already has a dentry, one of those is returned.

      If it doesn't, a new anonymous (IS_ROOT and
      DCACHE_DISCONNECTED) dentry is allocated and attached.

      In the case of a directory, care is taken that only one dentry
      can ever be attached.

    d_splice_alias(inode, dentry) will introduce a new dentry into the tree;
      either the passed-in dentry or a preexisting alias for the given inode
      (such as an anonymous one created by d_obtain_alias), if appropriate.
      It returns NULL when the passed-in dentry is used, following the calling
      convention of ->lookup.

Filesystem Issues
-----------------

For a filesystem to be exportable it must:

   1. provide the filehandle fragment routines described below.
   2. make sure that d_splice_alias is used rather than d_add
      when ->lookup finds an inode for a given parent and name.

      If inode is NULL, d_splice_alias(inode, dentry) is equivalent to::

		d_add(dentry, inode), NULL

      Similarly, d_splice_alias(ERR_PTR(err), dentry) = ERR_PTR(err)

      Typically the ->lookup routine will simply end with a::

		return d_splice_alias(inode, dentry);
	}



A file system implementation declares that instances of the filesystem
are exportable by setting the s_export_op field in the struct
super_block.  This field must point to a "struct export_operations"
struct which has the following members:

 encode_fh  (optional)
    Takes a dentry and creates a filehandle fragment which can later be used
    to find or create a dentry for the same object.  The default
    implementation creates a filehandle fragment that encodes a 32bit inode
    and generation number for the inode encoded, and if necessary the
    same information for the parent.

  fh_to_dentry (mandatory)
    Given a filehandle fragment, this should find the implied object and
    create a dentry for it (possibly with d_obtain_alias).

  fh_to_parent (optional but strongly recommended)
    Given a filehandle fragment, this should find the parent of the
    implied object and create a dentry for it (possibly with
    d_obtain_alias).  May fail if the filehandle fragment is too small.

  get_parent (optional but strongly recommended)
    When given a dentry for a directory, this should return  a dentry for
    the parent.  Quite possibly the parent dentry will have been allocated
    by d_alloc_anon.  The default get_parent function just returns an error
    so any filehandle lookup that requires finding a parent will fail.
    ->lookup("..") is *not* used as a default as it can leave ".." entries
    in the dcache which are too messy to work with.

  get_name (optional)
    When given a parent dentry and a child dentry, this should find a name
    in the directory identified by the parent dentry, which leads to the
    object identified by the child dentry.  If no get_name function is
    supplied, a default implementation is provided which uses vfs_readdir
    to find potential names, and matches inode numbers to find the correct
    match.

  flags
    Some filesystems may need to be handled differently than others. The
    export_operations struct also includes a flags field that allows the
    filesystem to communicate such information to nfsd. See the Export
    Operations Flags section below for more explanation.

A filehandle fragment consists of an array of 1 or more 4byte words,
together with a one byte "type".
The decode_fh routine should not depend on the stated size that is
passed to it.  This size may be larger than the original filehandle
generated by encode_fh, in which case it will have been padded with
nuls.  Rather, the encode_fh routine should choose a "type" which
indicates the decode_fh how much of the filehandle is valid, and how
it should be interpreted.

Export Operations Flags
-----------------------
In addition to the operation vector pointers, struct export_operations also
contains a "flags" field that allows the filesystem to communicate to nfsd
that it may want to do things differently when dealing with it. The
following flags are defined:

  EXPORT_OP_NOWCC - disable NFSv3 WCC attributes on this filesystem
    RFC 1813 recommends that servers always send weak cache consistency
    (WCC) data to the client after each operation. The server should
    atomically collect attributes about the inode, do an operation on it,
    and then collect the attributes afterward. This allows the client to
    skip issuing GETATTRs in some situations but means that the server
    is calling vfs_getattr for almost all RPCs. On some filesystems
    (particularly those that are clustered or networked) this is expensive
    and atomicity is difficult to guarantee. This flag indicates to nfsd
    that it should skip providing WCC attributes to the client in NFSv3
    replies when doing operations on this filesystem. Consider enabling
    this on filesystems that have an expensive ->getattr inode operation,
    or when atomicity between pre and post operation attribute collection
    is impossible to guarantee.

  EXPORT_OP_NOSUBTREECHK - disallow subtree checking on this fs
    Many NFS operations deal with filehandles, which the server must then
    vet to ensure that they live inside of an exported tree. When the
    export consists of an entire filesystem, this is trivial. nfsd can just
    ensure that the filehandle live on the filesystem. When only part of a
    filesystem is exported however, then nfsd must walk the ancestors of the
    inode to ensure that it's within an exported subtree. This is an
    expensive operation and not all filesystems can support it properly.
    This flag exempts the filesystem from subtree checking and causes
    exportfs to get back an error if it tries to enable subtree checking
    on it.

  EXPORT_OP_CLOSE_BEFORE_UNLINK - always close cached files before unlinking
    On some exportable filesystems (such as NFS) unlinking a file that
    is still open can cause a fair bit of extra work. For instance,
    the NFS client will do a "sillyrename" to ensure that the file
    sticks around while it's still open. When reexporting, that open
    file is held by nfsd so we usually end up doing a sillyrename, and
    then immediately deleting the sillyrenamed file just afterward when
    the link count actually goes to zero. Sometimes this delete can race
    with other operations (for instance an rmdir of the parent directory).
    This flag causes nfsd to close any open files for this inode _before_
    calling into the vfs to do an unlink or a rename that would replace
    an existing file.
