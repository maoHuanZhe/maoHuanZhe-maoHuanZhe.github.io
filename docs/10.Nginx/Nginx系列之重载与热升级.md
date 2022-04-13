---
title: Nginx系列之重载与热升级
tags: Nginx
categories: Nginx
abbrlink: 1997b89e
date: 2022-03-23 11:02:28
permalink: /pages/ba7dc9/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## nginx热部署
```shell
# 复制nginx二进制文件
cp nginx nginx.old
ps -ef | grep nginx
# 给nginx master进程发送USR2信号
kill -USR2 728041
# 这时候会新起一个master进程 向老的master进行发送WINCH信号
kill -WINCH 728041
# 如果更新后服务正常，则将老的 master 进程彻底退出
kill -QUIR 728041
# 如果更新后服务出错，则回滚，将老的 master 进程重新拉起，关闭新的 master 进程
kill -HUP 728041
kill -QUIT 839152
```
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
## 升级脚本示例
```shell
#!/bin/bash
#nginx安装地址
path='/usr/local/learn/nginx/'
#备份nginx二进制文件
cp $path/sbin/nginx $path/sbin/nginx.bak.$(date "+%Y%m%d%H%M%S")
cd /opt/nginx-1.20.2
/opt/nginx-1.20.2/configure --prefix=$path --with-http_slice_module --add-module=/opt/nginx-1.20.2/ngx_cache_purge-2.3 --with-http_realip_module --with-http_auth_request_module --add-module=/opt/nginx-1.20.2/nginx-http-concat --with-http_sub_module --with-http_addition_module --with-http_secure_link_module --with-http_geoip_module --with-http_ssl_module > /dev/null 2>&1
if [ $? -eq 0 ];then
    echo    "Nginx预编译完成，开始安装"
else
    echo    "Nginx预编译失败，请检查相关依赖包是否安装"
exit 4
fi
make &>/dev/null
make install &>/dev/null
if [ $? -eq 0 ];then
    echo    "Nginx安装成功"
else
    echo    "Nginx安装失败"
exit 5
fi
cd -
```
