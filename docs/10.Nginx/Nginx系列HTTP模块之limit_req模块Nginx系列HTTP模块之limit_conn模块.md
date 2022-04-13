---
title: Nginx系列HTTP模块之limit_req模块Nginx系列HTTP模块之limit_conn模块
date: 2022-03-29 11:24
tags: 
  - Nginx
  - HTTP
  - 模块
categories: Nginx
abbrlink: 548b3040
permalink: /pages/7c2163/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 问题：如何限制每个客户端的每秒处理请求数？
## ngx_http_limit_req_module模块
-  生效阶段：preaccess阶段
- 默认编译进nginx，通过`--without-http_limit_req_module`禁用功能
-  生效算法：leaky bucket算法
- 生效范围：全部worker进程（基于共享内存），进入preaccess阶段前不生效
## 示例
```nginx
http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
    ...
    server {
        ...
        location /search/ {
            limit_req zone=one burst=5;
        }
}
# 可以添加多个限制
limit_req_zone $binary_remote_addr zone=perip:10m rate=1r/s;
limit_req_zone $server_name zone=perserver:10m rate=10r/s;

server {
    ...
    limit_req zone=perip burst=5 nodelay;
    limit_req zone=perserver burst=10;
}
```
## 指令
```
定义共享内存（包括大小）以及key关键字和限制速率
Syntax:	limit_req_zone key zone=name:size rate=rate [sync];
Default:	—
Context:	http
rate单位为r/s或者r/m

限制并发连接数
Syntax:	limit_req zone=name [burst=number] [nodelay | delay=number];
Default:	—
Context:	http, server, location
burst默认为0，nodelay，对burst中请求不再采用延时处理的做法，而是立即处理

限制发生时的日志级别
Syntax:	limit_req_log_level info | notice | warn | error;
Default:	limit_req_log_level error;
Context:	http, server, location
This directive appeared in version 0.8.18.

限制发生时向客户端返回的错误码
Syntax:	limit_req_status code;
Default:	limit_req_status 503;
Context:	http, server, location
This directive appeared in version 1.3.15.
启用干运行模式。在这种模式下，请求处理率不受限制，但是，在共享内存区域，过多请求的数量会像往常一样核算。
Syntax:	limit_req_dry_run on | off;
Default:	limit_req_dry_run off;
Context:	http, server, location
This directive appeared in version 1.17.1.
```
### 问题
-    limit_req与limit_conn配置同时生效时，哪个生效？
limit_req
-    nodelay添加与否，有什么不同？
nodelay，对burst中请求不再采用延时处理的做法，而是立即处理

### 示例
```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;
limit_req_zone $binary_remote_addr zone=one:10m rate=2r/m;
server {
    server_name limit.fgrapp.com;
    root html/;
    error_log logs/limit_error.log info;
    
    location / {
        limit_conn_status 500;
        limit_conn_log_level warn;
        limit_rate 50;
        limit_conn addr 1;
        #limit_req zone=one burst=3 nodelay;
        limit_req zone=one;
     }
}
```