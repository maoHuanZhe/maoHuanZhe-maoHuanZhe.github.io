---
title: Elasticsearch系列之安装
date: 2022-03-31 10:07
abbrlink: c6f7b2b8
permalink: /pages/da6911/
categories: 
  - Elasticsearch
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 安装
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.1-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.1-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.1.1-linux-x86_64.tar.gz.
-bash: shasum: command not found
yum install perl-Digest-SHA
tar -xzf elasticsearch-8.1.1-linux-x86_64.tar.gz
cd elasticsearch-8.1.1/ 
bin/elasticsearch
Killed
vim bin/elasticsearch
ES_JAVA_OPTS="-Xms1g -Xmx1g"
失败
修改ES中config目录下的jvm.options文件
vim jvm.options
将
-Xms1g
-Xmx1g
改为
-Xms512m
-Xmx512m
就启动成功了

can not run elasticsearch as root

useradd es
passwd es

chown -R es:es elasticsearch-8.1.1

启动成功后访问不了 控制台输出
received plaintext http traffic on an https channel, closing connection

vim config/elasticsearch.yml
xpack.security.enabled设置为false
http://82.157.68.63:9200
{
  "name" : "VM-24-6-centos",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "gY8rk85OR2iOwXqaDSKi3A",
  "version" : {
    "number" : "8.1.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "d0925dd6f22e07b935750420a3155db6e5c58381",
    "build_date" : "2022-03-17T22:01:32.658689558Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```
## 插件
```
bin/elasticsearch-plugin list
bin/elasticsearch-plugin install analysis-icu

82.157.68.63:9200/_cat/plugins
VM-24-6-centos analysis-icu 8.1.1

集群启动

```