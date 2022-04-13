---
title: Nginx系列HTTP模块之limit_conn模块
date: 2022-03-29 09:59
tags: 
  - Nginx
  - HTTP
  - 模块
categories: Nginx
abbrlink: 3d7708b5
permalink: /pages/98a46c/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## ngx_http_limit_conn_module模块
ngx_http_limit_conn_module模块用于限制每个 key 的连接数量，特别是来自单个IP地址的连接数量。
并非所有连接都计算在内。只有当服务器正在处理请求并且整个请求头已经读取时，才会计算连接。
-    默认编译进nginx，通过`--without-http_limit_conn_module`禁用
-    生效范围：全部worker进程（基于共享内存），进入preaccess阶段前不生效，限制的有效性取决于key的设计（依赖postread阶段的realip模块取到的真实ip）
### 指令
- limit_conn
- limit_conn_dry_run
- limit_conn_log_level
- limit_conn_status
- limit_conn_zone
### 变量
- $limit_conn_status
### 示例
```nginx
http {
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    ...
    server {
        ...
        location /download/ {
            limit_conn addr 1;
        }
}
# 也可以定义多个限制
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;

server {
    ...
    limit_conn perip 10;
    limit_conn perserver 100;
}
```

## 指令
```
定义共享内存（包括大小），以及key关键字
Syntax:	limit_conn_zone key zone=name:size;
Default:	—
Context:	http
限制并发连接数
Syntax:	limit_conn zone number;
Default:	—
Context:	http, server, location
限制发生时的日志级别
Syntax:	limit_conn_log_level info | notice | warn | error;
Default:	limit_conn_log_level error;
Context:	http, server, location
This directive appeared in version 0.8.18.
限制发生时向客户端返回的错误码
Syntax:	limit_conn_status code;
Default:	limit_conn_status 503;
Context:	http, server, location
This directive appeared in version 1.3.15.
启用干运行模式。在这种模式下，连接数量不受限制，但是，在共享内存区域，过多连接的数量会像往常一样核算。
简单来说就是不再限制连接数量，但是会记录日志。
Syntax:	limit_conn_dry_run on | off;
Default:	limit_conn_dry_run off;
Context:	http, server, location
This directive appeared in version 1.17.6.
```
### 示例
```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;
server {
        server_name limit.fgrapp.com;
        root html/;
        error_log logs/limit_error.log info;
                    
        location / {
                limit_conn_status 500;
                limit_conn_log_level warn;
                limit_rate 50;
                limit_conn addr 1;
        }
}
```
```shell
curl limit.fgrapp.com -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Tue, 29 Mar 2022 02:48:29 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
Connection: keep-alive
ETag: "621ede70-264"
Accept-Ranges: bytes

curl limit.fgrapp.com -I
HTTP/1.1 500 Internal Server Error
Server: nginx/1.20.2
Date: Tue, 29 Mar 2022 02:48:29 GMT
Content-Type: text/html
Content-Length: 177
Connection: close
# 这里同一 ip 同时请求的话 第一个请求的会返回 200，第二个请求的会返回 500 ，下面是记录的日志
2022/03/29 10:48:29 [warn] 1344085#0: *407 limiting connections by zone "addr", client: 82.157.68.63, server: limit.fgrapp.com, request: "HEAD / HTTP/1.1", host: "limit.fgrapp.com"

                limit_conn_dry_run on;
# 配置 limit_conn_dry_run 为 on 后，对并发请求不再限制，但是会记录日志
curl limit.fgrapp.com -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Tue, 29 Mar 2022 02:49:10 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
Connection: keep-alive
ETag: "621ede70-264"
Accept-Ranges: bytes

curl limit.fgrapp.com -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Tue, 29 Mar 2022 02:49:10 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
Connection: keep-alive
ETag: "621ede70-264"
Accept-Ranges: bytes
# 可以看到两个请求都返回了 200，下面是记录的日志
2022/03/29 10:49:14 [warn] 1344245#0: *409 limiting connections, dry run, by zone "addr", client: 82.157.68.63, server: limit.fgrapp.com, request: "HEAD / HTTP/1.1", host: "limit.fgrapp.com"
```
## 变量
`$limit_conn_status`:保持限制连接次数的结果
- PASSED:通过
- REJECTED:拒绝
- REJECTED_DRY_RUN:拒绝但允许通过
```shell
                echo 'limit_conn_status: $limit_conn_status';
# 添加打印 limit_conn_status 变量的代码，然后同时请求两次
curl limit.fgrapp.com
limit_conn_status: PASSED
curl limit.fgrapp.com
limit_conn_status: REJECTED_DRY_RUN
```
