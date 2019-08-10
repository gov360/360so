
【shell 脚本———七天课程】

######################################################################
【mysql 下午半天的sheLL】

kernel  负责驱动硬件

shell     翻译 表示  加解密

UI      user界面


[root@localhost 桌面]# cat /etc/shells
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh


不同的shell使用习惯不同

默认rhel shell  为 /bin/bash

[root@localhost 桌面]# echo $SHELL
/bin/bash


1. what's shell scripts
     目的：为了完成一个或多个任务     安装脚本   监控脚本    分析脚本
     脚本是一个过程脚本   完成一个任务的所有命令必须从上往下写

2. 如何写一个脚本
   脚本的名字 建议  功能.sh    扩展名  建议写  1.py 1.pl 1.c
   开头一定定义脚本的运行环境
   给脚本执行权限


将完成一个任务的所有命令按照执行顺序从上到下写入一个文件   并  给 执行权限
=
例如  新建用户  tom   密码是 123456   使用tom 创建/tmp/tom1-10


#!/bin/bash

# auther
# date
# version
# desc

useradd haha
echo 123456 | passwd --stdin haha
su - haha -c "touch /tmp/file{1..10}"

useradd  tom
echo 123456 | passwd --stdin tom
su - tom -c "touch /tmp/tom{1..10}"

作业：
B C D E 4块盘
两个区      1     2
1  KVM  vg100  lv100    pe 16M    /tmp/lv
2   r5                             /tmp/r5      ext4


分区磁盘脚本：
#!/bin/bash
#partition
fdisk /dev/sdb <<EOF
n
p
2

+200M
n
e
4


n
#!/bin/bash

#partition
fdisk /dev/sdb <<EOF
n
p
2

+200M
n
e
4


n
l

+300M
n
l


w
EOF


#flush 
wait
partx -a /dev/sdb

#format 

mkfs.ext2 /dev/sdb2 &
mkfs.ext3 /dev/sdb5 &
mkfs.ext4 /dev/sdb6 &

#mount
wait

mkdir /tmp/{a..c}

echo "/dev/sdb2         /tmp/a          ext2    defaults 0 0" >> /etc/fstab
echo "/dev/sdb5         /tmp/b          ext3    defaults 0 0" >> /etc/fstab
echo "/dev/sdb6         /tmp/c          ext4    defaults 0 0" >> /etc/fstab

mount -a

###################################################################

###################################################################

【第一天上午课程】

1.  shell 符号：


   ~   !   @   #   $   %   ^  &  *  ( )  [ ]  { } ?  " "   ' '  |   >  >>    <   <<    ;   ``     +   -  *  /  %




通配符
：    
～     匹配家目录
    
？     匹配一个字节   除回车以外
     
 *     匹配任意字节
     
 ( )    分组    a    (com)
     
 [ ]    匹配一个范围中的字节
    
 { }    匹配一个范围





运算符：


 +   -   *  /  %    ==




重定向          0   标准输入     1 标准输出      2 标准错误输出  

         |
	
        >     >>     1>a.log  2>error.log       2>&1      (>/dev/null 2>&1) &>/dev/null  
       
        <     <<   
 



其他字符
：	
           ！     @    #    
    
           $ 取内容符      XXXX=888  $XXXX
	 
           ^  $        正则表达式中有意义  
	 
           &      后台执行

          “ ”  ‘  ’ 如果没有变量就没有区别  单引号不解释变量
   
         ；  一行执行多条命令
        
            ` `  命令中执行命令 
	 
             .     ..     	

            赋值运算符  =  


========================================

运算  

整形   expr  

浮点   echo "scale=2;100/3"|bc      

    


=========================================


格式化输出   echo 
 
     -e   解释转义字符    \n 回车      \t  插入一个table键      \b 回退一个字节         \a 蜂鸣 
 
     -n  回车不换行




格式化输入   read  注意当程序执行到read的时候  就会停下来  等待用户的键盘输入  回车代表输入结束

      
       -s  关闭回显

      -n  接受键盘的几个字节

       -t  超时时间

       -p  打印输出




    

 






 






