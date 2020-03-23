jinja 渲染：

{%%}
{%if 条件%}
{%elif 条件%}
{%endif%}

{%for%}
{%endfor%}

{%set 变量名 = 值%}
取变量值： {{变量名}}

1 如果在sls文件中，可以直接使用上面格式，
2 如果在配置文件中，使用jinja，需要在相应的sls文件中： [template: jinja]

apache_install:
  pkg.installed:
    {%if grains['os'] == "RedHat"%}
    - name: httpd
    {%elif grains['os'] == "Ubuntu"%}
    - name: apache2
    {%endif%}

app_install:
  pkg.installed:
    {%if grains['id'] == "minion_1.2"%}
    - name: mysql-server
    {%elif grains['id'] == "minion_1.3"%}
    - name: httpd
    {%endif%}

------------------------------------------------------
批量创建用户：

user.present

{%set user=['tom1','tom2','tom3']%}
{%for u in user%}
{{u}}:
  user.present:
    - fullname: {{u}}Chen
    - shell: /bin/bash
    - home: /home/{{u}}
{%endfor%}

-------------------------------------------------------

master:
vim /srv/salt/httpd
ServerName {{grains['ip4_interfaces']['eth1'][0]}}:80

install_httpd:
  pkg.installed:
    - name: httpd

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://httpd.conf
    - require:
      - pkg: httpd
    - template: jinja  # 加载jinja模板

httpd:
  service.running:
    - require:
      - pkg: httpd
    - watch:
      - file: /etc/httpd/conf/httpd.conf

-------------------------------------------------------

练习：mysql AB复制

-------------------------------------------------------

include： 加载sls文件

init.sls
include:
  - web_install.apache  # 加载对应salt家目录下面web_install/apache.sls文件
  - web_install.mysql
  - web_install.php

---------------------------------------------------------

extend：

vim init.sls                      

include:
  - web_install.httpd_install

extend:
  httpd:
    service:
      - running
      - watch:
        - file: /etc/httpd/conf/httpd.conf

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://httpd.conf
    - template: jinja
~                         

web_install/httpd_install.sls:
httpd:
  pkg.installed

------------------------------------------------------------

top:  入口文件 /srv/salt/top.sls

vim top.sls
base:
  'minion_1.2':
    - mysql_install
  'minion_1.3':
    - httpd_install
    - php_install

salt '*' state.highstate
等价于：
salt 'minion_1.2' state.sls mysql_install
salt 'minion_1.3' state.sls httpd_install
salt 'minion_1.3' state.sls php_install


1、2 --- nginx/lvs
3、4 --- httpd
5、6 --- mysql


分组：nodegroup
nodegroups:
  webgroup: 'minion_1.2'
  dbgroup: 'minion_1.3'

salt -N 'nodegrouop组名' 命令


top.sls
通过分组进行匹配：
base:
  webgroup:
    - match: nodegroup
    - apache_install
  dbgroup:
    - match: nodegroup


    - mysql_install

通过grains信息进行匹配：
base:
  'id:minion_1.2':
    - match: grain
    - apache_install
  'id:minion_1.3':
    - match: grain
    - mysql_install

--------------------------------------------------------------

include  ： 加载外部sls文件
extend   ： 对sls文件进行扩展
top 入口文件   state.highstate

---------------------------------------------------------------

python 与数据库进行交互：mysql
1 安装
yum install -y MySQL-python
2 导入模块：import MySQLdb
3 创建对数据库的连接：
变量名 = MySQLdb.connect('host','user','password','database')
4 构建一个操作接口：
cursor = 变量名.cursor()
5 编写sql语句
sql = 'show database'
6 执行sql语句
cursor.execute(sql)
7 cursor.fetchone 或 cursor.fetchall 来获取执行的返回结果。
8 变量名.close()
9 * 注意对于innodb表，rollback 、commit, 基于事务，原子性操作
    修改如果不使用commit，数据将不会写入到数据库。
    动作成功 conn.commit()
    动作失败 conn.rollback()


>>> conn = MySQLdb.connect('127.0.0.1','root','','db1')
>>> cursor=conn.cursor()
>>> sql = 'create table t1(name char(10));'     
>>> cursor.execute(sql)
0L
>>> sql = 'create table t2(name char(10))engine=innodb;'
>>> 
>>> cursor.execute(sql)                                 
0L
>>> sql = 'insert into t1 values("ChenChen");' 
>>> cursor.execute(sql)                       
1L
>>> sql = 'insert into t2 values("ChenChen");'
>>> cursor.execute(sql)                       
1L
>>> conn.commit()
>>> conn.close()

--------------------------------------------------------------------

minion 将返回信息放入自己数据库中：
1 grant all on *.* to 'salt'@'%' identified by '123';

2 修改minion配置文件
mysql.host: '10.1.1.2'
mysql.user: 'salt'
mysql.pass: '123'
mysql.port: 3306
/etc/init.d/salt-minion restart

3 yum install -y MySQL-python

4 mysql < salt.sql
vim salt.sql
# /usr/lib/python2.6/site-packages/salt/returners/mysql.py
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `salt`;

--
-- Table structure for table `jids`
--

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_returns`
--

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_events`
--

