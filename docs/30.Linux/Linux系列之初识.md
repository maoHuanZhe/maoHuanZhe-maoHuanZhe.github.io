---
title: Linux系列之初识
date: 2022-03-29 14:47
tags: 
  - Linux
categories: Linux
abbrlink: 56a4954
permalink: /pages/0eaaf5/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 命令学习法
- Linux 命令与参数之间必须用空格隔开
- Linux 命令是区分大小写的
- 命令的类型
    - cd is a shell builtin
    - ping is /usr/sbin/ping
    - ll is aliased to `ls -l --color=auto'
    - for is a shell keyword
## 常用命令
- whereis:查询命令文件的位置
- file:查看文件类型
- who:当前在前的用户
- whoami:我是谁
- pwd:我在哪
- uname -a:查看内核信息
- echo:打印语句
- chear:清屏
- history:历史
## 特殊字符
- `.`点
    - 如果文件的开始是`.`，说明当前文件是一个隐藏文件
    - `.`指向当前目录
    - `..`指向当前目录的上级目录
- `$`
    - 说明这是一个变量
    - $PATH: Linux 的系统变量
- `*`星号
    - 通配符
- `~`
    - 当前用户的家目录
    - 每个用户的家目录是不同的
    - root 用户的家目录在系统跟目录下
    - 其他用户的家目录在`/home/用户名`下
- 空格
    - Linux 命令与参数用空格隔开
- /
    - 整个 Linux 的文件根目录
-  命令的参数
    - 如果是单词，一般加--
    - 如果是字母或者缩写一般加-