###################################################################

【第一天下午课程笔记】

系统本来就是一个程序    程序在运行中 会有很多数据产生   数据一般都会放到内存

系统在开机的时候 会把自己常用数据全部放到内存   方便自己使用

内存很大  那么系统将数据放入内存后如何找到数据       变量

变量  方便数据存入内存和读出


变量名=值    key=value

声明了变量名以后   内存划一片空间【空间是有地址的】    给这片空间起个名字  就是变量名     再把>数据存入这片空间

读   根据变量名找到空间的地址   读出这一片连续的地址对应空间的数据



系统中把自己的变量分类
      全局变量：      公共变量 ——任何人都可以使用
            1： /etc/profile           开机执行完init后加载
            4： /etc/bashrc
        	如何查看全局变量  printenv
        	如何定义全局变量  export 命令     export 变量名=value



    本地变量：      私有变量 ——只用用户自己能用    set 查看   unset 临时取消
              2： ～/.bash_profile
              3： ~/.bashrc


模拟用户登录脚本：
#!/bin/bash
clear
echo -e "Red Hat Enterprise Linux Server release 6.5 (Santiago)\nKernel `uname -r` on an `uname -m`\n"

read -p "Login:  "  user
read -s -p "Password:  "  pw

# sh login.sh
Red Hat Enterprise Linux Server release 6.5 (Santiago)
Kernel 2.6.32-573.el6.i686 on an i686
Login： root
Passwd：123456


作业：

KFC.sh  结算单脚本

#!/bin/bash

HBB=10.5
JC=11.5
KL=7.5
ST=4
QT=15

###### 1. 用户交互
read -p "汉堡：" NUM_HBB
read -p "鸡翅：" NUM_JC
read -p "可乐：" NUM_KL
read -p "薯条：" NUM_ST
read -p "其它：" NUM_QT

######## 2. 计算输出
clear
echo -e "\t\t\tKFC结算单"
echo "###########################################################"
echo -e "商品\t单价\t数量\t合计"
echo -e "汉堡\t$HBB\t$NUM_HBB\t`echo "scale=2; $HBB*$NUM_HBB" | bc`"
echo -e "鸡翅\t$JC\t$NUM_JC\t`echo "scale=2; $JC*$NUM_JC" | bc`"
echo -e "可乐\t$KL\t$NUM_KL\t`echo "scale=2; $KL*$NUM_KL" | bc`"
echo -e "其它\t$QT\t$NUM_QT\t`echo "scale=2; $QT*$NUM_QT" | bc`"
echo -e "\n"
echo -e "总计:\t `echo "scale=2; $HBB*$NUM_HBB+$JC*$NUM_JC+$KL*$NUM_KL+$QT*$NUM_QT"|bc`"
echo "###########################################################"
echo -e "吃点好的很有必要               营养健康每一天\n\n"

			KFC结算单
###########################################################
商品	单价	数量	合计
汉堡	10.5	5	52.5
鸡翅	11.5	5	57.5
可乐	7.5	3	22.5
其它	15	4	60

总计:	 192.5
###########################################################
吃点好的很有必要		营养健康每一天

==========================================================


##############################################################

【shell 第二天上午课程】

判断   if       负责判断      我想判断一下     ----->   if
判断就有对和错   真和假


语法:   if...else...fi

	if  [  条件  ]    # 如果条件为真
   	then             # 那么
                代码块      	    # 干啥
	else              # 否则
                代码块
	fi                  # 该判断结束



条件：可以是啥

     数学比较运算  >= (-ge)    > (-gt)  == (-eq)   <=（-le）  <(-lt)  != (-ne)


