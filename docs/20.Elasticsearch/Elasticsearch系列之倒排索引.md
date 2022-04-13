---
title: Elasticsearch系列之倒排索引
date: 2022-04-02 13:33
abbrlink: cefbbfec
permalink: /pages/ae8ffc/
categories: 
  - Elasticsearch
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 图书与搜索引擎的类比
- 图书
    - 正排索引:目录页
    - 倒排索引:索引页
- 搜索引擎
    - 正排索引:文档 id 到文档内容和单词的关联
    - 倒排索引:单词到文档 id 的关联
## 倒排索引的核心组成
- 单词词典(Term Dictionary)，记录所有文档的单词，记录单词到倒排列表的关联关系
    - 单词词典一般比较大，可以通过 B+树或哈希链法实现，以满足高性能的插入与查询
- 倒排列表(Posting List)，记录了单词对应的文档结合，由倒排索引项组成
    - 文档 ID
    - 词频 TF:该单词在文档中出现的次数，用于相关性评分
    - 位置(Position):单词在文档中分词的位置。用于语句搜索(phrase query)
    - 偏移(Offset):记录单词的开始结束位置，实现高亮显示
Elasticsearch 的 JSON 文档中的每个字段都有自己的倒排索引
可以指定对某些字段不做索引
 - 优点:节省存储空间
 - 缺点:字段无法被搜索
