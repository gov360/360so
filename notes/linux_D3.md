用户管理


1、用户分类

	超级用户（root，0）
	普通用户
		系统用户（1~499）
		真实用户（500~42亿多，底层4B）

User ID   -->UID用户身份标示

2、群组分类
	linux中管理用户使用的用户-群组机制来管理
	
	超级用户群组
	系统用户群组
	用户自定义群组

group ID  -->GID群组身份标示


3、存放用户信息的文件：/etc/passwd

root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
cjk:x:500:500:cjk:/home/cjk:/bin/bash

第一列：用户名
第二列：密码占位符
第三列：用户身份标示，uid 
第四列：群组身份标示，gid，群组信息放在/etc/group
第五列：描述信息（comment）-c
第六列：用户的家目录
第七列：用户使用的shell    贝壳，壳
		交互式shell：/bin/bash       可以通过用户名和密码登陆系统，获得/bin/bash，跟系统交互
		非交互式shell:/sbin/nologin  无法通过用户名和密码登陆系统，用于系统用户。


创建用户的命令：
	useradd  [选项]  用户名
选项：
	-u：指定用户的uid
	-g：指定用户的gid
	-G：指定用户的附加组
	-c：指定用户的描述信息
	-d：指定用户的家目录（主目录、宿主目录）
	-s：指定用户使用的shell
	-o：指定用户的uid系统中已经被使用，如你仍然用这个uid，就可以使用这个选项强制使用，与-u结合使用
	-m：指定用户的家目录如果不存在，可以使用该选项自动创建上
	-e：指定用户过期时间。

	创建用户user1，描述信息为ceshi，用户的家目录/home/user1,用户的uid为1000，允许用户登陆系统，账号过期时间2017年3月22


删除用户：
	userdel [选项]  用户名
		-r	：彻底删除用户在系统上的文件。建议在删除用户时使用该选项。

更改用户信息：
	usermod  [选项] 用户名
选项：
	-u：指定用户的uid
	-g：指定用户的gid
	-G：指定用户的附加组
	-c：指定用户的描述信息
	-d：指定用户的家目录（主目录、宿主目录）
	-s：指定用户使用的shell
	-o：指定用户的uid系统中已经被使用，如你仍然用这个uid，就可以使用这个选项强制使用，与-u结合使用
	-m：指定用户的家目录如果不存在，可以使用该选项自动创建上
	-e：指定用户过期时间。

[root@localhost 桌面]# usermod -u 1002 -c test  -s /sbin/nologin user2
修改user2用户的uid为1002，描述信息为test，使用/sbin/nologin这个shell（不能登陆系统）

history命令：查看当前用户历史命令
！351	调用历史命令中第351条命令
！useradd	调用历史命令中最近一次执行过的useradd命令

	
查询用户信息（命令）：
	cat  /etc/passwd        head  tail  less more
	id  用户名

[root@localhost 桌面]# id cjk			//查看系统中有没有cjk这个用户
uid=500(cjk) gid=500(cjk) 组=500(cjk)


4、设置用户密码
	passwd [用户名]
		如果没有[]中的用户名，默认是给当前用户设置密码

	root可以给任何用户设置密码，不受密码长度限制
	普通用户需要至少8位字符，建议使用数字、字符、特殊符号来增加密码复杂度



用户密码存放文件：cat /etc/shadow
cjk:$6$KtLWVWrz$lJhdhJsF5x4Zi6FuW.uhqviJZMMxrH2aK2kq.rlegwdM2lhfPu3LyagSoU/iIl4CJ4tKF8YwWLVXvZswtXdXo1:17245:0:99999:7:::

第一列：用户名
第二列：加密后的密码  sha512   hash算法（哈希、散列）
	输入不固定，输出固定   128位	32位（md5）
	不可逆   ：   123 ---> abcddfsfa   
			abcddfsfa--->  不可逆
第三列：17245，单位是天。从1970年1月1号--->最近一次设置密码的那一天的累计天数。	
第四列：两次修改密码最小间隔天数。0表示随时可以修改密码。7，表示7天后才可以修改密码。
第五列：两次修改密码最大间隔天数。99999，表示没有限制。10，表示密码需要在10天之内修改。
	7  10     今天修改密码       7天后10天内可以修改密码---密码过期。
第六列：7，密码过期前警告天数。
第七列：宽限时间。默认0,没有宽限时间。5，依然可以使用原来的密码尝试登陆，在登陆的界面会强制你更新密码。
第八列：账户过期时间。默认没有值，表示账户不过期。
第九列：保留  （运行级别4）

chage 查看/设置用户密码信息
	-l 用户名：查看用户的密码信息。
	-m n：两次修改密码的最小间隔天数
	-M n：两次修改密码的最大间隔天数
	-W n：密码过期前警告天数
	-I n：密码过期后的宽限时间
	-E  :账号过期  格式“YYYY-MM-DD”   如果指定为-1，那么该账号永不过期。

在10天内不能修改用户密码，30天如果不修改密码那么密码过期，过期前3天警告，宽限期5天，账号过期时间2017、11、11
chage -m 10 -M 30 -W 3 -I 5 -E 2017-11-11 用户名