条件  可以是啥    # man test

     数学比较运算  >= (-ge)    > (-gt)  == (-eq)   <=（-le）  <(-lt)  != (-ne)
     字符串比较运算 ==    ！=   -z 字符串是否为空  -n 字符串是否不为空
     逻辑运算  与运算     要求两个或以上条件    真真为真  真假为假   假假为假   &&
                    或运算     要求两个或以上条件    真真为真  真假为真   假假为假   ||
                    非运算     要求只有一个条件       非真即假   非假即真                  ！
     文件判断   同一个文件  -ef       [ file1 -ef file2 ]
                     新旧判断    -ot   -nt
                     文件类型判断   -d   -f  -x -L ......

############################################################

【shell 第二天下午课程】

语法二：  单 if 语法
if [ 条件  ];then
    代码块
fi


语法三：  多条件 if

if [ tj1 ]; then
      command1
elif [ tj 2 ]; then
        command2
......
else
       commandx
fi

=============================================
ping -c1 IP &>/dev/null

if [ $? -ne 0 ];then....


if ping -c1 $IP &>/dev/null



#!/bin/bash
totle=`head -1 /proc/meminfo|awk '{print $2}'`
free=`head -2 /proc/meminfo|tail -1|awk '{print $2}'`

# use=`echo "($totle-$free)*100/$totle"|bc`
# if ((  ))    ((  )) 可以进行运算
a () {
if (( ($totle-$free)*100/$totle > 10 )); then
    echo haha
else
    echo hehe
fi
}



## [[  ]]  条件中可以植入shell的通配符 字符串
for i in ra cdd eff rbb cff
  do
      if [[ $i == r* ]];then
        echo $i
      fi
done


#!/bin/bash
echo "脚本的名字是: $0"
echo "脚本的参数是: $@"
echo "脚本的第2个参数是: $2"
echo "脚本共  $# 个参数"
echo "当前脚本的进程号是: $$"

作业：
判断某一年是不是闰年
公交刷卡程序    653路公交共30站   用户前10站   刷卡2元   以后每加五站   多刷1元   峰值6元  
上车没刷或下车没刷扣款6元   卡内余额不足报警提示
  线路号是 去  1-30      回30 - 1
由于我们没有设备    所以上车刷卡 卡内余额  下车刷卡 都由交互来完成

check_host
check_port
check_memory
拿不到数据     未知  3

80 warn  	    1
95 严重警告   2
80以下  ok     0          exit 0


思考  如何监控一个页面是否死了

==========================================================


######################################################

【第三天上午课程】

循环     for   while

1） 减少冗余代码
2） 节省内存


for和while什么时候用合适
如果你有明确的循环次数  就用for  没有明确的循环次数  就用while


for 条件循环        循环的次数和你给的条件成正比


语法
for 变量名  in  v1 v2  v3  v4 .......
   do
                代码块
done


打印1-9

条件  直接赋值    for i in 1 2 3 4 5 6 7 8 9
        使用命令    for i in `seq 1 9`          or     for i in /tmp
        是一句话    for i in  tom's house is kitty'sister


嵌套关系   for 嵌套if      for 嵌套  for


循环的控制
     break   跳出循环
     continue  跳过某次循环

=========for 的仿C写法 =============

随机一个数 1-100

要求你去猜

80

恭喜你猜对了   共猜5次

作 业：

   1 2 3 4 四个数字组成三位数 要求个十百位不能重复   问有多少种组合
   剪子石头布  你和机器人玩游戏
   安装apache2.4脚本  apr apr-util  httpd-2.4

   要求新建用户user01---user20 20个用户   密码为随机六位数   要求是大小写字母数字 最少两种组合

   扩展：
   
   21根火柴  你和机器人玩游戏  池中共21根火柴 你和机器人每次轮流拿  1-4根  最后一根剩谁手里谁输
    出海打渔  某渔民从2001年1月1日开始 3天打渔 两天晒网    问某年某月的某一天 他干啥呢


shell 仿C 写法
#include <stdio.h>

int main (void) {
   int a;
        for (a=1;a<10;a++)
                printf("%d\n",a);
}


#######################################################
【第4天上午课程】


while   不明确循环次数

