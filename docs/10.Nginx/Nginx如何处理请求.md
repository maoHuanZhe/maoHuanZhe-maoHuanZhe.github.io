---
title: Nginx如何处理请求
date: 2022-03-25 11:01
abbrlink: 49e83109
permalink: /pages/15abc6/
categories: 
  - Nginx
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
Nginx首先决定哪个服务器应该处理请求。让我们从一个简单的配置开始，其中所有三台虚拟服务器都在端口上收听*:80：
```
server {
    listen      80;
    server_name example.org www.example.org;
    ...
}
server {
    listen      80;
    server_name example.net www.example.net;
    ...
}
server {
    listen      80;
    server_name example.com www.example.com;
    ...
}
```
在此配置中，nginx仅校验请求的 Header 中的字段"Host"，以确定请求应路由到哪个服务器。如果其值与任何 server_name 都不匹配，或者请求根本不包含"Host"字段，则nginx将把请求路由到此端口的默认服务器。在上述配置中，默认服务器是第一个——这是nginx的标准默认行为。它还可以显式设置哪个服务器应该是默认的，并在监听指令中使用default_server参数：
```
server {
    listen      80 default_server;
    server_name example.net www.example.net;
    ...
}
```
**默认服务器是监听端口的属性，而不是服务器名称的属性。**
## 如何防止处理具有未定义服务器名称的请求
如果不允许没有“主机”头字段的请求，则可以如下配置：
```
server {
    listen      80;
    server_name "";
    return      444;
}
```
服务器名称设置为空字符串，该字符串将匹配没有"Host"头字段的请求，并返回一个特殊的nginx的444 状态码来关闭连接。
## 基于名称和基于IP的混合虚拟服务器
让我们看看一个更复杂的配置，一些虚拟服务器在不同的地址上监听：
```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}
server {
    listen      192.168.1.1:80;
    server_name example.net www.example.net;
    ...
}
server {
    listen      192.168.1.2:80;
    server_name example.com www.example.com;
    ...
}
```
在此配置中，nginx首先根据 server 块的 listen 指令校验请求的IP地址和端口。然后，它根据与IP地址和端口匹配的 server 块的server_name 指令校验请求头中的"Host"字段。如果没有找到对应的 server_name，默认服务器将处理请求。例如，在192.168.1.1:80端口上收到的www.example.com请求将由192.168.1.1:80端口的默认服务器处理，即由第一台服务器处理，因为没有为该端口定义www.example.com。
如前所述，默认服务器是监听端口的属性，可以为不同的端口定义不同的默认服务器：
```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}
server {
    listen      192.168.1.1:80 default_server;
    server_name example.net www.example.net;
    ...
}
server {
    listen      192.168.1.2:80 default_server;
    server_name example.com www.example.com;
    ...
}
```
## 一个简单的 PHP 站点配置
现在让我们看看nginx如何选择一个位置来处理典型、简单的PHP网站的请求：
```
server {
    listen      80;
    server_name example.org www.example.org;
    root        /data/www;

    location / {
        index   index.html index.php;
    }

    location ~* \.(gif|jpg|png)$ {
        expires 30d;
    }

    location ~ \.php$ {
        fastcgi_pass  localhost:9000;
        fastcgi_param SCRIPT_FILENAME
                      $document_root$fastcgi_script_name;
        include       fastcgi_params;
    }
}
```
Nginx首先遍历匹配全部的前缀字符串 location。在上面的配置中，唯一的前缀 location是“/”，由于它与任何请求匹配，它将作为最后手段使用。然后，nginx按照配置文件中列出的顺序检查正则表达式的 location。找到匹配的正则表达式后停止搜索，nginx将使用此位置。如果没有与请求匹配的正则表达式，则nginx使用前面找到的最长的前缀 location。
**所有类型的 location只校验请求的URI部分，不校验参数部分**。这样做是因为查询字符串中的参数可以通过几种方式给出，例如：
```
/index.php?user=john&page=1
/index.php?page=1&user=john
```
此外，任何人都可以在参数中加入任何内容：
```
/index.php?page=1&something+else&user=john
```
现在，让我们看看如何在上述配置中处理请求：
- 请求“/logo.gif”首先与前缀 location“/”匹配，然后由正则表达式“\.(gif|jpg|png)$”匹配，因此，它由后一个 location处理。使用指令“root /data/www”，将请求映射到文件/data/www/logo.gif，并将文件发送到客户端。
- 请求“/index.php”也首先与前缀 location “/”匹配，然后由正则表达式“\.(php)$”匹配。因此，它由后一个 location处理，请求被传递给在localhost:9000上监听的FastCGI服务器。fastcgi_param指令将FastCGI参数SCRIPT_FILENAME设置为“/data/www/index.php”，FastCGI服务器执行该文件。变量$document_root等于 root 指令的值，变量$fastcgi_script_name等于请求URI，即“/index.php”。
- 请求“/about.html”仅与前缀 location “/”匹配，因此，它在此 location 处理。使用指令“root /data/www”，将请求映射到文件/data/www/about.html，并将文件发送到客户端。
- 处理请求“/”更加复杂。它仅与前缀 location “/”匹配，因此，它由此 location 处理。然后，index 指令根据其参数和“root /data/www”指令校验 index 文件的存在。如果文件/data/www/index.html不存在，并且文件/data/www/index.php存在，则指令会内部重定向到“/index.php”，nginx会再次搜索 location，就像请求是由客户端发送的一样。正如我们之前所看到的，重定向的请求最终将由FastCGI服务器处理。

原文地址:https://nginx.org/en/docs/http/request_processing.html
