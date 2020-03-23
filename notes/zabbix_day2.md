主机： 	用来管理配置监控主机的选项。
	应用集：用来分类管理项目的。
	项目：	监控项。
	触发器：拥来定义报警的组件。定义阈值，已经定义报警的方式。
	图形：	将采集到的数据绘制出图形。
	探索：	自动发现，系统自动发现网络设备、挂载点等
	Web：	用户监控web页面，可用性、响应速度...\

注意：关联模板的时候要尽量避免重复。

项目：item

名称：item_name, 可以使用变量[宏变量]，$1 - $9 对应 item_key传递进来的9个参数。
类型：常见的。代理
键值：item_key
历史数据保留时长(单位天)：这个值会被管家覆盖。 管家：管理- 一般
趋势数据存储周期(单位天): 每个小时采集一次。使用的资源很小。
存储值：
	不变：数据采集和存储时相同。
	每秒速率：(当前值-上次采集的值)/(当前时间-上次采集的时间)
	简单变化：当前值-上次采集的值
展示值：自定义值对应- 管理-一般-值对应

自定义项目：
修改配置文件：
Include=/etc/zabbix/zabbix_agentd.conf.d/   # 监控项配置文件存放目录
UnsafeUserParameters=1         		       # 开启自定义监控项
UserParameter=			      # 自定义监控项的item_key

语法：
UserParameter=item_key,command
UserParameter=item_key[*],command   ---key[]中的参数对应$1 到 $9
	UserParameter=wc[*],grep -c "$2" $1
	key: wc[/etc/passwd,root]
例如：
UserParameter=process_num,ps aux|wc -l
方法1：
配置文件agentd.conf中直接添加
方法2：
cd /etc/zabbix/zabbix_agentd.conf.d/
vim 任意名称的文件
方法3：
通过脚本方式进行监控：
mkdir scripts
cat mem_use.sh 
#!/usr/bin/env bash

total=`head -2 /proc/meminfo | awk 'NR==1{print $2}'`
free=`head -2 /proc/meminfo | awk 'NR==2{print $2}'`

use=`echo "scale=2;($total-$free)*100/$total" | bc`
echo $use
------------
UserParameter=mem_use,bash /etc/zabbix/scripts/mem_use.sh


测试工具：
zabbix_get -s 10.1.1.2 -k "process_num"

=============================================================
触发器：
名称：可以使用zabbix的宏变量：{HOST.NAME}主机名   {HOST.IP}  {ITEM.VALUE}
表达式：{Template OS Linux:system.cpu.load[percpu,avg1].avg(5m)}>5  如果条件为真则触发报警。
语法：
{<server>:item_key.function}<运算符>常数
运算符：
+ - * / 
> < >= <= <> =
and or not


{www.zabbix.com:system.cpu.load[all,avg1].last()}>5

{www.zabbix.com:system.cpu.load[all,avg1].last()}>5 or {www.zabbix.com:system.cpu.load[all,avg1].min(10m)}>2 

{www.zabbix.com:vfs.file.cksum[/etc/passwd].diff()}=1

{www.zabbix.com:net.if.in[eth0,bytes].min(5m)}>100K

{smtp1.zabbix.com:net.tcp.service[smtp].last()}=0 and {smtp2.zabbix.com:net.tcp.service[smtp].last()}=0

{zabbix.zabbix.com:agent.version.str("beta8")}=1

{zabbix.zabbix.com:icmpping.count(30m,0)}>5

{zabbix.zabbix.com:tick.nodata(3m)}=1

{zabbix:system.cpu.load[all,avg1].min(5m)}>2 and {zabbix:system.cpu.load[all,avg1].time()}>000000 and {zabbix:system.cpu.load[all,avg1].time()}<060000

{MySQL_DB:system.localtime.fuzzytime(10)}=0

{server:system.cpu.load.avg(1h)}/{server:system.cpu.load.avg(1h,1d)}>2

{Template PfSense:hrStorageFree[{#SNMPVALUE}].last()}<{Template PfSense:hrStorageSize[{#SNMPVALUE}].last()}*0.1

({server1:system.cpu.load[all,avg1].last()}>5) + ({server2:system.cpu.load[all,avg1].last()}>5) + ({server3:system.cpu.load[all,avg1].last()}>5)>=2

=====================================================================

邮件报警： msmtp+mutt
mail
yum install -y mailx

/etc/mail.rc:
set from=vfast_2017@163.com smtp=smtp.163.com
set smtp-auth-user=vfast_2017@163.com smtp-auth-password=qwer1234
set smtp-auth=login
测试：
echo "this is mail text." | mail -s "mail title" wangjiale2009919@163.com

邮件报警设置：
/usr/local/zabbix/share/zabbix/alertscripts
sendmail.sh
#!/usr/bin/env bash
# $1 代表前端传进脚本的收件人， $2代表前端定义的标题 ，$3代表前端定义的邮件内容。
echo "$3" | mail -s "$2" $1

chmod +x sendmail.sh

1 管理 - 示警媒介类型 - 脚本 
2 管理 - 用户 - 指定用户 - 示警媒介
3 组态 - 动作 - 事件源：触发器 - 创建动作


动作操作
步骤	细节	开始于	持续时间(秒)	动作
1 - 4	送出信息给用户: chenchen (chen chen) 通过 zabbix-mail
送出信息给用户群组: group_test 通过 zabbix-mail
立即地	120	编辑   移除
5 - 10	送出信息给用户: Admin (Zabbix Administrator) 通过 zabbix-mail
送出信息给用户群组: Zabbix administrators 通过 zabbix-mail
00:08:00	60	编辑   移除
新的

=======================================================================

web 监控
web.test.fail: 检测web场景是否访问失败。
{ProjectA_test:web.test.fail[webtest].last(0)}<>0

web.test.error：web场景报错信息。
{host:web.test.error[Scenario].strlen()}>0 and {host:web.test.fail[Scenario].min()}>0

web.test.in： 检测指定阶段的下载速度。web.test.in[webtest,httpd,bps]
{host:web.test.in[Scenario,,bps].last()}<10000

web.test.time: 检测指定阶段的响应时间。
{zabbix:web.test.time[ZABBIX GUI,Login,resp].last()}>3

========================================================================

自动注册： 组态 - 动作- 事件源：自动注册 
Hostname=RHEL6_BJ_Ceshi_10.1.1.2

========================================================================

proxy
管理-系统代理程式 ： 名称和proxy的hostname对应。

=========================================================================

API 
第三方应用需要跟zabbix进行交互，需要传输json格式数据。
json数据格式：
数据对象：键值对
多个数据，逗号分隔
大括号保存对象
中括号保存数组
{
   "jsonrpc": "2.0",
   "method": "user.login",
   "params": {
   "user": "Admin",
   "password": "zabbix"
}
}

所有的API请求都要访问：
http://10.1.1.2/zabbix/api_jsonrpc.php
第一次调用API使用user.login方法：输入用户名密码信息。
系统将核对信息，如果无误，则返回sessionid给用户。
后续操作不需要在输入用户名密码，只需要提交sessionid就可以获取想要的数据了。

API官网：
https://www.zabbix.com/documentation/2.4/manual/api/reference/user/login

python auth.py 
Auth Successful. The Auth ID Is: 5f07a93ce5b2134e5825b9a994295e6b










