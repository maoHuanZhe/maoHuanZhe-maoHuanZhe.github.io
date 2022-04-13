---
title: Nginx系列HTTP请求处理流程
date: 2022-03-25 16:37
abbrlink: b382ebad
permalink: /pages/d88f96/
categories: 
  - Nginx
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## HTTP 请求处理的 11 个阶段
-  POST_READ
- SERVER_REWRITE
- FIND_CONFIG
- REWRITE
- POST_REWRITE
- PREACCESS
- ACCESS
- POST_ACCESS
- PRECONTENT
- CONTENT
- LOG
## POST_READ
-    realip : [[ Nginx系列HTTP模块之realip模块.md | Nginx系列HTTP模块之realip模块 ]] 
## SERVER_REWRITE
-    rewrite:[[ Nginx系列HTTP模块之rewrite模块.md | Nginx系列HTTP模块之rewrite模块 ]]
## REWRITE
-    rewrite
## PREACCESS
-    limit_conn
- limit_req
## ACCESS
-    auth_basic
- access
- auth_request
## PRECONTENT
-    try_files
## CONTENT
-    index
- autoindex
- concat
## LOG
-    access_log
## 模块的执行顺序
nginx 模块的执行顺序可以参考 nginx 编译生成的 ngx_modules.c 文件中的 ngx_modules 数组顺序的倒序
