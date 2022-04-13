---
title: Elasticsearch系列之报错及解决方案
date: 2022-04-07 14:44
tags: 
  - Elasticsearch
  - 问题解决
categories: Elasticsearch
abbrlink: 82b564d9
permalink: /pages/0f33f3/
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## action_request_validation_exception
### 返回内容
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "action_request_validation_exception",
        "reason" : "Validation Failed: 1: internal versioning can not be used for optimistic concurrency control. Please use `if_seq_no` and `if_primary_term` instead;"
      }
    ],
    "type" : "action_request_validation_exception",
    "reason" : "Validation Failed: 1: internal versioning can not be used for optimistic concurrency control. Please use `if_seq_no` and `if_primary_term` instead;"
  },
  "status" : 400
}
```
问题描述:
使用 version 参数进行并发控制
```
PUT website/_doc/1?version=2
{
  "title": "Test Version",
  "text": "test version"
}
```
解决方法:
1.添加`version_type`参数，`version_type=external`此时 version 参数需要大于文档的 version，`version_type=external_gte`此时 version 参数需要大于等于文档的 version，否则会报错
```
PUT website/_doc/1?version=2&version_type=external
{
  "title": "Test Version",
  "text": "test version"
}
```

## version_conflict_engine_exception
返回内容
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "version_conflict_engine_exception",
        "reason" : "[1]: version conflict, current version [2] is higher or equal to the one provided [2]",
        "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
        "shard" : "0",
        "index" : "website"
      }
    ],
    "type" : "version_conflict_engine_exception",
    "reason" : "[1]: version conflict, current version [2] is higher or equal to the one provided [2]",
    "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
    "shard" : "0",
    "index" : "website"
  },
  "status" : 409
}
```
问题描述:
使用 version 和 version_type 进行并发控制
```
PUT website/_doc/1?version=2&version_type=external
{
  "title": "Test Version",
  "text": "test version"
}
```
问题解决:version_type=external 时，需要 version 参数严格大于文档 version,或者指定 version_type=external_gte,此时只需要 version 大于等于文档 version 就可以进行索引操作
两种 type 操作成功后文档 version 都等于参数中指定的 version
```
PUT website/_doc/1?version=2&version_typeernal_gte
{
  "title": "Test Version external_gte",
  "text": "test version external_gte"
}
```
```
{
  "_index" : "website",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 29,
  "_primary_term" : 1
}
```
### 返回结果
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "version_conflict_engine_exception",
        "reason" : "[1]: version conflict, required seqNo [35], primary term [1]. current document has seqNo [36] and primary term [1]",
        "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
        "shard" : "0",
        "index" : "website"
      }
    ],
    "type" : "version_conflict_engine_exception",
    "reason" : "[1]: version conflict, required seqNo [35], primary term [1]. current document has seqNo [36] and primary term [1]",
    "index_uuid" : "cE5GwtBlTDqI8vm4u0-zZg",
    "shard" : "0",
    "index" : "website"
  },
  "status" : 409
}
```
## date_time_parse_exception
### 返回内容
```
{
  "error" : {
    "root_cause" : [
      {
        "type" : "mapper_parsing_exception",
        "reason" : "failed to parse field [date] of type [date] in document with id '1996'. Preview of field's value: '2020/04/07'"
      }
    ],
    "type" : "mapper_parsing_exception",
    "reason" : "failed to parse field [date] of type [date] in document with id '1996'. Preview of field's value: '2020/04/07'",
    "caused_by" : {
      "type" : "illegal_argument_exception",
      "reason" : "failed to parse date field [2020/04/07] with format [strict_date_optional_time||epoch_millis]",
      "caused_by" : {
        "type" : "date_time_parse_exception",
        "reason" : "Failed to parse with all enclosed parsers"
      }
    }
  },
  "status" : 400
}
```
请求内容:
```
PUT website/_doc/1996?if_seq_no=1&if_primary_term=1
{
  "title": "Test Version Controller",
  "text": "use if_seq_no and if_primary_term",
  "date": "2020/04/07"
}
```
解决方法:
日期类型错误，更改日期格式
```
PUT website/_doc/1996?if_seq_no=1&if_primary_term=1
{
  "title": "Test Version Controller",
  "text": "use if_seq_no and if_primary_term",
  "date": "2020-04-07"
}
```