date查看和更改系统时间
[root@localhost 桌面]# date
2017年 03月 20日 星期一 14:28:38 CST
[root@localhost 桌面]# date 0319150017.00
	


6、群组信息/etc/group
	
	初始群组（创建用户时，默认创建的群组，这个群组叫做该用户的初始群组）
	主要群组（当前用户的有效群组）
	附加群组（次要群组）
	有效群组

[root@localhost 桌面]# id jiateng
uid=1004(jiateng) gid=1004(jiateng) 组=1004(jiateng),500(cjk)	//当前jiateng既属于jiateng群组，也属于cjk群组
[root@localhost 桌面]# su - jiateng
[jiateng@localhost ~]$ touch xx1.txt
[jiateng@localhost ~]$ ll xx1.txt 
-rw-rw-r-- 1 jiateng jiateng 0 11月 13 00:20 xx1.txt 	//用户在系统中活动，是以本用户及用户的有效群组的身份活动的
[jiateng@localhost ~]$ groups		//查看自己都属于哪些群组
jiateng cjk		//第一个群组即有效群组（主要），后面的群组都是附加群组（次要）
[jiateng@localhost ~]$ newgrp cjk	//切换有效群组为cjk
[jiateng@localhost ~]$ groups
cjk jiateng		//有效群组为cjk
[jiateng@localhost ~]$ touch xx2.txt
[jiateng@localhost ~]$ ll xx2.txt 
-rw-r--r-- 1 jiateng cjk 0 11月 13 00:21 xx2.txt	//证明用户是以本用户及有效群组在系统中活动的

/etc/group存放群组信息文件
root:x:0:
bin:x:1:bin,daemon
daemon:x:2:bin,daemon
sys:x:3:bin,adm
adm:x:4:adm,daemon
第一个字段：群组名称
第二个字段：群组密码占位符
第三个字段：gid，群组身份标示
第四个字段：群组成员，每个成员使用","隔开。表示该群组中有哪些用户。


添加群组
	groupadd [选项] 群组名称
		-g	指定群组id
[root@localhost 桌面]# groupadd vfast
[root@localhost 桌面]# groupadd -g 2000 rongxin
[root@localhost 桌面]# tail -2 /etc/group 
vfast:x:1005:
rongxin:x:2000:

删除群组
	groupdel 群组名

更改群组
	groupmod [选项] 群组名称
	-g	更改群组id
	-n	更改群组名称

[root@localhost 桌面]# groupmod -g 1006 vfast	更改群组id
[root@localhost 桌面]# tail -1 /etc/group 	//查看更改是否成功
vfast:x:1006:
[root@localhost 桌面]# groupmod -n rongxin vfast	//更改群组名称
[root@localhost 桌面]# tail -1 /etc/group 
rongxin:x:1006:


7、gpasswd 管理群组
语法：
gpasswd [option] group

-a	添加用户到群组
-d	从群组中踢除用户
-A	指定群组的管理员
-M	批量管理多个用户


[root@localhost 桌面]# gpasswd -a bd rongxin	//添加用户到群组
Adding user bd to group rongxin
[root@localhost 桌面]# gpasswd -A bd rongxin	//指定群组的管理员
[bd@localhost ~]$ gpasswd -d bd rongxin		//将踢出群组
Removing user bd from group rongxin

-M选项会覆盖掉群组中的原来的成员：
[root@localhost 桌面]# cat /etc/group | grep rongxin
rongxin:x:1006:jiateng,bd
[root@localhost 桌面]# useradd user3
[root@localhost 桌面]# useradd user4
[root@localhost 桌面]# gpasswd -M user1,user2,user3,user4,cjk rongxin
[root@localhost 桌面]# cat /etc/group | grep rongxin
rongxin:x:1006:user1,user2,user3,user4,cjk

	


8、添加用户的默认参考文件
default   缺省-->默认

/etc/default/useradd

[root@localhost ~]# cat /etc/default/useradd 
# useradd defaults file
GROUP=100	//兼容其他linux发行版
HOME=/home	//指定家目录
INACTIVE=-1	//密码是否过期
EXPIRE=		//账号是否过期
SHELL=/bin/bash	//shell类型
SKEL=/etc/skel	//用户环境变量的参考目录
CREATE_MAIL_SPOOL=yes	//是否创建邮箱

/etc/login.deft
[root@localhost 桌面]# cat /etc/login.defs  | grep -v "^$" | grep -v "^#"
MAIL_DIR	/var/spool/mail		//指定用户邮箱存放目录
PASS_MAX_DAYS	99999	//两次密码修改最大间隔天数
PASS_MIN_DAYS	0	//...最小...
PASS_MIN_LEN	5	//密码最短长度
PASS_WARN_AGE	7	//密码到期前警告天数
UID_MIN			  500		//最小uid
UID_MAX			60000	//最大uid
GID_MIN			  500
GID_MAX			60000
CREATE_HOME	yes	//创建家目录
UMASK           077	//普通用户的umask值
USERGROUPS_ENAB yes	//启动用户群组
ENCRYPT_METHOD SHA512 	//指定加密方法




添加注释：
:10,20 s/^/#/	表示10到20行，每行的开头用“#”替换

取消注释：
:10,20 s/#//	表示10到20行中每行出现的第一个#用“空”替换






