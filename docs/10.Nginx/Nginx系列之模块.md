---
title: Nginx系列之模块
date: 2022-03-23 18:42
tags: Nginx
categories: Nginx
abbrlink: 6a9c532e
permalink: /pages/d9b179/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## nginx 模块
- 是否编译进 nginx
- 提供了哪些配置项
- 提供哪些变量
- 模块何时被使用
## 如何确定 nginx 编译进了哪些模块
在 nginx 编译完成后会生成 objs 目录
objs 目录下有 ngx_modules.c 文件
ngx_modules.c 文件中有一个 ngx_modules[]数组，里面包含了所有编译进 nginx 的模块
### 模块提供的配置项与变量
可以在`https://nginx.org/en/docs/`页面中找到对应模块，进入对应模块的详情页，查看模块提供的指令与变量
### 模块的执行顺序
可以参考`ngx_modules`数组中的顺序
## 官方模块
可以通过 `./configure --help` 查看
可以通过`--with`与`--without`启用与禁用模块
###  动态模块
执行 `./configure --help` 命令查看可以看到有些模块后面跟着`=dynamic`，例如`--with-http_image_filter_module=dynamic`，这种就说明该模块可以被编译成动态模块
#### 示例
HTTP image filter module requires the GD library 
```shell
yum install gd gd-devel
```
编译安装 nginx 后会发现 nginx 安装目录多了 modules 文件夹
修改配置文件引入动态模块
```shell
vim nginx.conf
# 添加在配置文件的头部
load_module modules/ngx_http_image_filter_module.so;
vim conf.d/dynamic.conf
    server {
        server_name dynamic.fgrapp.com;

        location / {
            root docs/;
            image_filter resize 24 24;
        }
    }
```
#### 测试
访问地址`http://dynamic.fgrapp.com/apple-touch-icon.png`,
这里我在 nginx 安装目录中存在 docs 目录且目录中包含 apple-touch-icon.png 文件，
通过开关`image_filter`配置可以看到网页中显示的图片大小是不同的
#### 主要指令
指令来源:Core functionality
Syntax:	load_module file;
Default:	—
Context:	main
This directive appeared in version 1.9.11.
用来加载动态模块
指令来源:ngx_http_image_filter_module
Syntax:	image_filter off;
image_filter test;
image_filter size;
image_filter rotate 90 | 180 | 270;
image_filter resize width height;
image_filter crop width height;
Default:	
image_filter off;
Context:	location
## 第三方模块
这里使用 `ngx_cache_purge` 模块示例第三方模块的编译与使用，
该模块的作用是清除 nginx 的缓存
首先到`https://github.com/FRiCKLE/ngx_cache_purge`上下载模块源码
当前模块的最新版本为 2.3，下载指令如下
```shell
wget https://github.com/FRiCKLE/ngx_cache_purge/archive/refs/tags/2.3.tar.gz
```
将下载下来的模块源码解压至 nginx 的源码目录中
```
tar -zxvf 2.3.tar.gz
# 这里/opt/nginx-1.20.2 是我的 nginx 源码目录
mv ngx_cache_purge-2.3 /opt/nginx-1.20.2
```
在 nginx 的编译指令中加入 `--add-module=/opt/nginx-1.20.2/ngx_cache_purge-2.3`，这里我写的的是模块源码的绝对地址
nginx 的热升级可参考 https://javadacainiao.gitee.io/posts/1997b89e.html
### 主要指令
接收到指定HTTP请求后立刻清除缓存
syntax: proxy_cache_purge on|off|<method> [from all|<ip> [.. <ip>]]
default: none
context: http, server, location
允许从代理的缓存中清除选定的页面。
syntax: proxy_cache_purge zone_name key
default: none
context: location
设置用于从代理缓存中清除指定空间的 key。
### 示例
#### 上游服务配置文件
```
vim upserver-purge.conf
server {
    listen 8098;

    root html;

    location / {
    }
}
```
#### 代理服务配置文件
```
vim purge.conf
proxy_cache_path /data/nginx/tmpcache levels=2:2 keys_zone=two:10m loader_threshold=300 loader_files=200
                    max_size=200m inactive=1m;

server {
    server_name purge.fgrapp.com;
    
    location ~ /purge(/.*) {
        # 指定要清楚的缓存空间，key 值要与 proxy_cache_key 相同
        proxy_cache_purge two $scheme$1;
    }

    location / {
        proxy_cache two;
        proxy_cache_valid 200 1m;
        add_header X-Cache-Status $upstream_cache_status;

        proxy_cache_key $scheme$uri;
        proxy_pass http://localhost:8098;
    }
}
```
#### 测试
```
curl purge.fgrapp.com/index.html -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Mon, 21 Mar 2022 07:02:48 GMT
Content-Type: text/html
Content-Length: 612
Connection: keep-alive
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
ETag: "621ede70-264"
X-Cache-Status: MISS
Accept-Ranges: bytes
第一次访问没有缓存，X-Cache-Status:为MISS
curl purge.fgrapp.com/index.html -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Mon, 21 Mar 2022 07:02:55 GMT
Content-Type: text/html
Content-Length: 612
Connection: keep-alive
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
ETag: "621ede70-264"
X-Cache-Status: HIT
Accept-Ranges: bytes
第二次访问命中缓存，X-Cache-Status:为 HIT

curl purge.fgrapp.com/purge/index.html -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Mon, 21 Mar 2022 07:03:19 GMT
Content-Type: text/html
Content-Length: 275
Connection: keep-alive
这时候调用接口清除缓存
curl purge.fgrapp.com/index.html -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Mon, 21 Mar 2022 07:03:38 GMT
Content-Type: text/html
Content-Length: 612
Connection: keep-alive
Last-Modified: Wed, 02 Mar 2022 03:03:12 GMT
ETag: "621ede70-264"
X-Cache-Status: MISS
Accept-Ranges: bytes
再次访问，X-Cache-Status:为 MISS
```