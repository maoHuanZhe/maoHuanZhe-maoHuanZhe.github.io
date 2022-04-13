---
title: Linux系列之网络信息
date: 2022-03-29 17:24
tags: 
  - Linux
  - 网络信息
categories: Linux
abbrlink: 49b9ad69
permalink: /pages/016dd2/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 主机名称
- 临时修改
    - hostname newname
- 长久修改
    - vim /etc/hostname
## 网络相关命令
- ifconfig
    - 查看当前网卡的配置信息
    - 可以使用 ip addr 替代
- netstat
    - 查看当前网络的状态信息
    - 一个机器默认有 65536 个端口号[0，65535]
    - 这是一个逻辑概念，将来我们需要使用程序监听指定端口，等待别人访问
    - 一个端口只能被一个程序监听
    - netstat -anp
    - netstat -r
- ping
    - 查看与目标 IP地址是否能够连通
- telnet
    - 查看与目标 IP地址的指定端口能否连通
    - yum install telnet -y
    - telnet 82.157.68.63 22 
- curl
- wget
## 防火墙
防火墙技术是通过有机结合各类用于安全管理与筛选的软件和硬件设备，帮助计算机网络于其内外网之间构建一道相对隔绝的保护屏障，以保护用户资料与信息安全性的一种技术
在 CengOS7+中使用 firewalld 替代以前的 iptables；
## 加密算法
- 不可逆加密算法
- 对称加密算法
- 非对称加密算法
## 主机间的相互免秘钥
- 可以通过 ssh 命令免秘钥连接到其他的主机
- 如果是第一次建立连接，需要输入 yes
    - 在~/.ssh/known_hosts 文件记录了以前访问地址(ip_hostname)的信息
    - 在访问地址的时候如果没有收录到known_hosts 文件中，就需要输入 yes
    - 如果以前收录到known_hosts 中，直接输入密码即可
- 需要输入密码
    - 生成秘钥
        - ssh-keygen -r rsa -P ' ' -f ~/.ssh/id_rsa
    - 如果想免秘钥登陆谁，只需要把自己的公钥传递给对方主机即可
    - 这个秘钥要放在~/.ssh/authorized_keys
        - ssh-copy-id -i ~/.ssh/id_rsa.pub root@82.157.68.63
    - 相互免秘钥工作流程
```
# 在主机 124.221.77.231 上操作
ssh-keygen -C
ssh-copy-id -i ~/.ssh/id_rsa.pub root@82.157.68.63
 在主机 82.157.68.63 上操作
ssh-copy-id -i ~/.ssh/id_rsa.pub root@82.157.68.63
```
## 主机名与 Host 校验
    - ssh -v -o GSSAPIAuthentication=no root@82.57.68.63
        - 本次不提示
    - 修改/etc/ssh/ssh_config 文件的配置，以后则不会出现此问题
    - 最后添加:
        - StrctHostKeyChecking no
        - UserKnownHostFile /dev/null 
## 配置主机与 IP 的映射关系
```shell
vim /etc/hosts
82.157.68.63 fgrapp1
```