DROP TABLE IF EXISTS `salt_events`;
CREATE TABLE `salt_events` (
`id` BIGINT NOT NULL AUTO_INCREMENT,
`tag` varchar(255) NOT NULL,
`data` mediumtext NOT NULL,
`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`master_id` varchar(255) NOT NULL,
PRIMARY KEY (`id`),
KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


5 测试：
salt 'target' test.ping --return mysql

-------------------------------------------------------------------------

1 module:
cd /usr/lib/python2.6/site-packages/salt/modules/
salt 'target' test.ping
salt 'target' state.sls sls_file_name
salt 'target' pkg.install httpd

2 state:
/usr/lib/python2.6/site-packages/salt/states
sls_file:
id:
  state_module.function
  ......

install_apache:
  pkg.installed:
    - name: httpd
...............................

include  init.sls:
include:
  目录名.sls文件名

extend
top.sls 入口文件
base:
  'target':
  - install_lvs

salt 'target' state.highstate

3 jinja模板
4 grains 记录minion的静态信息的模块
salt -G ''
通过grains信息进行匹配：
base:
  'id:minion_1.2':
    - match: grain
    - apache_install

5 分组 nodegroup
salt -N ''
top.sls
base:
  webgroup:
    - match: nodegroup
    - apache_install

6 salt '' command --return mysql
7 pam 用户验证
external_auth:
  pam:
    chenchen:
      - test.ping
      - cmd.*

salt -a pam 'minion_1.2' cmd.run "date"

-------------------------------------------------------------------------

二次开发：

salt的体系结构：
#publish_port: 4505
#ret_port: 4506

1 创建一个操作对象：需要操作哪个minion
salt 'minion_1.2' test.ping

2 用户的请求通过4506发送给reqserver

3 reqserver 将请求交给 mworker

4 mworker 确定你是否有权限干这个活

5 mworker 宣告任务开始， 通过eventpublisher 发布消息

6 消息通过publisher 加密进行传输，发送给所有的minion

7 minion与master的4505进行连接。接收master上的命令

8 minion分析接收到的命令，解密，查看target是不是自己，如果是，在本地模块中找命令进行操作。
						      如果不是，不进行处理。

9 minion处理完成，将数据返回给master的4506

10 reqserver接收到 minion 返回的信息， 交给mworker，mworker解密，通过eventpublisher发布相应的minion执行状态。

11 用户接收master返回的信息，成功、失败 或者 超时

12 等待所有操作完成，或者超时，关闭任务。


------------------------------------------------------------

reactor ：
/etc/salt/master：
reactor:
  - 'tag_id':
    - '要调用的sls文件'


/srv/reactor/aaa.sls
{%if data['fun'] == 'test.ping' and data['success'] == True%}
shutdown:
  local.cmd.run:    # modules
    - tgt: 'minion_1.3'
    - arg:
      - 'shutdown -h 8'
{%endif%}

reactor:
  - 'salt/job/*/ret/minion_1.2':
    - '/srv/reactor/aaa.sls'

salt 'target' cmd.run "command"

======================================================================================

自定义modules：

1 创建目录：/srv/salt/_modules
2 编写模块：/srv/salt/_modules/m1.py
#!/usr/bin/env python

def func1():
    '''
    my first salt module.
    '''
    print "this is function1."
    return True

3 将模块同步到目标机器上：
salt 'target' saltutil.sync_modules

4 执行模块：
salt 'minion_1.2' m1.func1  

# __salt__['cmd.run'](arg1)
# __grains__['os']

---------------------------------------------------

m2.py
#!/usr/bin/env python

def func2(arg1):
    return arg1 ** 2

---------------------------------------------------

>>> commands.getoutput('pwd')
'/usr/lib/python2.6/site-packages/salt/modules'
>>> commands.getoutput('whoami')

salt 'target' cmd.run "date"

调用salt中已有模块：
__salt__['模块名.函数名'](arg)

m3.py
#!/usr/bin/env python

def func3(arg):
    out = __salt__['cmd.run'](arg)
    return out

---------------------------------------------------

自定义event信息
__salt__['event.send'](tag, data)

vim /srv/salt/__modules/m4.py
#!/usr/bin/env python
def func4():
    __salt__['event.send']("run m4.func4", {'user':'chenchen'})
    return True


------------------------------------------------------------

自定义grains： setval

方法1：master
salt 'target' grains.setval city bj
方法2：minion
/etc/salt/grains  or  /etc/salt/minion

方法三：自定义grains
1 mkdir /srv/salt/_grains
2 /srv/salt/_grains/g1.py
#!/usr/bin/env python
def f1():
    grains = {}
    grains['city'] = "shanghai"
    return grains
3 salt 'target' saltutil.sync_grains
4 salt '' grains.get city

作用：
1 salt -G "os:RedHat"
2 top.sls
base:
  'os:RedHat'
    - match: grain
    - install_apache
3 在自定义模块的脚本中调用grains信息：

在脚本中可以调用minion中已有的grains：
__grains__['os']

=====================================================================================
自定义state

salt 'target' state.sls sls文件名

install_httpd:
  pkg.installed:
    - name: httpd

1 mkdir /srv/salt/_states
2 vim /srv/salt/_states/s1.py
#!/usr/bin/env python
def bs(name, x):
    ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': "my first state function"
    }
    try:
        result = x ** 2
        ret['changes']['Chengfang'] = result
        ret['result'] = True
    except:
        ret['changes']['wrong'] = "there is something wrong."
    return ret

3 salt 'target' saltutil.sync_states

cat ../jisuan.sls 
test:
  s1.bs:
    - x: 3

======================================================================================


练习：根据如下sls文件，自定义state模块。

【/srv/salt/cmd_run.sls】
cmd:
  systemcommand.execute:
    - cmd: 'whoami'

【/srv/salt/_states/systemcommand.py】
#!/usr/bin/env python
import commands
def execute(name, cmd):
    ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': 'systemcommend'
    }
    try:
        result = commands.getoutput(cmd)
        ret['changes']['output'] = result
        ret['result'] = True
    except:
        ret['changes']['wrong'] = 'some thing wrong'

    return ret

[root@localhost salt]# salt 'minion_10.1.1.2' saltutil.sync_states
[root@localhost salt]# salt 'minion_10.1.1.2' state.sls cmd_run
