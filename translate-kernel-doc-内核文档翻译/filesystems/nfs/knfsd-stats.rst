============================
Kernel NFS Server Statistics
============================

本文是基于Documentation/filesystems/nfs/knfsd-stats.rst以下提交记录:

.. code-block:: shell

	commit cb63032b1233e03ac20fc2b60820a50d605b9bc0
	Author: Daniel W. S. Almeida <dwlsalmeida@gmail.com>
	Date:   Wed Jan 29 01:49:17 2020 -0300

	Documentation: nfs: knfsd-stats: convert to ReST

:Authors: Greg Banks <gnb@sgi.com> - 26 Mar 2009

本文档描述了内核 NFS 服务器提供给用户空间的统计信息的格式和语义。 这些统计数据以多个文本形式的伪文件提供，下面分别对每个文件进行描述。

在大多数情况下，您不需要知道这些格式，因为 nfs-utils 发行版中的 nfsstat(8) 程序提供了一个有用的命令行界面来提取和打印它们。

此处描述的所有文件都被格式化为一系列文本行，由换行符 '\n' 字符分隔。 以散列“#”字符开头的行是供人类使用的注释，解析例程应忽略。 所有其他行包含由空格分隔的字段序列。

/proc/fs/nfsd/pool_stats
========================

如果挂载了 /proc/fs/nfsd 文件系统（它几乎总是应该挂载），则该文件在 2.6.30 以后的内核中可用。

第一行是描述所有其他行中存在的字段的注释。 其他行将以下数据显示为一系列无符号十进制数字字段。 每个 NFS 线程池显示一行。

所有计数器都是 64 位宽并自然换行。 没有办法将这些计数器归零，而是应用程序应该进行自己的速率转换。

pool
	The id number of the NFS thread pool to which this line applies.
	This number does not change.

	Thread pool ids are a contiguous set of small integers starting
	at zero.  The maximum value depends on the thread pool mode, but
	currently cannot be larger than the number of CPUs in the system.
	Note that in the default case there will be a single thread pool
	which contains all the nfsd threads and all the CPUs in the system,
	and thus this file will have a single line with a pool id of "0".

packets-arrived
	Counts how many NFS packets have arrived.  More precisely, this
	is the number of times that the network stack has notified the
	sunrpc server layer that new data may be available on a transport
	(e.g. an NFS or UDP socket or an NFS/RDMA endpoint).

	Depending on the NFS workload patterns and various network stack
	effects (such as Large Receive Offload) which can combine packets
	on the wire, this may be either more or less than the number
	of NFS calls received (which statistic is available elsewhere).
	However this is a more accurate and less workload-dependent measure
	of how much CPU load is being placed on the sunrpc server layer
	due to NFS network traffic.

sockets-enqueued
	Counts how many times an NFS transport is enqueued to wait for
	an nfsd thread to service it, i.e. no nfsd thread was considered
	available.

	The circumstance this statistic tracks indicates that there was NFS
	network-facing work to be done but it couldn't be done immediately,
	thus introducing a small delay in servicing NFS calls.  The ideal
	rate of change for this counter is zero; significantly non-zero
	values may indicate a performance limitation.

	This can happen because there are too few nfsd threads in the thread
	pool for the NFS workload (the workload is thread-limited), in which
	case configuring more nfsd threads will probably improve the
	performance of the NFS workload.

threads-woken
	Counts how many times an idle nfsd thread is woken to try to
	receive some data from an NFS transport.

	This statistic tracks the circumstance where incoming
	network-facing NFS work is being handled quickly, which is a good
	thing.  The ideal rate of change for this counter will be close
	to but less than the rate of change of the packets-arrived counter.

threads-timedout
	Counts how many times an nfsd thread triggered an idle timeout,
	i.e. was not woken to handle any incoming network packets for
	some time.

	This statistic counts a circumstance where there are more nfsd
	threads configured than can be used by the NFS workload.  This is
	a clue that the number of nfsd threads can be reduced without
	affecting performance.  Unfortunately, it's only a clue and not
	a strong indication, for a couple of reasons:

	 - Currently the rate at which the counter is incremented is quite
	   slow; the idle timeout is 60 minutes.  Unless the NFS workload
	   remains constant for hours at a time, this counter is unlikely
	   to be providing information that is still useful.

	 - It is usually a wise policy to provide some slack,
	   i.e. configure a few more nfsds than are currently needed,
	   to allow for future spikes in load.


Note that incoming packets on NFS transports will be dealt with in
one of three ways.  An nfsd thread can be woken (threads-woken counts
this case), or the transport can be enqueued for later attention
(sockets-enqueued counts this case), or the packet can be temporarily
deferred because the transport is currently being used by an nfsd
thread.  This last case is not very interesting and is not explicitly
counted, but can be inferred from the other counters thus::

	packets-deferred = packets-arrived - ( sockets-enqueued + threads-woken )


More
====

Descriptions of the other statistics file should go here.