while [ 条件 ]      条件为真 开始循环   条件参考if条件
       do

        代码块

      done

   or

  until [ 条件 ]    条件为假 开始循环
       do
             代码块
       done

嵌套关系
if  for  while until
循环控制
break
continue
sleep

########################################
exit 和  break 的区别
exit：会退出脚本，释放内存，
break：跳过当前循环，继续执行下面的条件，不影响脚本执行。

1*1=1
2*1=2   2*2=4
3*1=3   3*2=6  3*3=9

while 嵌套 until
1-5
6-9

#################################################

【shell-第四天下午课程】

----------------数组-----------------------------
    做一个学员信息收集系统     name id age gender score   假如学校有50个人     脚本中需要250变量
    数组：一个变量名后可以定义多个value
              数组 name id age gender score

  语法： 数组名=(v1 v2 v3 v4 v5 ......)

       name=('tom' 'kitty' 'jimi' 'jarry' ‘harry’)
如何读出
       ${数组名[索引]}      索引 元素的排列顺序  从0开始计数
       ${name[2]}
  数组 和 for

#!/bin/bash
name=('tom' 'kitty' 'jimi' 'jarry' 'harry')

#读出数组中的某个元素
#echo ${name[2]}

echo "数组中的所有元素是: ${name[@]}"
echo "数组中的元素数量: ${#name[@]}"
echo "数组中的元素索引是: ${!name[@]}"
echo "数组中索引为1开始的所有元素: ${name[@]:1}"
echo "数组中索引为1-3元素: ${name[@]:1:3}"


########### 函数 ################################


陈晨的一天
  1）起床
  2）上学的路上
  3）上课
  4）回家


1）拍错简单     500行的脚本拍错  和 50行排错 哪个块
2）减少了代码冗余
3) 改变代码自上而下的顺序


函数名 （） {

     代码块

}


function 函数名 {

    代码块
}

默认情况 函数不会执行 除非你调用它


nginx的启动管理脚本

start  stop  restart  reload  status


********************************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

【第五天上午课程】——之ngins 安装 启动脚本

case 多条件分支语句     用户可以在程序中预设N多条件  不同的条件对应不同的操作 根据条件触发操作   每次执行代码 只能触发一个操作
一般用在写主题框架

case 变量名 in 
v1)
      command1
;;
v2)
        command2
;;
.....
*)
       commandx
esac

============================================================

 【第五天下午课程】——之apache 虚拟主机

sed命令    行编辑器

希望通过脚本来修改配置文件     非交互式完成修改     使用行编辑  sed来完成


对文件的编辑   增删改查


命令的语法

sed 【options】 {command} [flags]【filename】

[可有可无] {必须有}


[filename]  数据源    数据源可以来自管道或文件
[options]   命令的补充
[flags]       对选项的补充
{command}  对文件干啥

================================
{command}  对数据干啥   增删改查

sed 'atoday is 2017-06-20' file
sed '3atoday is 2017-06-20' file
sed '2,4atoday is 2017-06-20' file

以上三种方式不适合生产环境
   开启匹配模式  sed '/2. chen/a\today is 2017' file

i   在指定的行前新开一行插入


删除
d


更改
c   更改一行
s   替换一个单词


查 p


==========================
options  命令选项

-n   抑制内存输出
-i   修改文件内容    不推荐i   建议i.xxx    i.bak     该操作不可逆    先备份一份在操作>源文件
-f file 将command内容写入到文件
-r 支持正则表达式


======================
flags 标志
N  是一个数字  代表要修改一行中的第N处
g  全部
p  打印
w file  把修改过的内容保存在file文件中

--------------------------------------------------------------------------------------------------
为www.vfast.com.cn 新建一个基于域名虚拟主机  要求DR sn access error

用户可以通过脚本对虚拟主机进行操作

……………………………………………………………………………………………………………………………………………
————————————————————————————————————————
【第六天上午课程】

正则表达式      三方产品    支持多种语言   PHP  PYTHON SHELL JAVA

so
   不是所有的LINUX命令都支持正则表达式    目前linux支持的：  grep  sed    awk


