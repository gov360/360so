cpu

个人cpu范围：玩游戏，看电影。。。游戏精简指令集。
AMD   便宜，性价比高
intel 科技含量，核心显卡 GPU   超线程技术。

服务器cpu： 稳定，运算能力强大， 数据吞吐量大。
intel 至强   处理能力很强。数据运算能力。还有很大的数据吞吐量， 缓存大。 稳定性很强。
没有核心显卡。

访问控制级别： ring0 - ring3
ring0        最高权限，核心级别
ring3	应用程序使用的权限

阻塞。。。。

个人浏览器
# getconf -a  查看缓存详细信息
# cat /proc/cpuinfo  查看CPU信息

cpu一个核心同时间只能处理一件事。

processor    逻辑处理器的id，虚拟机虚拟出来的

physical id     :  物理cpu的id
siblings：	逻辑核心的数量： 2个
core id         : 0 核心id
cpu cores       : 1 核心数量

cpu将缓存:分成多个组，每个组分成多个行
LEVEL1_ICACHE_SIZE                 32'768   缓存大小【字节】
LEVEL1_ICACHE_ASSOC                8	一个缓存分组中有多少行
LEVEL1_ICACHE_LINESIZE             64   一个行大小【字节】
LEVEL1_DCACHE_SIZE                 32'768
LEVEL1_DCACHE_ASSOC                8
LEVEL1_DCACHE_LINESIZE             64
LEVEL2_CACHE_SIZE                  262'144
LEVEL2_CACHE_ASSOC                 4
LEVEL2_CACHE_LINESIZE              64
LEVEL3_CACHE_SIZE                  6'291'456
LEVEL3_CACHE_ASSOC                 12
LEVEL3_CACHE_LINESIZE              64
LEVEL4_CACHE_SIZE                  0
LEVEL4_CACHE_ASSOC                 0
LEVEL4_CACHE_LINESIZE              0


load average: 0.00, 0.00, 0.00
对于单核心单cpu的情况：  时间片轮转，对于每一个进程，申请一定时间片，时间片分配时间到了，进程失去对于cpu的使用权限，需要继续申请等待。
1.00	正好使cpu处于满运作状态，而且正好完全处理完成所有任务，没有等待。
2.00	任务多于处理能力的一倍，一半任务在处理一半的任务在等待。
3.00	超过两倍，cpu已经有些处理不过来了。

对于n个核心：
n.00	正好使cpu处于满运作状态，而且正好完全处理完成所有任务，没有等待。
2n.00   
3n.00	

# getconf -a  查看缓存详细信息
# cat /proc/cpuinfo  |grep processor |awk -F : '{print $2}' | sort -u | wc -l
2


Cpu(s):  
0.0%us 没有调整过优先级的用户进程占用cpu百分比
0.0%sy,  系统进程占用cpu百分比
0.0%ni,	 修改过nice值得进程占用cpu百分比
	  nice -n 5 top
	  renice ...
100.0%id,  idle 空闲cpu
0.0%wa,  wait， 处于等待状态的进程占用cpu百分比。
0.0%hi,   hardware interrupt 硬件中断
0.0%si,   software interrupt 软件中断
0.0%st,	  steal time，
云厂商，对于大客户。

阿里云：

自动化：企业在积极研发适用于自己的平台。

腾讯，蓝鲸运维平台：对于大多数企业并不适用。

堆叠代码：
运维脚本： install_apache
           ....

针对不同业务，调整执行的代码脚本及其顺序。

根源： 制定了很严格的流程。

=============================================================

大数据算法：

=============================================================

virt	虚拟内存 虚内存
res 	resident常驻内存

==============================================================

监控cpu/men 发现问题，解决问题：
[root@laowang ~]# for i in `uptime | awk '{print $10,$11,$12}'| tr -d ','` ; do echo $i; done   
0.00
0.00
0.00

[root@laowang vm]# free -m | awk 'NR==3{print $4}'
1304
[root@laowang vm]# free -m | awk 'NR==4{print $3}'  
0

监控：
if [ 负载过高 ]:
  then
    mail 
fi

   如果发现load averag过高/内存可用量不足：
   如果是正常业务： 加硬件。。。
   如果业务占用cpu/mem不高，可能面临着非法用户的攻击：抓取攻击用户的ip信息，iptables。
   以上都不是，考虑是否最近自己有过更新或其他操作。----版本回滚。


负载均衡： 避免单点故障
	   降低成本。


上下文切换。


内存：
内存管理：
物理内存根据数据块进行分组，叫做“分页”。 一个分页默认4kb。

虚拟内存 或 虚内存【一定要和windows的虚拟内存区别开来，windows的虚拟内存相当于linux的swap】
程序在启动的过程中，向 os【内核】 申请的是虚拟内存。可能比较大，但是程序开始不会使用这么多。随着使用过程中不断加大。

