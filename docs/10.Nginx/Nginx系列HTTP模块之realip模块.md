---
title: Nginx系列HTTP模块之realip模块
date: 2022-03-25 17:21
abbrlink: 1620efe9
tags: 
  - Nginx
  - HTTP
  - 模块
categories: Nginx
permalink: /pages/e7c845/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
# realip模块
Ngx_http_realip_module模块用于将客户端地址和可选端口更改为在指定标头字段中发送的地址和可选端口。
- 默认不会编译进Nginx：通过 `--with-http_realip_module` 启用功能
- 指令：
    - `set_realip_from`
    - `real_ip_header`
    - `real_ip_recursive`
- 变量：
    - `realip_remote_addr`
    - `realip_remote_port`
## 配置示例
```nginx
set_real_ip_from  192.168.1.0/24;
set_real_ip_from  192.168.2.1;
set_real_ip_from  2001:0db8::/32;
real_ip_header    X-Forwarded-For;
real_ip_recursive on;
```
## 指令详解
```conf
Syntax:	set_real_ip_from address | CIDR | unix:;
Default:	—
Context:	http, server, location
定义信任的 IP 地址，即只有这里指定的 IP 的地址才可以从请求头字段中获取 IP 与端口。
Syntax:	real_ip_header field | X-Real-IP | X-Forwarded-For | proxy_protocol;
Default:	real_ip_header X-Real-IP;
Context:	http, server, location
指定从哪个请求头字段中获取 IP 地址
Syntax:	real_ip_recursive on | off;
Default:	real_ip_recursive off;
Context:	http, server, location
This directive appeared in versions 1.3.0 and 1.2.1.
如果递归搜索被禁用，与受信任地址之一匹配的原始客户端地址将被real_ip_header指令定义的请求头字段中发送的最后一个地址取代。如果启用递归搜索，与其中一个受信任地址匹配的原始客户端地址将被请求头字段中发送的最后一个非受信任地址替换。
```
## 示例
### 配置文件
```nginx
server {
    server_name realip.fgrapp.com;
    set_real_ip_from 82.157.68.63;
    real_ip_header X-Forwarded-For;
    real_ip_recursive off;
    location / {
        return 200 "Client real ip: $remote_addr\n
remote_port: $remote_port\n
realip_remote_addr: $realip_remote_addr\n
realip_remote_port: $realip_remote_port\n";
    }
}
```
### 测试请求
```shell
curl -H X-forwarded-For: 1.1.1.1:9090,82.157.68.63:8080 realip.fgrapp.com
Client real ip: 82.157.68.63

remote_port: 8080

realip_remote_addr: 82.157.68.63

realip_remote_port: 33534
# 修改配置文件将real_ip_recursive设为on后
curl -H X-forwarded-For: 1.1.1.1:9090,82.157.68.63:8080 realip.fgrapp.com
Client real ip: 1.1.1.1

remote_port: 9090

realip_remote_addr: 82.157.68.63

realip_remote_port: 33574
# 修改配置文件将 set_real_ip_from 改为82.157.68.64 后
curl -H X-forwarded-For: 1.1.1.1:9090,82.157.68.66:8080 realip.fgrapp.com
Client real ip: 82.157.68.63

remote_port: 33618

realip_remote_addr: 82.157.68.63

realip_remote_port: 33618
# 这时候已经不是受信任的 IP 地址了，所以$remote_addr 变量不会再从请求的头字段中获取了。
```
请求时`X-forwarded-For: 1.1.1.1:9090,82.157.68.66:8080 `中的端口号可以不写，这样就不会修改` $remote_port`变量的值。