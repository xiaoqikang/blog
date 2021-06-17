.. SPDX-License-Identifier: GPL-2.0

================================================
Multi-Queue Block IO Queueing Mechanism (blk-mq)（多队列块 IO 排队机制 (blk-mq)）
================================================

本文是基于Documentation/block/blk-mq.rst以下提交记录:

.. code-block:: shell
        commit 8ac867340bd8cc8c65d4cafbf634873b8ddcf3f7
        Author: Mauro Carvalho Chehab <mchehab+huawei@kernel.org>
        Date:   Tue Sep 29 10:04:26 2020 +0200

        docs: block: blk-mq.rst: get rid of :c:type

Multi-Queue Block IO Queuing Mechanism 是一种 API，可让快速存储设备通过排队并同时向块设备提交 IO 请求来实现每秒大量的输入/输出操作 (IOPS)，受益于现代存储提供的并行性 设备。

Introduction
============

Background
----------

从内核开发之初，磁硬盘一直是事实上的标准。 Block IO 子系统旨在为那些在进行随机访问时具有高惩罚的设备实现最佳性能，而瓶颈是机械运动部件，比存储堆栈上的任何层慢得多。这种优化技术的一个例子涉及根据硬盘磁头的当前位置对读/写请求进行排序。

然而，随着固态驱动器和非易失性存储器的发展，没有机械部件，也没有随机访问惩罚，能够执行高并行访问，堆栈的瓶颈已经从存储设备转移到了操作系统。为了利用这些设备设计中的并行性，引入了多队列机制。

前一种设计有一个单独的队列来存储带有单个锁的块 IO 请求。由于缓存中的脏数据和多个处理器的单一锁的瓶颈，这在 SMP 系统中不能很好地扩展。当不同的进程（或同一进程，移动到不同的 CPU）想要执行块 IO 时，这种设置也会遇到拥塞。取而代之的是，blk-mq API 会生成多个队列，这些队列具有 CPU 本地的各个入口点，从而无需锁定。下一节(`Operation`_)将更深入地解释其工作原理。

Operation
---------

当用户空间对块设备执行 IO（例如读取或写入文件）时，blk-mq 会采取行动：它将存储和管理对块设备的 IO 请求，充当用户空间（和文件系统，如果存在）和块设备驱动程序。

blk-mq 有两组队列：软件暂存队列和硬件调度队列。当请求到达块层时，它会尝试尽可能最短的路径：直接将其发送到硬件队列。但是，有两种情况它可能不会这样做：如果在该层附加了 IO 调度程序，或者如果我们想尝试合并请求。在这两种情况下，请求都会被发送到软件队列。

然后，在软件队列处理完请求后，它们将被放置在硬件队列中，第二阶段队列是硬件可以直接访问以处理这些请求。但是，如果硬件没有足够的资源来接受更多的请求，blk-mq 会将请求放置在一个临时队列中，以便将来在硬件有能力时发送。

Software staging queues
~~~~~~~~~~~~~~~~~~~~~~~

The block IO subsystem adds requests  in the software staging queues
(represented by struct blk_mq_ctx) in case that they weren't sent
directly to the driver. A request is one or more BIOs. They arrived at the
block layer through the data structure struct bio. The block layer
will then build a new structure from it, the struct request that will
be used to communicate with the device driver. Each queue has its own lock and
the number of queues is defined by a per-CPU or per-node basis.

The staging queue can be used to merge requests for adjacent sectors. For
instance, requests for sector 3-6, 6-7, 7-9 can become one request for 3-9.
Even if random access to SSDs and NVMs have the same time of response compared
to sequential access, grouped requests for sequential access decreases the
number of individual requests. This technique of merging requests is called
plugging.

Along with that, the requests can be reordered to ensure fairness of system
resources (e.g. to ensure that no application suffers from starvation) and/or to
improve IO performance, by an IO scheduler.

IO Schedulers
^^^^^^^^^^^^^

There are several schedulers implemented by the block layer, each one following
a heuristic to improve the IO performance. They are "pluggable" (as in plug
and play), in the sense of they can be selected at run time using sysfs. You
can read more about Linux's IO schedulers `here
<https://www.kernel.org/doc/html/latest/block/index.html>`_. The scheduling
happens only between requests in the same queue, so it is not possible to merge
requests from different queues, otherwise there would be cache trashing and a
need to have a lock for each queue. After the scheduling, the requests are
eligible to be sent to the hardware. One of the possible schedulers to be
selected is the NONE scheduler, the most straightforward one. It will just
place requests on whatever software queue the process is running on, without
any reordering. When the device starts processing requests in the hardware
queue (a.k.a. run the hardware queue), the software queues mapped to that
hardware queue will be drained in sequence according to their mapping.

Hardware dispatch queues
~~~~~~~~~~~~~~~~~~~~~~~~

The hardware queue (represented by struct blk_mq_hw_ctx) is a struct
used by device drivers to map the device submission queues (or device DMA ring
buffer), and are the last step of the block layer submission code before the
low level device driver taking ownership of the request. To run this queue, the
block layer removes requests from the associated software queues and tries to
dispatch to the hardware.

If it's not possible to send the requests directly to hardware, they will be
added to a linked list (``hctx->dispatch``) of requests. Then,
next time the block layer runs a queue, it will send the requests laying at the
``dispatch`` list first, to ensure a fairness dispatch with those
requests that were ready to be sent first. The number of hardware queues
depends on the number of hardware contexts supported by the hardware and its
device driver, but it will not be more than the number of cores of the system.
There is no reordering at this stage, and each software queue has a set of
hardware queues to send requests for.

.. note::

        Neither the block layer nor the device protocols guarantee
        the order of completion of requests. This must be handled by
        higher layers, like the filesystem.

Tag-based completion
~~~~~~~~~~~~~~~~~~~~

In order to indicate which request has been completed, every request is
identified by an integer, ranging from 0 to the dispatch queue size. This tag
is generated by the block layer and later reused by the device driver, removing
the need to create a redundant identifier. When a request is completed in the
drive, the tag is sent back to the block layer to notify it of the finalization.
This removes the need to do a linear search to find out which IO has been
completed.

Further reading
---------------

- `Linux Block IO: Introducing Multi-queue SSD Access on Multi-core Systems <http://kernel.dk/blk-mq.pdf>`_

- `NOOP scheduler <https://en.wikipedia.org/wiki/Noop_scheduler>`_

- `Null block device driver <https://www.kernel.org/doc/html/latest/block/null_blk.html>`_

Source code documentation
=========================

.. kernel-doc:: include/linux/blk-mq.h

.. kernel-doc:: block/blk-mq.c