用特殊符号 写一个 公式  去匹配你想要的字符串


两套特殊字符

   1）特殊字符
   2）posix字符

=============================================
^  以什么开头   ^b   以b开头的字符串
$  以什么结尾   b$   以b结尾的字符串

    两个一起出现  代表精确匹配
    单个出现或不出现 代表模糊匹配

============================================
【第六天下午课程】
  .

  *

  ?

  +
==========================================
  ( )
  [ ]
  { }

  \
  |
==========================
awk  gawk
作用：从标准输出中截取对应的数据进行处理   不会对源文件进行修改

行编辑器


语法
    awk [options] '{program}' [filename]

awk作者认为awk就是一个单行脚本程序  所以 大括号必须有   又认为单行脚本程序其实就是单行字符串   所以 单引>号必须加
awk命令 把行(row)叫做记录,回车是记录的分割符
           列field 叫做字段  空[空格 table]是字段的分割符
          分割符有两种  一种是数据源的分割符  一种是输出到屏幕后的分割符

=================
awk 截取功能
   字段   记录   字符串

字段的截取
    $N 代表第几个字段    注意 $0 代表全文本内容  $1 第一个字段     $NF 代表最后一个字段

记录的截取 NR==N   开启匹配模式 匹配行
   匹配  精确匹配  ==   !=
         模糊匹配  ~    !~







***********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++
【21点游戏脚本】

#!/bin/bash
BOOT() { if [ $NUM2 -le 16 ]
         then
            let "TMP2=$((RANDOM %10))+1"
            let "NUM3=$NUM3+$TMP2"
            echo "机器人本次是$TMP2点"
            echo "机器人牌面是$NUM3点（不包含底牌）"
            let "NUM2=$NUM2+$TMP2"
      elif [ $NUM2 -gt 21 ]
        then
           echo -e "\033[32m 机器人是$NUM2点，超过21点，您赢了 \033[0m"
           exit
      else
         echo "机器人停止要牌"
      fi
      if [ $yao == n ] && [ $NUM2 -ge 16 ]  && [ $NUM2 -le 21 ]
         then
            break
      fi }

NUM3=0;
echo "是否开始21点游戏？[y or n ]"
read START
if [ $START == y ]
   then
      echo "游戏开始"
      let "NUM1=$((RANDOM %10))+1"
      let "NUM2=$((RANDOM %10))+1"
      echo "您的底牌是$NUM1"
      for i in `seq 1 21`
         do
         echo ""
#-----------------------ren----------------
         echo "是否继续要牌(y or n)"
         read yao
         if [ $yao == y ]
             then
               let "TMP1=$((RANDOM %10))+1"
               let "NUM1=$NUM1+$TMP1"
               echo "您本次是$TMP1点"
               echo "您现在有$NUM1点"
               if [ $NUM1 -gt 21 ]
                  then
                  echo -e "\033[31m 超过21点，您输了 \033[0m "
                  exit
             fi
         else
           echo "您现在有$NUM1点"
           break
      fi
#------------------jiqi---------------------------------------------
                 BOOT
   done

   for i in `seq 1 10 `
     do
         BOOT
  done
else
    echo "游戏退出"
fi
#----------------------bijiao----------------------------
     if [ $NUM1 -gt $NUM2 ] && [ $START == y ]
       then
          echo -n -e "机器人$NUM2点\t"
          echo  "您$NUM1点"
          echo -e "\033[32m 您赢了 \033[0m"
          exit
     elif [ $NUM1 -lt $NUM2 ] && [ $START == y ]
      then
          echo -n -e "机器人$NUM2点\t"
          echo  "您$NUM1点"
          echo -e "\033[31m 您输了 \033[0m"
          exit
     elif [ $NUM1 -eq $NUM2 ] && [ $START == y ]
       then
          echo -n -e "机器人$NUM2点\t"
          echo  "您$NUM1点"
          echo -e "\033[33m 平手 \033[0m"
          exit
fi
      
