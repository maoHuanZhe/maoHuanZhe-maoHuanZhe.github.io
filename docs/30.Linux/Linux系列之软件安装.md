---
title: Linux系列之软件安装
date: 2022-03-30 14:42
tags: 
  - Linux
  - 软件安装
categories: Linux
abbrlink: 9a9a923e
permalink: /pages/60360b/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 环境变量
当我们执行一个命令的时候，默认从当前路径开始查找
如果当前路径找不到对应的命令文件，从环境变量$PATH 查找
$PATH 的配置文件在/ect/profile
Linux 路径与路径之间用`:`连接
每次修改完以后需要重新加载文件`source /etc/profile
## 软件的安装方式
- 解压安装
- 使用安装包安装
    - 自己下载安装包
    - 使用统一的软件帮助安装
- 通过源码安装
## RPM 安装
- RadHat Package Manager 它属于红帽的一种包管理方式
- 通过 RPM 命令安装软件
    - rpm -ivh jdk-7u67-linux-x64.rpm
- 可以查询软件
    - rpm -qa | grep jdk
    - rpm -q jdk
- 卸载软件
    - rpm -e 
## YUM 安装
### yum 的作用
- 可以帮我们管理 RPM 包
- 可以帮我们安装软件
- 如果软件有其他依赖，会帮我们安装依赖后再安装软件
- 类似于 Maven
### yum 命令
- seach:查询命令或者软件
- info:查看包的信息
- list /list jdk:查询安装的 rpm 包，或者只查询某一种
### 更换 YUM 源
- 首先安装 wget:yum install wget -y
- 将系统原始配置文件生效:mv /etc/yum.repos.d/CentOS-Base.repo //etc/yum.repos.d/CentOS-Base.repo.backup
- 使用 wget 获取阿里 yum 源配置文件
    - wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirros.aliyum.com/repo/Centos-6.repo
    - wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirros.aliyum.com/repo/Centos-7.repo
- 清空以前 yum 源的缓存:yum clean all
- 获取阿里云的缓存:yum makecache
