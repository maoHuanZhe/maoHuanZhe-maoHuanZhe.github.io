---
title: Linux系列之用户-组-权限
date: 2022-03-30 10:46
tags: 
  - Linux
  - 用户
  - 组
  - 权限
categories: Linux
abbrlink: 6b2524c4
permalink: /pages/dffbd9/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 用户
- 新增用户
    - useradd fgrapp
    - 会创建同名的组和家目录
- 设置密码
    - passwd fgrapp
- 删除用户
    - userdel -r fgrapp
    - 级联删除家目录和组
- 修改用户信息
    - usermod -l fgrapp fgr: 修改用户名，家目录和组名称是不会被修改的
    - usermod -L fgrapp 锁定用户名
    - usermod -U fgrapp 解锁用户名
- 常用文件
    - cat /etc/shadow:用户名和密码
    - cat /etc/passwd
        - 用户名，编号，组编号，家目录，命令
- 切换用户
    - su fgrapp
## 组
- 创建组
    - groupadd fgr
- 删除组
    - groupdel fgr
- 修改组名称
    - groupmod -n fgr fgrapp
- 查看用户对应的组
    - groups
    - groups fgrapp
        - 当创建用户时，会默认创建一个同名的组
- 修改用户的组
    - usermod -g fgrapp fgr
    - usermod -G fgrapp f
## 权限
- chown
- chmod
