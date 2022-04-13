---
title: Nginx系列之配置
date: 2022-03-24 16:11
abbrlink: 817a620c
permalink: /pages/7c7b7c/
categories: 
  - Nginx
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 指令
指令的 Context 即指令可以出现的配置块
###分类
- 值指令:存储配置项的的值
- 动作类指令:指定行为
**值指令可以合并，动作类指令不可以合并**
### 存储值的指令继承规则:向上覆盖
子配置不存在时，直接使用父配置块
子配置存在时，直接覆盖父配置块
### listen 指令
```
Syntax:	listen address[:port] [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
listen unix:path [default_server] [ssl] [http2 | spdy] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
Default:	
listen *:80 | *:8000;
Context:	server
```
示例
```
listen 127.0.0.1:8000;
listen 127.0.0.1;
listen 8000;
listen *:8000;
listen localhost:8000;
listen [::]:8000;
listen [::1];
listen unix:/var/run/nginx.sock;
```
#### 主域名
Syntax:	server_name_in_redirect on | off;
Default:	
server_name_in_redirect off;
Context:	http, server, location
```
server {
    server_name primary.fgrapp.com second.fgrapp.com;
    server_name_in_redirect off;

    return 302 /redirect;
}
```
```
配置开启时，使用 second 域名访问重定向后的域名是主域名
server_name_in_redirect on;
curl second.fgrapp.com -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.20.2
Date: Fri, 25 Mar 2022 02:05:48 GMT
Content-Type: text/html
Content-Length: 145
Location: http://primary.fgrapp.com/redirect
Connection: keep-alive
配置关闭后，重定向后的域名就是访问的域名
server_name_in_redirect off;
curl second.fgrapp.com -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.20.2
Date: Fri, 25 Mar 2022 02:06:53 GMT
Content-Type: text/html
Content-Length: 145
Location: http://second.fgrapp.com/redirect
Connection: keep-alive
```

