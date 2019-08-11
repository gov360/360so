mysql 优化

LAMP： 
web： 应用优化，varnish
      网络调优，tcp内核调优。
		路由分发，首页分发。

内存调优：
磁盘IO：磁盘调度算法。

ulimit -HSn 10240

apache:
somaxconn 

worker:线程模式。不建议使用。

<IfModule prefork.c>
StartServers       50
MinSpareServers    45
MaxSpareServers   70
ServerLimit      1500
MaxClients       1500
MaxRequestsPerChild  10000
</IfModule>

关闭一些不需要的模块。
长连接设置。
是否启用压缩。
过期设置。

-------------------------
编程核心：算法， 实现

shell-*****  命令多。 for if  while .. trap 
python-****   perl、ruby
go 谷歌
---------------------------------------------------

fastcgi进程常驻内存 ------ cgi调用过程中创建进程:

--------------------------------------------------

mysql 调优

tps：每秒传输次数

qps: 每秒查询次数，每秒执行的sql语句数量。
     = 峰值pv数 * 每个pv平均请求数 * 需要连接数据库的pv占所有pv的百分比
     = 184 * 15 * 0.1 = 276

一般不要超过1500.

ABBB： 通过架构进行优化。

oracle  db2  sqlserver

-----------------------------------------------------------------------

优化点：连接池

用户认证：
	root： 禁止root远程登录。
	用户： web用户，只允许固定的几个web过来访问。web:10.1.1.1-3   
							mysql: 'apache'@'10.1.1.1'
							
线程复用：mysql 默认有一个连接池，其中有空闲的线程。这种线程常驻内存，不会消失。
mysql> show variables like 'thread_cache_size';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| thread_cache_size | 0     |
+-------------------+-------+

建议值：
1G --->  8
2G ---> 16
3G ---> 32
>3G ---> 64 或 128  一般稍小于平均并发量。

修改值：
临时修改：
set global thread_cache_size=8;
或者修改配置文件：/etc/my.cnf
thread_cache_size=8

连接数限制：
mysql> show variables like 'max_connections';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 151   |
+-----------------+-------+
1 row in set (0.00 sec)

mysql> set global max_connections=1500; 
or my.cnf
max_connections=1500

检查内存-缓存：查询缓存,其中记录曾经查询过的sql语句及其结果。 key - value
select * from db1.t1 where id= 100;
id    name
100   xxx

mysql> set global query_cache_size=128000000;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'query_cache_size';
+------------------+-----------+
| Variable_name    | Value     |
+------------------+-----------+
| query_cache_size | 128000000 |
+------------------+-----------+
1 row in set (0.00 sec)

query_cache_size=128M


-------------------------------------------------------------------------

sql接口： 用来接收用户发送的sql语句。
parser：解释器，用来解释sql语句。
optimizer: 优化器，把解释后的sql语句以最优的方式在当前的mysql中执行，优化数据检索方式。
mysql缓存：key缓存【myisam】  和 innodb缓存。


innodb缓存设置：事务，事务具有原子性。成功：commit  失败：回滚
mysql> show variables like '%innodb_buffer%';
+-------------------------+---------+
| Variable_name           | Value  	     |
+-------------------------+---------+
| innodb_buffer_pool_size | 8388608 |
+-------------------------+---------+

注意这个变量是只读变量，不能通过set global方式进行修改，只能在配置文件中进行配置。

这个值，对于单一mysql服务器，70%-80%的总内存大小。
16G内存：
innodb_buffer_pool_size=12G


myisam缓存设置：
mysql> show variables like '%key_buffer%';   
+-----------------+---------+
| Variable_name   | Value   |
+-----------------+---------+
| key_buffer_size | 8384512 |
+-----------------+---------+

mysql> set global  key_buffer_size=256000000;        
Query OK, 0 rows affected (0.11 sec)

mysql> show variables like '%key_buffer%';   
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| key_buffer_size | 256000000 |
+-----------------+-----------+
1 row in set (0.00 sec)

================================================================================

slow.log:记录慢速日志。记录mysql中哪些sql语句执行过慢，以便进行优化。
my.cnf
log_slow_queries=/tmp/my_slow.log
long_query_time=4


缓存表的数量限制：查看系统有多少张表，进行设置。
mysql> show variables like '%table_open_cache%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| table_open_cache | 64    |
+------------------+-------+

table_open_cache=128
flush tables;   ---- 清空缓存的表


临时表：
mysql> show variables like '%tmp%table%';  
+----------------+----------+
| Variable_name  | Value      |
+----------------+----------+
| max_tmp_tables | 32          |
| tmp_table_size | 16777216 |  小于16M的临时表使用内存进行存储数据，大于放入磁盘。
+----------------+----------+


系统超时时间：
mysql> show variables like '%timeout%';  
+----------------------------+-------+
| Variable_name              | Value      |
+----------------------------+-------+
| connect_timeout            | 10          |
| delayed_insert_timeout     | 300      |
| innodb_lock_wait_timeout   | 50     |
| innodb_rollback_on_timeout | OFF  |
| interactive_timeout        | 28800 |  建议和wait_timeout一起调整
| net_read_timeout           | 30     |
| net_write_timeout          | 60     |
| slave_net_timeout          | 3600   |
| table_lock_wait_timeout    | 50    |
| wait_timeout               | 28800     |
+----------------------------+-------+

建议在配置文件中进行修改：
interactive_timeout=60
wait_timeout=60


innodb日志级别： innodb日志如何写入磁盘
mysql> show variables like '%innodb_flush%';
+--------------------------------+-------+
| Variable_name                  | Value       |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 1     |

0	最不安全，每隔一秒将数据写入硬盘。期间数据缓存在mysql运行内存中。
1	最安全，默认级别，将日志数据实时写入硬盘
2	数据先写入系统缓存，比0模式安全，比1模式更快。



数据写入磁盘方式：
innodb_flush_method=0_DIRECT   不通过系统缓冲，将数据写入磁盘。避免额外的数据复制和double buffering【mysql buffer 和 OS buffer】。




# 最大连接数限制
max_connections=1500
# 线程池中可用线程大小
thread_cache_size=16
# 查询缓存大小
query_cache_size=128M
# innodb缓存 和 myisam缓存
innodb_buffer_pool_size=512M
key_buffer_size=256M
# 慢速日志
log_slow_queries=/tmp/my_slow.log
long_query_time=4
# 缓存表数量
table_open_cache=128
# 非交互操作超时时间
interactive_timeout=10
wait_timeout=10
# innodb日志缓存方式
innodb_flush_log_at_trx_commit=2
# innodb数据缓存方式
innodb_flush_method=0_DIRECT

----------------------------------------------------------------------

./mysqlreport

--user 	用户名
--password 指定密码
--port  指定端口
--host  指定主机
--socket 指定sock接口文件
--outfile 将输出写入指定位置的文件。

----------------------------------------------------------------------

lua + nginx  亿级web架构。

----------------------------------------------------------------------
===========================================================================

数据库管理：运维不可分割。



IDC机房运维
监控
桌面运维： 万能，修电话，修打印机，修空调。。。

资产工程师：
	笔记本、台式机、服务器、带宽、cdn。。。。。

系统运维工程师：
	服务器系统稳定运行。
	邮件服务器
	web
	数据库
	。。。。
	测试机 研发、测试、。。

服务器安全、产品上线、更新维护、下线。。。

。。。。

管理海量服务器。
日志，E+L+K   【python。。编程工具进行二次开发。】

=====================================================================================

