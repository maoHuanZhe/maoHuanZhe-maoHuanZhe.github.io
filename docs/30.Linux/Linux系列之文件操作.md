---
title: Linux系列之文件操作
date: 2022-03-29 15:33
tags: 
  - Linux
  - 文件系统
categories: Linux
abbrlink: 63ebfd22
permalink: /pages/f4cd24/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## cd
改变当前工作目录
## ls
- 显示出指定目录下所有的文件
- 文件的类型
    - `-`普通文件
    - `d`文件夹
    - `l`软链接
- ls
- ls -a
- ls -la
- ll
## mkdir
- 创建文件夹
- mkdir aaa:创建文件夹 aaa
- mkdir -p bbb/ccc:递归创建文件夹，创建 bbb 文件夹，然后在 bbb 文件夹内创建 ccc 文件夹
- mkdir a{1,3,5}:创建 a1、a3、a5 文件夹
- mkdir -p a/{1,3,5}:递归创建文件夹，创建 a 文件夹，然后在 a 文件夹内创建 1、3、5 文件夹
## rmdir
- 删除空文件夹
- 要删除的首先要是个文件夹，其次该文件夹必须是空的
- rmdir aaa : 删除 aaa 文件夹，如果 aaa 文件夹不为空的话，不会删除
- rmdir -p aaa/bbb:递归删除空文件夹，如果 bbb 文件夹为空则删除 bbb 文件夹，然后如果此时 aaa 文件夹为空则删除 aaa 文件夹，否则不删除 aaa 文件夹
- rmdir a{1,3,5}:删除 a1、a3、a5 文件夹，如果不为空则不删除
- rmdir -p a/{1,3,5}:递归删除空文件夹，如果 1，3，5 文件夹为空则删除这些文件夹，然后如果此时 a 文件夹为空则删除 a 文件夹，否则不删除 a 文件夹
## cp
- 复制
- cp 源文件 目标目录
- cp aaa /opt:将当前路径下的 aaa 文件复制到/opt 目录下
- cp -r bbb/ /opt :将当前路径下的 bbb 文件夹复制到/opt 目录下
- cp -r a* /opt: 将当前路径下的以 a 开头的文件和文件夹复制到/opt 目录下
## mv
- 移动文件或文件夹
    - mv a.txt /opt:将当前路径下的 a.txt 文件移动到/opt 目录下
    - mv aaa/ /opt:将当前路径下的 aaa 文件夹移动到/opt 目录下
- 修改文件名称
    - mv a.txt b.txt:将 a.txt 重命名为 b.txt
    - mv a.txt /opt/b.txt:将 a.txt 移动到/opt 目录下并重命名为 b.txt
## rm
- 删除文件或文件夹
- rm a.txt :删除 a.txt 文件
- rm -r aaa/:删除 aaa 文件夹
- rm -f a.txt:强制删除，不再询问
- rm -rf aaa:强制删除文件夹
## touch
- 如果文件不存在则创建文件，如果文件存在则修改文件元数据
- touch a.txt
## stat
- 查看文件元数据
- stat a.txt
## ln
- 创建文件的连接
- 软链接
    - ln -s 源文件 连接名
    - ln -s a.txt alink
    - 软链接和原始文件不是同一个文件
- 硬连接
    - ln 源文件 连接名
    - ln a.txt slink
    - 硬连接和原始文件使用文件系统中的同一个文件
    - 如果害怕一个文件被误删，可以使用硬连接保护这个文件
- 软链接在连接文件的时候，推荐使用文件的绝对路径
## 文件的查看
- cat 
- tac
- more
- less
- head
    - head -number filename
- tail
    - tail -number filename
- head -9 a.txt | tail -1
- tail -f access.log
## find
- 文件查找
- find / -name filename
## 文件大小
- 分区信息
    - df -h
- 指定文件目录大小
    - du -h --max-depth=1 filename
## 文件压缩
- tar
    - -zxvf:解压缩
    - -C 指定目录
    - -zcf:压缩
