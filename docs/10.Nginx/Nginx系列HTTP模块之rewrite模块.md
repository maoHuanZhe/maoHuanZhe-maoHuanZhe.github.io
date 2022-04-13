---
title: Nginx系列HTTP模块之rewrite模块
date: 2022-03-28 11:24
tags: 
  - Nginx
  - HTTP
  - 模块
categories: Nginx
abbrlink: ab00c57a
permalink: /pages/74ccdb/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
`ngx_http_rewrite_module`模块用于使用PCRE正则表达式更改请求URI，返回重定向，并有条件地选择配置。
## 指令
- `break`
- `if`
- `return`
- `rewrite`
- `set`
- `rewrite_log`
## break 指令
停止处理当前ngx_http_rewrite_module指令集。
如果访问到 break 分支的话会返回 404 状态。
```nginx
if ($slow) {
    limit_rate 10k;
    break;
}
```
## if 指令
```nginx
Syntax:	if (condition) { ... }
Default:	—
Context:	server, location
条件condition为真，则执行大括号内的指令
```
遵循值指令的继承规则
-    检查变量为空或者值是否为0，直接使用
-    将变量与字符串做匹配，使用=或者!=
-    将变量与正则表达式做匹配：大小写敏感（~,!~）,大小写不敏感（~*,!~*）
-    检查文件是否存在，使用-f或者!-f
-    检查目录是否存在，使用-d或者!-d
-    检查文件、目录、软链接是否存在，使用-e或者!-e
-    检查是否为可执行文件，使用-x或者!-x
#### 示例
```nginx
if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /msie/$1 break;
}
if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
    set $id $1;
}

if ($request_method = POST) {
    return 405;
}

if ($slow) {
    limit_rate 10k;
}

if ($invalid_referer) {
    return 403;
}
```
## set 指令
```
Syntax:	set $variable value;
Default:	—
Context:	server, location, if
```
为指定的变量设置一个值。该值可以包含文本、变量及其组合。
**如果是自定义的变量，变量的作用域应该是当前请求，下次请求的话变量值就不存在了**
### 示例
```nginx
server {
    server_name if.fgrapp.com;

    location / {
        return 200 'name: $my_name\n';
    }
    location ~ /set/(.*)$ {
        set $my_name $1;
        if ( $my_name = 'fgr') {
            break;
        }
        if ($my_name = 'fgrapp') {
            return 200;
        }
        rewrite /set(.*) /;
    }
}
```
```shell
curl if.fgrapp.com/set/fgr -I
HTTP/1.1 404 Not Found
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 07:19:52 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive
# 这里走到 break 分支，请求在这里直接返回了 所以是 404
curl if.fgrapp.com/set/fgrapp -I
HTTP/1.1 200 OK
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 07:20:07 GMT
Content-Type: application/octet-stream
Content-Length: 0
Connection: keep-alive
# 这里走到了 return 分支，返回 200 状态码
curl if.fgrapp.com/set/fgrapp.com
name: fgrapp.com
# 这里重定向到了 / location 块。
```
## return指令
Syntax:	return code [text];
        return code URL;
        return URL;
Default:	—
Context:	server, location, if
### 返回状态码
- Nginx自定义：
    - 444:关闭链接
- HTTP1.0标准：
    - 301:永久重定向
    - 302:临时重定向，禁止被缓存
- HTTP1.1标准：
    - 303:临时重定向，允许改变方法，禁止被缓存
    - 307:链式重定向，不允许改变方法，禁止被缓存
    - 308:永久重定向，不允许改变方法
## error_page指令
Syntax:	error_page code ... [=[response]] uri;
Default:	—
Context:	http, server, location, if in location

error_page 404             /404.html;
error_page 500 502 503 504 /50x.html;
error_page 404 =200 /empty.gif;
error_page 404 = /404.php;
location / {
    error_page 404 = @fallback;
}

location @fallback {
    proxy_pass http://backend;
}
error_page 403      http://example.com/forbidden.html;
error_page 404 =301 http://example.com/notfound.html;

