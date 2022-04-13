---
title: Nginx系列之编译安装与升级
date: 2022-03-28 09:15
abbrlink: 22832af7
permalink: /pages/61a30a/
categories: 
  - Nginx
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 编译Nginx
```shell
# 下载
wget https://nginx.org/download/nginx-1.20.2.tar.gz
# 解压
tar -xzf nginx-1.20.2.tar.gz
cd nginx-1.20.2
# vim支持nginx语法
cp -r contrib/vim/* ~/.vim/
# 编译
./configure --prefix=/usr/local/learn/nginx
make
make install
```
### 编译时参数配置
- `--prefix`:指定编译安装的位置
- `--with-模块名称`:添加指定模块
- `--without-模块名称`:禁用指定模块
- `--add-module=PATH`:添加第三方模块
## 操作命令
-  nginx:启动
- nginx -s reload:重载配置文件
- nginx -s reopen:重新打开日志文件记录日志
- nginx -s stop:停止
- nginx -t:校验配置文件
- nginx -v:nginx 版本信息
- nginx -V: nginx 版本与编译信息
## 升级
```shell
# 升级前将原先的 nginx 二进制文件备份，以防升级失败用于回滚
cp nginx nginx.old
# 获取 nginx master 进程号
ps -ef | grep nginx
# 给nginx master进程发送USR2信号
kill -USR2 728041
# 这时候会新起一个master进程 这时候应该有两个 master 进程 还是只有一个 master 进程的话 一般情况下是配置文件出错了，可以运行 nginx -t 校验一下配置文件
ps -ef | grep nginx
# 向老的master进行发送WINCH信号
kill -WINCH 728041
# 如果更新后服务正常，则将老的 master 进程彻底退出
kill -QUIT 728041
# 如果更新后服务出错，则回滚，将老的 master 进程重新拉起，关闭新的 master 进程
kill -HUP 728041
kill -QUIT 839152
```
## 升级自用脚本
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
