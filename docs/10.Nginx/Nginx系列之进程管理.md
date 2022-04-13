---
title: Nginx系列之进程管理
tags: Nginx
categories: Nginx
abbrlink: 1997b89e
date: 2022-03-23 11:02:28
permalink: /pages/2eb249/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## Nginx进程管理：信号		
### Master进程
-  监控worker进程：监控worker进程是否发送CHLD信号
-  管理worker进程
-  接收信号
    1.  TERM,INT
    2.  QUIT
    3.  HUP
    4.  USR1
    5.  USR2
    6.  WINCH
### Worker进程
-  接收信号
    1.  TERM,INT
    2.  QUIT
    3.  USR1
    4.  INCH
### nginx命令行与信号的对应关系
-    reload:HUP
-    reopen:USR1
-    stop:TERM
-    quit:QUIT
## reload重载配置文件的真相
1.向master进行发送HUP信号（reload命令）
2.master进程校验配置语法是否正确
3.master进程打开新的监听端口
4.master进程用新的配置启动新的worker子进程
5.master进程向老的worker子进程发送QUIT信号
6.老worker进程关闭监听句柄，处理完当前链接后结束进程
## 热升级的完整流程
1.将旧Nginx文件换成新Nginx文件（注意备份）
2.向master进程发送USR2信号
3.master进程修改pid文件名，加后缀.oldbin
4.master进程用新Nginx文件启动新master进程
5.向老master进程发送QUIT信号，关闭老master进程
6.回滚，向老Master进程发送HUP信号，向新master进程发送QUIT信号
## worker进程：优雅的关闭
1.设置定时器：worker_shutdown_timeout
2.关闭监听句柄
3.关闭空闲链接
4.在循环中等待全部链接关闭
5.退出进程