### 问题
#### server与location块下的return指令的关系？
**优先执行server块下的指令**
#### return与error_page指令的关系？
**优先执行return指令**
### 示例
```nginx
server {
    server_name return.fgrapp.com;

    root html/;
    error_page 404 /50x.html;
    return 405;
    location / {
        return 404 "find nothing!\n";
    }
}
```
```shell
curl return.fgrapp.com/fgr.html
<html>
<head><title>405 Not Allowed</title></head>
<body>
<center><h1>405 Not Allowed</h1></center>
<hr><center>nginx/1.20.2</center>
</body>
</html>
# 这里返回 405 说明 server 块下的 return 优先于 location 块下的 return

# 现在将 server 块下的 return 注释掉
    #return 405;
curl return.fgrapp.com/fgr.html
find nothing!
# 这里返回 404 find nothing! 说明 return 优先于 error_page 指令执行

# 现在将 location 块下的 return 指令注释掉
        #return 404 "find nothing!\n";
curl return.fgrapp.com/fgr.html
<!DOCTYPE html>
<html>
<head>
<title>Error</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>An error occurred.</h1>
<p>Sorry, the page you are looking for is currently unavailable.<br/>
Please try again later.</p>
<p>If you are the system administrator of this resource then you should check
the error log for details.</p>
<p><em>Faithfully yours, nginx.</em></p>
</body>
</html>
# 现在才 50x.html 的内容，说明触发了error_page 指令
```
### rewrite_log指令
记录重定向日志，配合error_log使用
Syntax:	rewrite_log on | off;
Default:	rewrite_log off;
Context:	http, server, location, if
## rewrite指令
Syntax:	rewrite regex replacement [flag];
Default:	—
Context:	server, location, if
### 功能
1.将regex指定的url换成replacement这个新的url
可以使用正则表达式及变量提取
2.当replacement以http://或者https://或者$schema开头，则直接返回302重定向
3.替换后的url根据flag指定的方式进行处理
-    last：用replacement这个URI进行新的location匹配
-    break：停止当前脚本指令的执行，等价于独立的break指令
-    redirect：返回302重定向
-    permanent：返回301重定向
### 示例
#### 目录结构
```conf
html/first/
|___1.txt
html/second/
|___2.txt
html/third/
|___3.txt
```
#### 配置指令
```conf
server {
    server_name rewrite.fgrapp.com;
    root html/;
    location /first {
        rewrite /first(.*) /second$1 last;
        return 200 ‘first!’;
    }
    location /second {
        rewrite /second(.*) /third$1 break;
        return 200 ‘second!’;
    }
    location /third {
        return 200 ‘third!’;
    }   
    location /redirect1 {
        rewrite /redirect1(.*) $1 permanent;
    }
    location /redirect2 {
        rewrite /redirect2(.*) $1 redirect;
    }
    location /redirect3 {
        rewrite /redirect3(.*) http://rewrite.fgrapp.com$1;
    }
    location /redirect4 {
        rewrite /redirect4(.*) http://rewrite.fgrapp.com$1 permanent;
    }
}
```
#### 问题
-    return指令与rewrite指令的顺序关系？
没有flag的情况下优先执行return，有falg的情况下执行rewrite
-    访问/first/3.txt,/second/3.txt,/third/3.txt分别会返回什么？
this is 3.txt,this is 3.txt,third!
-    如果不携带flag会怎么样？
first!,second!,third!
-    访问/redirect1/index.html,/redirect2/index.html,/redirect3/index.html,/redirect4/index.html分别会返回什么？
301,302,302,301
```
cat ../../html/third/3.txt
this is 3.txt
curl rewrite.fgrapp.com/first/3.txt
this is 3.txt
curl rewrite.fgrapp.com/second/3.txt
this is 3.txt
curl rewrite.fgrapp.com/third/3.txt
third!
# 这里可以看到在 rewrite 存在 flag 的情况下，优先执行 rewrite。
            rewrite /first(.*) /second$1;
            #rewrite /first(.*) /second$1 last;
            rewrite /second(.*) /third$1;
            #rewrite /second(.*) /third$1 break;
# 这里将 rewrite 的 flag 参数 取消
curl rewrite.fgrapp.com/first/3.txt
first!
curl rewrite.fgrapp.com/second/3.txt
second!
curl rewrite.fgrapp.com/third/3.txt
third!
# 这里可以看到 rewrite 没有 flag 的情况下，返回的结果都是 return 指令的结果
        rewrite_log on;
        error_log logs/rewrite_error.log notice;
# 这里增加记录重定向日志的配置 这里需要注意不仅 rewrite_log 需要配置为 on，
# error_log 的日志级别也需要设置为 notice
curl rewrite.fgrapp.com/redirect1/index.html -I
HTTP/1.1 301 Moved Permanently
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 08:31:07 GMT
Content-Type: text/html
Content-Length: 169
Location: http://rewrite.fgrapp.com/index.html
Connection: keep-alive
# 这里可以看到 flag 配置为 permanent 返回为 301 重定向
curl rewrite.fgrapp.com/redirect2/index.html -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 08:31:24 GMT
Content-Type: text/html
Content-Length: 145
Location: http://rewrite.fgrapp.com/index.html
Connection: keep-alive
# 这里可以看到 flag 配置为 redirect 返回为 302 重定向
curl rewrite.fgrapp.com/redirect3/index.html -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 08:31:36 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://rewrite.fgrapp.com/index.html
# 这里可以看到默认返回为 302 重定向
curl rewrite.fgrapp.com/redirect4/index.html -I
HTTP/1.1 301 Moved Permanently
Server: nginx/1.20.2
Date: Mon, 28 Mar 2022 08:31:52 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: http://rewrite.fgrapp.com/index.html

#以下为重定向日志
2022/03/28 16:20:13 [notice] 1127325#0: *110 "/redirect1(.*)" matches "/redirect1/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect1/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:13 [notice] 1127325#0: *110 rewritten redirect: "/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect1/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:27 [notice] 1127325#0: *111 "/redirect2(.*)" matches "/redirect2/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect2/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:27 [notice] 1127325#0: *111 rewritten redirect: "/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect2/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:32 [notice] 1127325#0: *112 "/redirect3(.*)" matches "/redirect3/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect3/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:32 [notice] 1127325#0: *112 rewritten redirect: "http://rewrite.fgrapp.com/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect3/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:38 [notice] 1127325#0: *113 "/redirect4(.*)" matches "/redirect4/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect4/index.html HTTP/1.1", host: "rewrite.fgrapp.com"
2022/03/28 16:20:38 [notice] 1127325#0: *113 rewritten redirect: "http://rewrite.fgrapp.com/index.html", client: 82.157.68.63, server: rewrite.fgrapp.com, request: "HEAD /redirect4/index.html HTTP/1.1", host: "rewrite.fgrapp.com"

```
