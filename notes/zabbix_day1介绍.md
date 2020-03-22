zabbix是一个基于WEB界面的提供分布式系统监视以及网络监视功能的企业级的开源解决方案。
agent端：主机通过安装agent方式采集数据。
server端：通过收集agent发送的数据，写入数据库（MySQL，ORACLE等），再通过php+apache在web前端展示.

zabbix最大的特点是分布式监控，自动发现，自定义监控项目。
监控系统所具备的四个要素  1、数据采集  2、数据存储  3、数据展示  4、事件报警
zabbix-serve：负责接收agent发送的报告信息，所有配置、统计数据及操作数据都有此组件组织进行；
 Agent：部署在被监控主机上，负责收集本地数据发往server或proxy端。
proxy：可选组件，常用于分布式监控环境中，代替server收集其他被监控端的监控数据，并统一发送到server端。
 web-interface：zabbix的GUI接口，通常与server运行在同一台主机上；
database：用于存储配置信息和zabbix收集的数据

五、zabbix的监控架构
在实际监控架构中，zabbix根据网络环境、监控规模等 分了三种架构： server-client 、master-node-client、server-proxy-client三种 。
1、server-client架构
也是zabbix的最简单的架构，监控机和被监控机之间不经过任何代理 ，直接由zabbix server和zabbix agentd之间进行数据交互。适用于网络比较简单，设备比较少的监控环境 。
2、server-proxy-client架构
其中proxy是server、client之间沟通的一个桥梁，proxy本身没有前端，而且其本身并不存放数据，只是将agentd发来的数据暂时存放，而后再提交给server 。该架构经常是和master-node-client架构做比较的架构 ，一般适用于跨机房、跨网络的中型网络架构的监控。
3、master-node-client架构
该架构是zabbix最复杂的监控架构，适用于跨网络、跨机房、设备较多的大型环境 。每个node同时也是一个server端，node下面可以接proxy，也可以直接接client 。node有自已的配置文件和数据库，其要做的是将配置信息和监控数据向master同步，master的故障或损坏对node其下架构的完整性。


正常： server[监控服务器]：10051 ---- agent[被监控机]:10050

分布式： server ---- proxy1 ---- agent
		     proxy2 ---- agent

阈值 == 阀值：
  if 超出阈值：
      报警

宏变量： global var

自动化动作：自动添加主机、自动删除主机。。
自动发现：

zabbix web前端：php

Zabbix API： 可以使得zabbix和第三方工具进行交互。

zabbix_server：  服务器守护进程
zabbix_proxy：   代理守护进程
zabbix_agentd： 客户端守护进程
zabbix_get： 测试工具，测试采集数据是否正常。



sed -i 's/before/after/g' filename   's/\/bin\/bash/\/sbin\/nologin/g'
sed -i 's%before%after%g' filename   's$/bin/bash$/sbin/nologin$g' 
sed -i 's@before@after@g' filename

Zabbix server


rpm -qa |grep php
rpm -e 包名 --nodeps

==================================================================

组态：
主机群组：用来分类管理主机和模板。Templates群组专门用来存放模板。
模板：	用户可以使用系统预先设定好的模板或自己定义模板。
	模板中预先设定好需要监控的项目、触发器、图形等信息。

主机： 	用来管理配置监控主机的选项。
	应用集：用来分类管理项目的。
	项目：	监控项。
	触发器：拥来定义报警的组件。定义阈值，已经定义报警的方式。
	图形：	将采集到的数据绘制出图形。
	探索：	自动发现，系统自动发现网络设备、挂载点等
	Web：	用户监控web页面，可用性、响应速度...
	
RHEL6_BJ_Ceshi_10.1.1.2

组态-维修：
案例：
一周维护一次，维护可能会出现误报警。
通过zabbix维护，自定义更新的时间。 在维护时间内，我们可以定义数据采集or不采集，这段时间都不会发生报警。

====================================================================

zabbix用户权限管理：
用户群组：  分类管理用户，并且规定群组中用户的最大权限。许可权只能被指派予用户群组
用户：	    用户不能脱离群组单独存在。
用户类型：用户不能自己修改自己的类型。
用户：  只有所在群组中的读的权限。
管理员：拥有所在群组中的最大权限。
超级管理员： 相当于linux的root用户，拥有最大权限。	

====================================================================






