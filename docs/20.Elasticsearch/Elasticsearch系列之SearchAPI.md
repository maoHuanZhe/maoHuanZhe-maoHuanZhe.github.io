---
title: Elasticsearch系列之SearchAPI
date: 2022-04-02 14:56
abbrlink: 58c5d073
permalink: /pages/4e47a2/
categories: 
  - Elasticsearch
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## Search API
- URI Search:在 URL 中使用查询参数
- Request Body Search:使用 Elasticsearch 提供的基于 JSON 格式的更加完备的 Query Domain Specific Language( DSL)
## 指定查询的索引
- /_search:集群上所有的索引
- /index1/_search:index1
- /index1，index2/_search:index1 和 index2
- /index*/_search:以 index 开头的索引
## 搜索的相关性 Relevance
- 搜索时用户和搜索引擎的对话
- 用户关心的是搜索结果的相关性
    - 是否可以找到所有相关的内容
    - 有多少不相关的内容被返回了
    - 文档的打分是否合理
    - 结合业务需求，平衡结果排名
## URI Search 
通过 URI Query 实现搜索
- q 指定查询语句，使用 Query String Syntax
- df 默认字段，不指定时，会对所有字段进行查询
- Sort 排序 / from 和 size 用于分页
- Profile 可以查看查询是如何被执行的
## 指定字段查询 与 泛查询
```
#带profile
GET /movies/_search?q=2012&df=title
{
  "profile": "true"
}

#泛查询
GET /movies/_search?q=2012
{
  "profile": "true"
}

# 指定字段
GET /movies/_search?q=title:2012
{
  "profile": "true"
}

# 使用引号 Phrase查询 
GET /movies/_search?q=title:"Beautiful Mind"
{
  "profile": "true"
}

# 使用引号 Phrase查询 
GET /movies/_search?q=title:Beautiful Mind
{
  "profile": "true"
}

# 分组 Bool查询 
GET /movies/_search?q=title:(Beautiful AND Mind)
{
  "profile": "true"
}


# 分组 Bool查询 
GET /movies/_search?q=title:(Beautiful NOT Mind)
{
  "profile": "true"
}

# 范围查询，区间写法 / 数学写法
GET /movies/_search?q=year:>=1980
{
  "profile": "true"
}

# 通配符查询
GET /movies/_search?q=title:b*
{
  "profile": "true"
}

# 模糊匹配 & 近似度匹配
GET /movies/_search?q=title:beautifl~1
{
  "profile": "true"
}

GET /movies/_search?q=title:"Lord Rings"~2
{
  "profile": "true"
}

```

## RequstBody
```
# 对bytes排序
POST kibana_sample_data_logs/_search
{
  "sort": [
    {
      "bytes": {
        "order": "desc"
      }
    }
  ],
  "query": {
    "match_all": {}
  }
}
# source filtering
POST kibana_sample_data_logs/_search
{
  "_source": ["clientip"],
  "query": {
    "match_all": {}
  }
}

# 脚本字段
GET kibana_sample_data_logs/_search
{
  "script_fields": {
    "new_fields": {
      "script": {
        "lang": "painless",
        "source": "doc['bytes'].value + '-bit'"
      }
    }
  },
  "query": {
    "match_all": {}
  }
}

POST movies/_search
{
  "query": {
    "match": {
      "title": "Last Christmas"
    }
  }
}


POST movies/_search
{
  "query": {
    "match": {
      "title": {
        "query": "Last Christmas",
        "operator": "and"
      }
    }
  }
}

POST movies/_search
{
  "query": {
    "match_phrase": {
      "title": "one love"
    }
  }
}


POST movies/_search
{
  "query": {
    "match_phrase": {
      "title": {
        "query": "one love",
        "slop": 1
      }
    }
  }
}

```
## Query String
