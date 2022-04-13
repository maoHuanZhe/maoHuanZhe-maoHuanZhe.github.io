---
title: Nginx系列之初识
tags: Nginx
categories: Nginx
abbrlink: 182cae4d
date: 2022-03-22 21:39:14
permalink: /pages/9258c1/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## Nginx的三个主要应用场景
-  静态资源服务
    1.  通过本地文件系统提供服务
-  反向代理服务
    1.  Nginx的强大性能
    2.  缓存
    3.  负载均衡
-  API服务
    1.    OpenResty
## Nginx为什么会出现
-  互联网的数据量快速增长
    1.  互联网的快速普及
    2.  全球化
    3.  物联网
-  摩尔定律：性能提升
-  低效的Apache
    1.  一个链接对应一个线程
## Nginx的优点
-    高并发，高性能
-    可扩展性好
-    高可靠性
-    热部署
-    BSD许可证
## Nginx的组成
-    Nginx二进制可执行文件：由各个模块源码编译出的一个文件
-    Nginx.conf配置文件：控制Nginx的行为
-    access.log访问日志：记录每一条http请求信息
-    error.log错误日志：定位问题
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
# Nginx配置语法
-    配置文件由指令与指令块构成
-    每条指令以;结尾，指令与参数间以空格符号分隔
-    指令块以{}将多条指令组织在一起
-    include语句允许组合多个配置文件以提升可维护性
-    使用#添加注释，提高可读性
-    使用$使用变量
-    部分指令的参数支持正则表达式
## http配置的指令块
- http
- server
- upstream
- location
## Nginx命令行
- 格式：nginx -s reload
- 帮助：nginx -?,-h
- 使用制定的配置文件：-c
- 指定配置指令：-g
- 指定运行目录：-p
- 发送信号：-s（stop、quit、reload、reopen）
- 测试配置文件是否有语法错误：-t,-T
- 打印nginx的版本信息、编译信息等：-v,-V
### 命令行演示
```shell
# 重新载入配置文件
nginx -s reload
# 重新打开日志记录文件
nginx -s reopen
```
### 用Nginx搭建一个可用的静态资源Web服务器
```nginx
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    # 定义日志格式
    log_format  main  '[$gzip_ratio]- $remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    sendfile        on;
    keepalive_timeout  65;
    # 开启 gzip 压缩
    gzip  on;
    # 开启压缩的最小响应长度
    gzip_min_length 1;
    # 压缩级别 范围1～9 数值越大压缩越厉害
    gzip_comp_level 2;
    # 压缩文件类型 可以使用*代表所有文件
    gzip_types text/plain applicaion/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    server {
        listen 8090;
        server_name nginx.fgrapp.com;
        # 定义日志记录位置 以及 指定日志格式
        access_log logs/bootstrap.access.log main;
        location / {
            alias html/;
            # 开启autoindex
            autoindex on;
            # 限制访问速度 1k 表示每秒传输1k字节到浏览器中
            set $limit_rate 1k;
        }
    }
}
```
### 用Nginx搭建一个具备缓存功能的反向代理服务
在 conf 目录中创建文件夹 conf.d
nginx.conf 添加导入模块配置`include       conf.d/*.conf;`
```shell
cd conf.d
vim downstream.conf
```
配置文件如下:
```nginx
# 配置缓存存放路径以及名称等信息
proxy_cache_path /temp/nginxcache levels=1:2 keys_zone=my_cache:10m max_size=10g inactive=60m use_temp_path=off;
upstream local {
        server 127.0.0.1:8090;
}
server {
        listen 80;
        server_name downstream.fgrapp.com;
        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://local;
                # 缓存配置
                proxy_cache my_cache;
                proxy_cache_key $host$uri$is_args$args;
                proxy_cache_valid 200 304 302 1d;
        }
}
```
## gitee 地址
https://gitee.com/javaDaCaiNiao/linux-init
