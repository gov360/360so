#!/bin/env bash
#version:1.0.0
#author: xiaozhi
#date:2019/10/23
#desg:my one script
#-------------------------------
#copyright: xiaozhi 2019
#license: GPL

echo 'hello word'
echo my is `hostname`
#获取IP地址
ip a |egrep -o "\<(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>"
#ifconfig |egrep -o "(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
#ip a |egrep -o "\<(([0-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>"