---
title: Elasticsearch系列之文档操作
date: 2022-04-02 10:37
tags: 
  - Elasticsearch
  - 文档
  - CRUD
categories: Elasticsearch
abbrlink: 310a8b2f
permalink: /pages/f412d1/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 新增一个文档
### 自动生成文档 ID
```
POST website/_doc
{
  "title": "My first blog",
  "text": "Just trying this out...",
  "date": "2022-04-07"
}

```    
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "R_zBAYABMeTiIsDGa9Rd",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}

```
### 自己指定 ID
#### 使用`create`
请求方式为`PUT`
```
PUT website/_create/2
{
  "title": "My first blog",
  "text": "Just trying this out...",
  "date": "2022-04-07"
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "2",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 1,
  "_primary_term" : 1
}
```
请求方式为`POST`
```
POST website/_create/3
{
  "title": "My first blog",
  "text": "Just trying this out...",
  "date": "2022-04-07"
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 2,
  "_primary_term" : 1
}
```
#### 使用`op_type=create`
请求方式为`PUT`
```
PUT website/_doc/4?op_type=create
{
  "title": "My first blog",
  "text": "Just trying this out...",
  "date": "2022-04-07"
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "4",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 3,
  "_primary_term" : 1
}
```
请求方式为`POST`
```
POST website/_doc/5?op_type=create
{
  "title": "My first blog",
  "text": "Just trying this out...",
  "date": "2022-04-07"
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "5",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 4,
  "_primary_term" : 1
}
```
### 总结
自动生成 ID 时，需要使用`PUT`方法，只需要指定`索引`就可以了，`**type`在`6.x`版本后已被取消**。具体可参考[removal-of-types](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/removal-of-types.html)
自定义 ID 时，`PUT`方法与`POST`方法都行，可使用`website/_create/3`或`website/_doc/5?op_type=create`两种方式
在创建一个新文档成功时，返回结果中的`result`字段为`created`，在后续内容中的更新时该字段的结果为`updated`，删除时该字段的结果为`deleted`
如果索引存在会返回报错信息
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "version_conflict_engine_exception",
        "reason" : "[3]: version conflict, document already exists (current version [1])",
        "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
        "shard" : "0",
        "index" : "website"
      }
    ],
    "type" : "version_conflict_engine_exception",
    "reason" : "[3]: version conflict, document already exists (current version [1])",
    "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
    "shard" : "0",
    "index" : "website"
  },
  "status" : 409
}
```
更多内容可参考[docs-index](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html)
## 查询一个文档
### 查询文档是否存在
```
HEAD website/_doc/2
```
请求结果
```
200 - OK
```
### 获取文档全部信息
```
GET website/_doc/2
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "2",
  "_version" : 1,
  "_seq_no" : 1,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "My first blog",
    "text" : "Just trying this out...",
    "date" : "2022-04-07"
  }
}
```
### 获取文档指定信息
```
GET website/_doc/2?_source=title,text
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "2",
  "_version" : 1,
  "_seq_no" : 1,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "text" : "Just trying this out...",
    "title" : "My first blog"
  }
}
```
### 获取文档源信息
```
GET website/_source/2
```
请求结果
```
{
  "title" : "My first blog",
  "text" : "Just trying this out...",
  "date" : "2022-04-07"
}
```
还可以和上一个查询组合一下，只获取源信息中的指定字段
```
GET website/_source/2?_source=title
```
请求结果
```
{
  "title" : "My first blog"
}
```
更多内容可参考[docs-get](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html)
## 删除一个文档
```
DELETE website/_doc/2
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "2",
  "_version" : 2,
  "result" : "deleted",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 5,
  "_primary_term" : 1
}
```
**删除操作也会使该文档的`_version`字段更新**
更多内容可参考[docs-delete](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html)
以上是根据 ID 删除指定文档，还可以根据查询条件删除符合条件的文档`Delete by query API`，可以参考[docs-delete-by-query](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html)
## Update 文档
### 更新整个文档
```
PUT website/_doc/3
{
  "title": "My first blog of update",
  "text": "Just trying update"
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 10,
  "_primary_term" : 1
}
```
查看更新的后的文档
```
GET website/_doc/3
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 2,
  "_seq_no" : 10,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "My first blog of update",
    "text" : "Just trying update"
  }
}
```
**这里如果指定的 ID 不存在的话，会创建一个新的文档**，可以根据返回值中的`result`字段判断是更新(`updated`)还是创建(`created`)
这里的更新是直接用请求的内容替换原有的内容，而不是只更新其中的某些字段。
### 更新局部文档
查看更新前的文档内容
```
GET website/_doc/3
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 8,
  "_seq_no" : 18,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "My first blog of update",
    "text" : "Just trying update"
  }
}
```
更新文档
```
POST website/_update/3
{
  "doc": {
    "text": "Update by _update",
    "date": "2022-04-07"
  }
}
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 9,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 19,
  "_primary_term" : 1
}
```
查看更新后的文档
```
GET website/_doc/3
```
请求结果
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "3",
  "_version" : 9,
  "_seq_no" : 19,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "My first blog of update",
    "text" : "Update by _update",
    "date" : "2022-04-07"
  }
}
```
**这里如果指定的 ID 不存在的话，会返回 404 异常**
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "document_missing_exception",
        "reason" : "[_doc][33]: document missing",
        "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
        "shard" : "0",
        "index" : "website"
      }
    ],
    "type" : "document_missing_exception",
    "reason" : "[_doc][33]: document missing",
    "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
    "shard" : "0",
    "index" : "website"
  },
  "status" : 404
}
```
这里的更新是对现有文档添加字段或者更新其中字段的值
### 总结
Elasticsearch 中的文档是不可修改的，所以上述的更新的具体流程是:
- 从旧文档中检索 JSON
- 修改它（在局部更新中存在该步骤）
- 删除旧文档
- 索引新文档
可以参考[docs-update](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html)
以上是根据 ID 更新文档，还可以根据查询条件更新符合条件的文档`Update By Query API`，可以参考[docs-update-by-query](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html)
## 并发控制
Elasticsearch 采用乐观并发控制
Elasticsearch 推荐使用`_seq_no`和`_primary_term`参数标识文档的版本。可以通过在操作的参数中加入这两个参数进行并发控制
首先新增一个文档
```
PUT website/_doc/1996
{
  "title": "Test Version Controller",
  "text": "use if_seq_no and if_primary_term"
}
```
返回结果，可以看到此时`_seq_no`为 37，`_primary_term`为 1.
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "1996",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 37,
  "_primary_term" : 1
}
```
更新文档
```
PUT website/_doc/1996?if_seq_no=37&if_primary_term=1
{
  "title": "Test Version Controller",
  "text": "use if_seq_no and if_primary_term",
  "date": "2020-04-07"
}
```
返回结果，此时更新成功了，`_seq_no`变为了 38
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "1996",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 38,
  "_primary_term" : 1
}
```
用刚才的参数再次请求
```
PUT website/_doc/1996?if_seq_no=37f_primary_term=1
{
  "title": "Test Version Controller",
  "text": "use if_seq_no and if_primary_term",
  "date": "2020-04-07"
}
```
返回结果，这时候就报错了，因为`_seq_no`已经改变了，`_seq_no`参数校验不相等的话就操作不成功
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "version_conflict_engine_exception",
        "reason" : "[1996]: version conflict, required seqNo [37], primary term [1]. current document has seqNo [38] and primary term [1]",
        "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
        "shard" : "0",
        "index" : "website"
      }
    ],
    "type" : "version_conflict_engine_exception",
    "reason" : "[1996]: version conflict, required seqNo [37], primary term [1]. current document has seqNo [38] and primary term [1]",
    "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
    "shard" : "0",
    "index" : "website"
  },
  "status" : 409
}
```
更多请参考[optimistic-concurrency-control](https://www.elastic.co/guide/en/elasticsearch/reference/current/optimistic-concurrency-control.html)
### 使用 version 与 version_type 参数进行并发控制
`version_type`可以取值为`external`和`external_gte`两种
- 为`external`时，version 值需要大于文档的 `_version`值
- 为`external_gte`时，version 值需要大于等于文档的`_version`值
首先获取文档信息
```
GET website/_doc/1996
```
返回结果，可以看到当前的`_version`为 2
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "1996",
  "_version" : 2,
  "_seq_no" : 38,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "Test Version Controller",
    "text" : "use if_seq_no and if_primary_term",
    "date" : "2020-04-07"
  }
}
```
通过 `version`与`version_type`进行并发控制
```
PUT website/_doc/1996?version=4&version_type=external
{
  "title": "Test Version Controller",
  "text": "use version and version_type"
}
```
返回结果，可以看到更新成功了，`**_version`的值变成了参数中指定的值，而不是在原先的基础上加一了**
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "1996",
  "_version" : 4,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 39,
  "_primary_term" : 1
}
```
## 总结
- `GET`方法检索文档
- `DELETE`方法删除文档
- `HEAD`方法判断文档是否存在
- `POST`方法可以新增或更新文档(局部更新和全部更新)，可以通过`_create`或者`op_type=create`指定当前操作为新增操作，通过`_update`指定当前操作为局部更新
- `PUT`方法也可以新增或者更新文档(只能全部更新不能局部更新)，可以通过`_create`或者`op_type=create`指定当前操作为新增操作