os 内核 : 调度计算机中的硬件， 使用机器码，低级语言
shell ： 介于内核与人之间
人： 使用高级语言， c java c++ 拥有自己的编译工具

虚拟内存有一张内存关系映射表，可以映射到物理内存和swap上。
~~~~~分析linux内核。

注意：使用swap，并不代表物理内存不够用了。
内存的换入换出，
换入：从swap换入到内存，当换出的数据需要使用，可以将被换出的数据换入到内存中，加速调用过程。
换出：从内存换出到swap，如果有数据不经常使用但是占用缓存，有更重要的任务需要操作内存，需要进行换出

[root@host ~]# free -m
             total       used       free     shared    buffers     cached
Mem:          2006       1906         99         11        165       1041
-/+ buffers/cache:        698       1307 
Swap:         1999          0       1999 


used1       当前分配的物理内存
free1 	当前未分配的物理内存
used2 	当前实际使用的物理内存
free2	当前可以使用的物理内存

cache：
  buffer cache 磁盘缓冲，优化磁盘数据的写入
  page cache 文件缓存，加速文件读取速度


used1 = buffers + cached + used2

find / .....     速度很快，是因为vfs，inode和目录项dentry，加速文件路径名到inode的转换。

科班：
操作系统  数据结构

网络协议：  nginx  apache。。。。。
	http：
	tcp：

运维开发：
==================================================================================

内核调优：

flush 处理脏数据。

rhel7：
    docker


[root@host ~]# cat /proc/sys/vm/nr_pdflush_threads 

以触发的方式清理内存中的脏数据：服务器的内存比较大，建议调低。
[root@laowang vm]# cat dirty_background_ratio  默认10%，如果当前脏数据比例占总内存的10%，则触发清理脏数据进程，以后台方式运行，不影响磁盘正常读写。
[root@laowang vm]# cat dirty_ratio  默认20%，以阻塞的方式强制清理内存。可能会因为阻塞造成内存暂时不可用。

周期性清理内存：
[root@host ~]# cat dirty_writeback_centisecs  默认500百分秒 = 5秒，5秒触发一次脏数据写回磁盘操作。

[root@host ~]# cat dirty_expire_centisecs  默认3000百分秒=30秒，脏数据一旦生成，不会立即清理，等待一定时间再清理。

[root@host ~]# cat vfs_cache_pressure  调整系统缓存目录项和inode的策略，默认100，如果设置小于100，系统会尽量保留缓存的目录项和i节点，如果设置大于100，系统根据实际情况不保留。建议调高，200.

[root@host ~]# cat min_free_kbytes  系统保留的最小内存：默认45056kb，大于8G内存的系统建议256M 或 512M


内存超载：
[root@host ~]# cat /proc/sys/vm/overcommit_memory
[root@laowang vm]# cat overcommit_memory 
0	内核自动选择虚内存的使用范围。
1 	允许超过CommitLimit，直至内存耗尽。不建议使用。
2	不允许超过CommitLimit

[root@host ~]# cat /proc/sys/vm/overcommit_ratio 
[root@laowang vm]# cat overcommit_ratio  
50

[root@laowang vm]# cat /proc/meminfo |grep -i commit
CommitLimit:       3075092 kB     # 当前限制的分配的虚拟内存的大小
Committed_AS:    4075484 kB     # 当前已经分配的总虚拟内存大小。

cat swappiness 	表示内核使用swap的倾向，60，建议调整为0.

cat page-cluster 默认3，表示2的3次方=8个分页，一次内存的操作最小单位8个分页。swap换入换出。


[root@host ~]# cd /proc/sys/vm/
[root@host vm]# ls
admin_reserve_kbytes          legacy_va_layout                oom_dump_tasks
block_dump                        lowmem_reserve_ratio        oom_kill_allocating_task
compact_memory                max_map_count                 overcommit_kbytes
dirty_background_bytes       meminfo_legacy_layout      overcommit_memory
dirty_background_ratio        memory_failure_early_kill    overcommit_ratio
dirty_bytes                           memory_failure_recovery    page-cluster
dirty_expire_centisecs           min_free_kbytes                 panic_on_oom
dirty_ratio                            min_slab_ratio                    percpu_pagelist_fraction
dirty_writeback_centisecs     min_unmapped_ratio         scan_unevictable_pages
drop_caches                        mmap_min_addr                stat_interval
extfrag_threshold                nr_hugepages                    swappiness
extra_free_kbytes                nr_hugepages_mempolicy          unmap_area_factor
hugepages_treat_as_movable  nr_overcommit_hugepages    vfs_cache_pressure
hugetlb_shm_group            nr_pdflush_threads              would_have_oomkilled
laptop_mode                      numa_zonelist_order            zone_reclaim_mode
[root@host vm]# 








