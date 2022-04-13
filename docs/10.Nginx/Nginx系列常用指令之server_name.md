---
title: Nginx系列常用指令之server_name
date: 2022-03-25 14:42
abbrlink: f5d9a60c
permalink: /pages/c17936/
categories: 
  - Nginx
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 格式
```
Syntax:	server_name name ...;
Default:	
server_name "";
Context:	server
```
### 示例
```
server {
    listen       80;
    server_name  example.org  www.example.org;
    ...
}

server {
    listen       80;
    server_name  *.example.org;
    ...
}

server {
    listen       80;
    server_name  mail.*;
    ...
}

server {
    listen       80;
    server_name  ~^(?<user>.+)\.example\.net$;
    ...
}
```
server_name 的值可以分为以下几种:
- 域名
- 泛域名
- 正则表达式
- 其他
## 域名
可以写多个域名，第一个域名为主域名。
```
server {
    server_name example.com www.example.com;
}
```
## 泛域名
仅支持在最前或者最后添加`*`。
```
server {
    server_name example.com *.example.com www.example.*;
}
```
`www.*.example.org` 与 `w*.example.org` 是不行的。
## 正则表达式
通过在域名前加上`~`实现
```
server {
    server_name www.example.com ~^www\d+\.example\.com$;
}
```
正则表达式中的变量还可以在后续的过程中使用
```
server {
    server_name ~^(www\.)?(.+)$;

    location / {
        root /sites/$2;
    }
}
server {
    server_name ~^(www\.)?(?<domain>.+)$;

    location / {
        root /sites/$domain;
    }
}
```
## 其他
### `.`
`.fgrapp.com`可以匹配`fgrapp.com`和`*.fgrapp.com`
### `_`
这个名字没有什么特别之处，它只是无数从未与任何真实名称相交的无效域名之一。其他无效名称，如“--”和“！@#”可以同样使用。
### `""`
匹配没有传递`Host`的请求
## server 匹配顺序
-  精确匹配
- `*`在前的泛域名
- `*`在后的泛域名
- 按照文件中的顺序匹配正则表达式域名
- default server
### default server
可以使用 server 块中的 `listen` 指令添加 `default_server` 属性配置当前 server 块为 `default server`，
如果没有配置的话则第一个 server 块为`default server`话。
```
server {
    listen       80  default_server;
    server_name  _;
    return       444;
}
server {
    listen       80;
    listen       8080  default_server;
    server_name  example.net;
    ...
}

server {
    listen       80  default_server;
    listen       8080;
    server_name  example.org;
    ...
}
```
详细内容查看:[server names](https://nginx.org/en/docs/http/server_names.html)