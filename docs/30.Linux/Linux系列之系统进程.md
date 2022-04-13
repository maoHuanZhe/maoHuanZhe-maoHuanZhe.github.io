---
title: Linux系列之系统进程
date: 2022-03-30 14:25
tags: 
  - Linux
  - 进程
categories: Linux
abbrlink: e38bc658
permalink: /pages/e7c453/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 进程信息
- ps -ef 
- ps -ef | grep nginx
- ps -aux
- top
## 后台进程
- 只需要在命令后面加上 & 
    - ping www.baidu.com >> baidu &
- jobs -l
    - 查看当前的后台进程
    - 但是只有当前用户界面可以获取到
- nohup 可以防止后台进程被挂起
    - nohup ping www.baidu.com >> baidu 2>&1 &
## 杀死进程
- kill -9 PID

