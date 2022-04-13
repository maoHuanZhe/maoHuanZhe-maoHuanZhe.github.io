---
title: Nginx系列常用指令之location
date: 2022-03-25 16:30
abbrlink: 93848f1e
tags: 
  - Nginx
  - HTTP
  - 指令
categories: Nginx
permalink: /pages/1b2a4e/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
```nginx
Syntax:	location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }
Default:	—
Context:	server, location

Syntax:	merge_slashes on | off;
Default:	merge_slashes on;
Context:	http, server
# 合并连续的 / 反斜杠
```
## location匹配规则：仅匹配URI，忽略参数
-    合并连续的/符号（merge_slashes on)
-    前缀字符串：常规，=（精确匹配），^~(匹配上后则不再进行正则表达式匹配)
-    正则表达式：~(大小写敏感),~*(忽略大小写)
-    @（用于内部跳转的命名location）
## 示例
```nginx
location = / {
    [ configuration A ]
}

location / {
    [ configuration B ]
}

location /documents/ {
    [ configuration C ]
}

location ^~ /images/ {
    [ configuration D ]
}

location ~* \.(gif|jpg|jpeg)$ {
    [ configuration E ]
}
```
```shell
/ ===>     A
精确匹配
/index.html ===>     B
首先最长前缀匹配 B，后续的正则表达式没有找到匹配的，所以最后匹配到 B
/documents/document.html ===>    C
首先最长前缀匹配 C，后续的正则表达式没有找到匹配的，所以最后匹配到 C
/images/1.gif ===>    D
最长前缀匹配到 D，然后不在匹配后续的正则表达式，所以最后匹配 D
/documents/1.jpg ===>    E
首先最长前缀匹配 C，后续的正则表达式匹配了 E，所以最后匹配 E
```
如果位置由以斜杠字符结尾的前缀字符串定义，并且请求由proxy_pass、fastcgi_pass、uwsgi_pass、scgi_pass、memcached_pass或grpc_pass之一处理，则执行特殊处理。为了响应URI等于此字符串的请求，但没有尾随斜杠，带有代码301的永久重定向将返回到请求的URI，并附加斜杠。如果不需要，可以像这样定义URI和位置的完全匹配：
```nginx
location /user/ {
    proxy_pass http://user.example.com;
}

location = /user {
    proxy_pass http://login.example.com;
}
```
```nginx
upstream locationupstream {
    server 127.0.0.1:8096;
}
server {
        server_name location.fgrapp.com;
        error_log logs/location_error.log debug;
        default_type text/plain;
        merge_slashes off;
        location ~ /Test1/$ {
           return 200 'first regular expressions match!\n';
        }
        location ~* /Test1/(\w+)$ {
           return 200 'longest regular expressions match!\n';
        }
        location ^~ /Test1/ {
           return 200 'stop regular expressions match!\n';
        }                                                                            
        location /Test1/Test2 {
          return 200 'longest prefix string match!\n';
        }
        location /Test1 {
          return 200 'prefix string match!\n';
        }
        location = /Test1 {
          return 200 'exact match!\n';
        }
        
        location /role/ {
            return 200 '/role/: $uri\n';
        }
        location /user/ {
            proxy_pass http://locationupstream;
        }
}
```
```nginx
server {
    listen 8096;

    location / {
        return 200 'success: $uri\n';
    }
}
server {
    listen 8095;

    location / {
        return 200 'login: $uri\n';
    }
}
```
```shell
curl location.fgrapp.com/Test1
exact match!
# 这里是精确匹配到  = /Test1
curl location.fgrapp.com/Test1/
stop regular expressions match!
# 这里是匹配到 ^~ /Test1/ 后终止了后续的正则匹配
curl location.fgrapp.com/Test1/Test2
longest regular expressions match!
# 这里首先匹配了最长前缀/Test1/Test2，然后匹配上了正则表达式~* /Test1/(\w+)$，最后匹配了正则表达式
curl location.fgrapp.com/Test1/Test2/
longest prefix string match!
# 这里首先匹配了最长前缀/Test1/Test2 ，后续的正则表达式没有匹配上，最后匹配了最长前缀
curl location.fgrapp.com/test1/Test2
longest regular expressions match!
# 这里没有匹配的最长前缀，后续的正则表达式匹配了~* /Test1/(\w+)$，最后匹配了正则表达式
curl location.fgrapp.com/user/
success: /user/
curl location.fgrapp.com/user
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.20.2</center>
</body>
</html>
curl location.fgrapp.com/role/
/role/: /role/
curl location.fgrapp.com/role
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.20.2</center>
</body>
</html>
# 这里可以看到两个 location 块分别匹配/user/和/role/，/user/使用的是反向代理，/role/没有使用反向代理。/user 被重定向到了/user/，/role 没有被重定向到/role/。这就是 nginx 对反向代理的服务作出的特殊处理
# 添加配置
upstream locationlogin {
    server 127.0.0.1:8095;
}
location = /user {
     proxy_pass http://locationlogin;
}
curl location.fgrapp.com/user
login: /user
# 这里/user 就精确匹配到了 = /user，就不会重定向到/user/了。
```