2、安装X Window:

yum groupinstall "X Window System"

3、安装gnome：

yum groupinstall "Desktop"

（6.2中Desktop就是gnome）
然后就等吧，当然在这里之前，可以先安装wget，然后修改下centos
的网络源为163的再安装gnome，修改源的方法自己google下吧，这里不獒述.

4、然后我们安装中文语言

yum groupinstall "Chinese Support"

5、最关键的一步了，启动gnome

startx
然后按下Ctrl+Alt+F2, OK，进入了桌面.

6、要下次自动启动gnome：


centos7不再使用这个文件，但是切换命令被保留。
修改/etc/inittab文件中的
id:3:initdefault
将3改为5
id:5:initdefault
重新启动系统.




