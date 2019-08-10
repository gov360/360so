saltstack: 配置管理工具

python 开发，由python模块组合成的一个工具
C/S架构
server:  master
client:  minion

特点：
1 使用消息队列，zeromq。能够快速的对很多机器进行操作。
2 消息传输都是加密的。RSAkey.

salt的配置文件的格式：YAML

master:
vi /etc/salt/master
interface: 10.1.1.1
# The tcp port used by the publisher:
#publish_port: 4505

# The user under which the salt master will run. Salt will update all
# permissions to allow the specified user to run the master. The exception is
# the job cache, which must be deleted if this user is changed. If the
# modified files cause conflicts, set verify_env to False.
#user: root

# The port used by the communication interface. The ret (return) port is the
# interface used for the file server, authentication, job returns, etc.
#ret_port: 4506

minion:
master: 10.1.1.1
id: minion_1.2

/etc/init.d/salt-minion restart

校验安装结果：
salt-key
salt-key -L 	查看所有key状态
salt-key -a minion_1.2   接受某一台minion的key
salt-key -A		 接受所有key
salt-key -d minion_1.2   删除一个minion的key
salt-key -D		 删除所有key
测试ping minion：
salt 'minion_1.2' test.ping

# 创建salt的家目录
mkdir /srv/salt 

----------------------------------------------------

计划任务cron：
salt 'minion_1.1' cron.set_job root '*' '*' '*' '*' '*' /tmp/date.sh # 添加计划任务
salt 'minion_1.2' cron.rm_job root /tmp/date.sh	# 删除计划任务
salt 'minion_1.2' cron.raw_cron root    # 查看minion的root用户的计划任务

运行命令cmd.run：
salt 'minion_1.2' cmd.run 'df -Th'

运行脚本cmd.script:
salt 'minion_1.2' cmd.script salt://date.sh

包管理：pkg
pkg.install 
salt 'minion_1.3' pkg.install httpd
salt 'minion_1.3' pkg.file_list httpd

服务管理：service
salt 'minion_1.3' service.restart httpd 
salt 'minion_1.3' service.start httpd 
status\reload\stop...

--------------------------------------------------------

minion 的过滤方法：
1 通配符：* ? []
2 -E 通过正则表达式进行匹配
3 -L 'minion_1.2,minion_1.3'  通过列表对id进行过滤
4 -S 通过ip或者ip子网进行匹配过滤
[root@localhost salt_package-2016.11.1]# salt -S 10.1.1.3 test.ping
[root@localhost salt_package-2016.11.1]# salt -S 10.1.1.0/24 test.ping
5 -C 混合匹配 可以使用 and or not
salt -C 'E@^minion_1.3 or L@minion_1.2' test.ping 
6 -G 可以通过被监控主机的grains进行过滤
salt -G 'os:RedHat' test.ping

---------------------------------------------------------

grains : 是saltstack记录minion静态信息的组件。cpu、内存、磁盘、网卡等等信息。
salt '*' grains.items 	查看所有的grains及值
salt '*' grains.ls	查看所有grains 的名称，返回一个字典，字典的值是一个大列表。
salt 'minion_1.2' grains.item os_family	指定查看某个grains的值。
salt 'minion_1.2' grains.get os_family  与上面类似，仅返回值

设置grains：自定义
salt '*' grains.setval city bj [master]
or
vim /etc/salt/grains   [minion]
city: sz
or
vim /etc/salt/minion   [minion]
grains:
  city:
    - bj

---------------------------------------------------------
salt中模块位置：
/usr/lib/python2.6/site-packages/salt/modules

state : saltstack最核心的部分。需要编写sls【salt state file】文件，通过sls文件对被控制机器进行管理

state 的sls文件使用yaml格式。


id:
  module.function:    # 所在位置：/usr/lib/python2.6/site-packages/salt/states
    - name: name
    - argument1: value
    - argument2:
      - value1
      - value2

salt '目标' state.sls [sls文件名]

-----------------------------------------------------------

安装httpd：

cd /srv/salt
vim apache.sls
httpd:
  pkg.installed

or

install_apache:
  pkg.installed:
    - name: httpd

install_mysql:
  pkg.installed:
    - name: mysql

salt 'minion_1.2' state.sls apache

-------------------------------------------------------------

创建用户：
vim user_add.sls
tom:
  user.present:
    - fullname: TomChen
    - shell: /bin/bash
    - home: /home/tom

salt '*' state.sls user.add

------------------------------------------------------------

文件管理：file.py
1 文件同步到指定minion的指定目录中：
/tmp/passwd:
  file.managed:
    - source: salt://passwd
------------------------------------------------------------

管理apache:
1 安装httpd
2 拷贝配置文件
3 启动httpd 

案例一：
install_httpd:
  pkg.installed:
    - name: httpd

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://httpd.conf

httpd:
  service.running


案例二：在成功安装了httpd后再进行拷贝配置文件和启动httpd
install_httpd:
  pkg.installed:
    - name: httpd

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://httpd.conf
    - require:
      - pkg: httpd

httpd:
  service.running
    - require:
      - pkg: httpd

案例三： 一旦配置文件有改变，重启httpd服务

vim apache.sls  或者 vim apache/init.sls

install_httpd:
  pkg.installed:
    - name: httpd

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://httpd.conf
    - require:
      - pkg: httpd

httpd:
  service.running
    - require:
      - pkg: httpd
    - watch:
      - file: /etc/httpd/conf/httpd.conf

salt 'target' state.sls apache

=============================================================

练习：
安装mysql， 拷贝master上的模板配置文件【开启二进制日志】，并启动mysqld服务。

=============================================================

jinja 渲染：

yum install httpdd
yum install apache2



