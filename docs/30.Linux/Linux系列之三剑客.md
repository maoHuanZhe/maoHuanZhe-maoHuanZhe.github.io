---
title: Linux系列之三剑客
date: 2022-03-30 15:33
tags: 
  - Linux
  - 三剑客
categories: Linux
abbrlink: 81ab3b26
permalink: /pages/7245bb/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 普通剑客
- cut
    - 用指定的规则来切分文本
    - cut -d ':' -f 1,2,3 passwd | grep school
- sort
    - sort fgrapp:对文本中的行进行排序
    - sort -t ' ' -k 2 fgrapp:对每一行的数据进行切分，按照第二列进行排序
    - sort -t ' ' -k 2 -r fgrapp:逆序
    - sort -t ' ' -k 2 -n fgrapp:按照数值大小进行排序，如果有字母，字母在前
- wc
    - 统计单词的数量
    - wc fgrapp
        - -l
        - -w
        - -c
## grep
- 可以对文本进行搜索
- 同时搜索多个文件
    - 从文档中查询指定的数据
    - grep adm passwd
    - grep school passwd lucky
- 显示匹配的行号
    - grep -n school passwd
- 显示不匹配的忽略大小写
    - grep -nvi school passwd --color=auto
- 使用正则表达式匹配
    - grep -E "[1-9]+" passwd --color=auto
## sed
- sed 是 Stream Editor(字符流编辑器)的缩写，简称流编辑器
- sed 软件从文件或管道中读取一行处理一行输入一行，
- 一次一行的的设计使得 sed 性能很高
- vim 命令打开文件是一次性将文件加载到内存
### awk
