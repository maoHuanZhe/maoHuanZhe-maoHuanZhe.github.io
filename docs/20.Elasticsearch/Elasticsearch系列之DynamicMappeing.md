---
title: Elasticsearch系列之DynamicMappeing
date: 2022-04-13 15:55:02
permalink: /pages/d425f6/
categories:
  - Elasticsearch
tags:
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
````
---
 title: Elasticsearch系列之DynamicMappeing
date: '2022-04-02 16:59'
abbrlink: c29606da


---

## 什么是 Mapping

- Mapping 类似于数据库中的 schema 的定义，作用如下
  - 定义索引中的字段的名称
  - 定义字段的数据类型，例如字符串，数字，布尔。。。
  - 字段，倒排索引的相关配置
- Mapping 会把 JSON 文档映射成 Lucene 所需要的扁平格式
- 每个 Mapping都属于一个索引的 Type
  - 每个文档都属于一个 Type
  - 一个 Type 有一个 Mapping 定义
  - 7.0 开始，不需要在 Mapping 定义中指定 type 信息

```
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "users",
        "creation_date" : "1648890213168",
        "number_of_replicas" : "1",
        "uuid" : "ytfnghKqQbmka-sHYj0WJw",
        "version" : {
          "created" : "8010199"
        }
      }
    }. 
```

## 字段的类型

- 简单类型
  - Text  / Keyword
  - Date
  - Integer / Floating
  - Boolean
  - IPv4 & IPv6 
- 复杂类型 - 对象和嵌套对象
  - 对象类型 / 嵌套类型
- 特殊类型
  - geo_point & geo_shape / percolator

## Dynamic Mapping

- 在写入文档的时候，如果索引不存在，会自动创建索引
- Dynamic Mapping的机制，使得我们无需手动定义Mappings。Elasticsearch会自动根据文档信息，推算出字段的类型
- 但是有时候会推算的不对，例如地理位置信息
- 当类型如果设置不对时，会导致一些功能无法正常运行，例如 Range 查询

## 类型的自动识别

- 字符串
  - 匹配日期格式，设置成Date
  - 配置数字设置为float或者long，该选项默认关闭
  - 设置为Text，并且增加keyword子字段
- 布尔值：boolean
- 浮点数：float
- 整数：long
- 对象：Object
- 数组：由第一个非空数值的类型所决定
- 空值：忽略

```http
# 写入文档 查看Mapping
PUT mapping_test/_doc/1
{
  "firstName" : "Fan",
  "lastName" : "Guangrui",
  "loginDate" : "2022-04-03T14:14:30.123Z"
}

{
  "_index" : "mapping_test",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}

# 查看 Mapping文件
GET mapping_test/_mapping
{
  "mapping_test" : {
    "mappings" : {
      "dynamic_templates" : [
        {
          "message_full" : {
            "match" : "message_full",
            "mapping" : {
              "fields" : {
                "keyword" : {
                  "ignore_above" : 2048,
                  "type" : "keyword"
                }
              },
              "type" : "text"
            }
          }
        },
        {
          "message" : {
            "match" : "message",
            "mapping" : {
              "type" : "text"
            }
          }
        },
        {
          "strings" : {
            "match_mapping_type" : "string",
            "mapping" : {
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "firstName" : {
          "type" : "keyword"
        },
        "lastName" : {
          "type" : "keyword"
        },
        "loginDate" : {
          "type" : "date"
        }
      }
    }
  }
}

# 删除索引
DELETE mapping_test

{
  "acknowledged" : true
}

# dynamic mapping 推断字段的类型
PUT mapping_test/_doc/1
{
  "uid": "123",
  "isVip": false,
  "isAdmin": "true",
  "age": 26,
  "height": 169
}

{
  "_index" : "mapping_test",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}

# 查看Mapping
GET mapping_test/_mapping

{
  "mapping_test" : {
    "mappings" : {
      "dynamic_templates" : [
        {
          "message_full" : {
            "match" : "message_full",
            "mapping" : {
              "fields" : {
                "keyword" : {
                  "ignore_above" : 2048,
                  "type" : "keyword"
                }
              },
              "type" : "text"
            }
          }
        },
        {
          "message" : {
            "match" : "message",
            "mapping" : {
              "type" : "text"
            }
          }
        },
        {
          "strings" : {
            "match_mapping_type" : "string",
            "mapping" : {
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "age" : {
          "type" : "long"
        },
        "height" : {
          "type" : "long"
        },
        "isAdmin" : {
          "type" : "keyword"
        },
        "isVip" : {
          "type" : "boolean"
        },
        "uid" : {
          "type" : "keyword"
        }
      }
    }
  }
}

```

## 能否更改Mapping的字段类型

- 新增字段
  - Dynamic设为true时，一旦有新增字段的文档写入，Mapping也同时被更新
  - Dynamic设为false，Mapping不会被更新，新增字段的数据无法被索引，但是信息会出现在_source中
  - Dynamic设置成Strict，文档写入失败
- 已有字段，一旦已经有数据写入，就不再支持修改字段定义（Lucene实现的倒排索引，一旦生成后，就不允许修改）
- 如果希望改变字段类型，必须使用Reindex API，重建索引
  - 如果修改了字段的数据类型，会导致已被索引的数据无法被搜索
  - 但是如果是新增加的字段，就不会有这样的影响

## 控制Dynamic Mapping

- 当dynamic被设置成false时，存在新增字段的数据写入，该数据可以被索引，但是新增字段被丢弃
- 当设置成Strict模式时，数据写入直接出错

```
# 默认Mapping支持dynamic，吸入的文档中加入新的字段
PUT dynamic_mapping_test/_doc/1
{
  "newField": "someValue"
}
{
  "_index" : "dynamic_mapping_test",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}

POST dynamic_mapping_test/_search
{
  "query": {
    "match": {
      "newField": "someValue"
    }
  }
}

{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "dynamic_mapping_test",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "newField" : "someValue"
        }
      }
    ]
  }
}

# 修改dynamic 为 false
PUT dynamic_mapping_test/_mapping
{
  "dynamic": false
}

{
  "acknowledged" : true
}

GET dynamic_mapping_test/_mapping

{
  "dynamic_mapping_test" : {
    "mappings" : {
      "dynamic" : "false",
      "dynamic_templates" : [
        {
          "message_full" : {
            "match" : "message_full",
            "mapping" : {
              "fields" : {
                "keyword" : {
                  "ignore_above" : 2048,
                  "type" : "keyword"
                }
              },
              "type" : "text"
            }
          }
        },
        {
          "message" : {
            "match" : "message",
            "mapping" : {
              "type" : "text"
            }
          }
        },
        {
          "strings" : {
            "match_mapping_type" : "string",
            "mapping" : {
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "newField" : {
          "type" : "keyword"
        }
      }
    }
  }
}

# 新增 anotherField
PUT dynamic_mapping_test/_doc/10
{
  "anotherField": "someValue"
}
{
  "_index" : "dynamic_mapping_test",
  "_type" : "_doc",
  "_id" : "10",
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

# 该字段不可以被搜索 
POST dynamic_mapping_test/_search
{
  "query": {
    "match": {
      "anotherField": "someValue"
    }
  }
}
{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 0,
      "relation" : "eq"
    },
    "max_score" : null,
    "hits" : [ ]
  }
}

# mapping中并没有anotherField
GET dynamic_mapping_test/_mapping
{
  "dynamic_mapping_test" : {
    "mappings" : {
      "dynamic" : "false",
      "dynamic_templates" : [
        {
          "message_full" : {
            "match" : "message_full",
            "mapping" : {
              "fields" : {
                "keyword" : {
                  "ignore_above" : 2048,
                  "type" : "keyword"
                }
              },
              "type" : "text"
            }
          }
        },
        {
          "message" : {
            "match" : "message",
            "mapping" : {
              "type" : "text"
            }
          }
        },
        {
          "strings" : {
            "match_mapping_type" : "string",
            "mapping" : {
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "newField" : {
          "type" : "keyword"
        }
      }
    }
  }
}
# 数据是存在的
GET dynamic_mapping_test/_doc/10
{
  "_index" : "dynamic_mapping_test",
  "_type" : "_doc",
  "_id" : "10",
  "_version" : 1,
  "_seq_no" : 1,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "anotherField" : "someValue"
  }
}

# dynamic 设置为 strict
PUT dynamic_mapping_test/_mapping
{
  "dynamic": "strict"
}
{
  "acknowledged" : true
}


# 尝试添加字段
PUT dynamic_mapping_test/_doc/12
{
  "lastField": "elasticsearch"
}

{
  "error" : {
    "root_cause" : [
      {
        "type" : "strict_dynamic_mapping_exception",
        "reason" : "mapping set to strict, dynamic introduction of [lastField] within [_doc] is not allowed"
      }
    ],
    "type" : "strict_dynamic_mapping_exception",
    "reason" : "mapping set to strict, dynamic introduction of [lastField] within [_doc] is not allowed"
  },
  "status" : 400
}

PUT dynamic_mapping_test/_doc/12
{
  "newField": "elasticsearch"
}

{
  "_index" : "dynamic_mapping_test",
  "_type" : "_doc",
  "_id" : "12",
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

PUT dynamic_mapping_test/_doc/13
{
  "anotherField": "elasticsearch"
}
{
  "error" : {
    "root_cause" : [
      {
        "type" : "strict_dynamic_mapping_exception",
        "reason" : "mapping set to strict, dynamic introduction of [anotherField] within [_doc] is not allowed"
      }
    ],
    "type" : "strict_dynamic_mapping_exception",
    "reason" : "mapping set to strict, dynamic introduction of [anotherField] within [_doc] is not allowed"
  },
  "status" : 400
}

DELETE dynamic_mapping_test
{
  "acknowledged" : true
}
```

## 如何显示定义一个Mapping

- 可以参考API手册，纯手写
- 为了减少输入的工作量，减少出错概率，可以依照以下步骤
  - 创建一个临时的index，写入一些样本数据
  - 通过访问MappingAPI获得该临时文件的动态Mapping定义
  - 对该配置修改后创建自己的索引
  - 删除临时索引xxxxxxxxxx     "settings" : {      "index" : {        "routing" : {          "allocation" : {            "include" : {              "_tier_preference" : "data_content"            }          }        },        "number_of_shards" : "1",        "provided_name" : "users",        "creation_date" : "1648890213168",        "number_of_replicas" : "1",        "uuid" : "ytfnghKqQbmka-sHYj0WJw",        "version" : {          "created" : "8010199"        }      }    }. 
````
```
```
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "users",
        "creation_date" : "1648890213168",
        "number_of_replicas" : "1",
        "uuid" : "ytfnghKqQbmka-sHYj0WJw",
        "version" : {
          "created" : "8010199"
        }
      }
    }. 
```
```
PUT users
{
  "mappings": {
    "properties": {
      "firstName" : {
        "type": "text"
      },
      "lastName" : {
        "type": "text"
      },
      "mobile" : {
        "type": "text",
        "index": false
      }
    }
  }
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "users"
}

PUT users/_doc/1
{
  "firstName":"Fan",
  "lastName": "Guangrui",
  "mobile": "15178292346"
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
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

POST /users/_search
{
  "query": {
    "match": {
      "mobile": "15178292346"
    }
  }
}
{
  "error" : {
    "root_cause" : [
      {
        "type" : "query_shard_exception",
        "reason" : "failed to create query: Cannot search on field [mobile] since it is not indexed.",
        "index_uuid" : "NsBXdC02TRyE7OqgrPL5jw",
        "index" : "users"
      }
    ],
    "type" : "search_phase_execution_exception",
    "reason" : "all shards failed",
    "phase" : "query",
    "grouped" : true,
    "failed_shards" : [
      {
        "shard" : 0,
        "index" : "users",
        "node" : "ngUMquIGT3SvZxF56R8W0w",
        "reason" : {
          "type" : "query_shard_exception",
          "reason" : "failed to create query: Cannot search on field [mobile] since it is not indexed.",
          "index_uuid" : "NsBXdC02TRyE7OqgrPL5jw",
          "index" : "users",
          "caused_by" : {
            "type" : "illegal_argument_exception",
            "reason" : "Cannot search on field [mobile] since it is not indexed."
          }
        }
      }
    ]
  },
  "status" : 400
}

PUT users
{
  "mappings": {
    "properties": {
      "firstName" : {
        "type": "text"
      },
      "lastName" : {
        "type": "text"
      },
      "mobile" : {
        "type": "keyword",
        "null_value": "NULL"
      },
      "phone" : {
        "type" : "keyword"
      }
    }
  }
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "users"
}

PUT users/_doc/1
{
  "firstName": "Fan",
  "lastName": "Guangrui",
  "mobile": null,
  "phone": null
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
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

PUT users/_doc/1
{
  "firstName": "Fan",
  "lastName": "Guangrui",
  "mobile": null,
  "phone": null
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
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
PUT users/_doc/2
{
  "firstName": "Meng",
  "lastName": "Han"
}
{
  "_index" : "users",
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
GET users/_search
{
  "query": {
    "match": {
      "mobile": "NULL"
    }
  }
}
{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "users",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "firstName" : "Fan",
          "lastName" : "Guangrui",
          "mobile" : null,
          "phone" : null
        }
      }
    ]
  }
}

DELETE users
PUT users
{
  "mappings": {
    "properties": {
      "firstName" : {
        "type": "text",
        "copy_to": "{fullName}"
      },
      "lastName" : {
        "type": "text",
        "copy_to": "{fullName}"
      }
    }
  }
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "users"
}

PUT users/_doc/1
{
  "firstName": "Fan",
  "lastName": "Guangrui"
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
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
GET users/_search?q=fullName:(Fan Guangrui)
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.5753642,
    "hits" : [
      {
        "_index" : "users",
        "_id" : "1",
        "_score" : 0.5753642,
        "_source" : {
          "firstName" : "Fan",
          "lastName" : "Guangrui"
        }
      }
    ]
  }
}

POST users/_search
{
  "query": {
    "match": {
      "fullName": {
        "query": "Fan Guangrui",
        "operator": "and"
      }
    }
  }
}
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.5753642,
    "hits" : [
      {
        "_index" : "users",
        "_id" : "1",
        "_score" : 0.5753642,
        "_source" : {
          "firstName" : "Fan",
          "lastName" : "Guangrui"
        }
      }
    ]
  }
}

PUT users/_doc/1
{
  "name": "MengHan",
  "interests": "shoping"
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 1,
  "_primary_term" : 1
}
PUT users/_doc/1
{
  "name": "ChengLong",
  "interests": ["shoping","music"]
}
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 3,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 2,
  "_primary_term" : 1
}
POST users/_search
{
  "query": {
    "match_all": {}
  }
}
{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "users",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "ChengLong",
          "interests" : [
            "shoping",
            "music"
          ]
        }
      }
    ]
  }
}
GET users/_mapping
{
  "users" : {
    "mappings" : {
      "dynamic_templates" : [
        {
          "message_full" : {
            "match" : "message_full",
            "mapping" : {
              "fields" : {
                "keyword" : {
                  "ignore_above" : 2048,
                  "type" : "keyword"
                }
              },
              "type" : "text"
            }
          }
        },
        {
          "message" : {
            "match" : "message",
            "mapping" : {
              "type" : "text"
            }
          }
        },
        {
          "strings" : {
            "match_mapping_type" : "string",
            "mapping" : {
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "firstName" : {
          "type" : "text",
          "copy_to" : [
            "fullName"
          ]
        },
        "fullName" : {
          "type" : "keyword"
        },
        "interests" : {
          "type" : "keyword"
        },
        "lastName" : {
          "type" : "text",
          "copy_to" : [
            "fullName"
          ]
        },
        "name" : {
          "type" : "keyword"
        }
      }
    }
  }
}


POST _analyze
{
  "tokenizer": "keyword",
  "char_filter": ["html_strip"],
  "text": ["<b>hello elasticsearch</b>"]
}
{
  "tokens" : [
    {
      "token" : "hello elasticsearch",
      "start_offset" : 3,
      "end_offset" : 26,
      "type" : "word",
      "position" : 0
    }
  ]
}

POST _analyze
{
  "tokenizer": "standard",
  "char_filter": [
    {
      "type": "mapping",
      "mappings": ["- => _"]
    }
  ],
  "text": ["123-456, I-test! test-990 650-555-1234"]
}
{
  "tokens" : [
    {
      "token" : "123_456",
      "start_offset" : 0,
      "end_offset" : 7,
      "type" : "<NUM>",
      "position" : 0
    },
    {
      "token" : "I_test",
      "start_offset" : 9,
      "end_offset" : 15,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "test_990",
      "start_offset" : 17,
      "end_offset" : 25,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "650_555_1234",
      "start_offset" : 26,
      "end_offset" : 38,
      "type" : "<NUM>",
      "position" : 3
    }
  ]
}

POST _analyze
{
  "tokenizer": "standard",
  "char_filter": [
    {
      "type": "mapping",
      "mappings": [":) => happy",":( => sad"]
    }
  ],
  "text": ["I an felling :)","Felling :( today"]
}

{
  "tokens" : [
    {
      "token" : "I",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "an",
      "start_offset" : 2,
      "end_offset" : 4,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "felling",
      "start_offset" : 5,
      "end_offset" : 12,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "happy",
      "start_offset" : 13,
      "end_offset" : 15,
      "type" : "<ALPHANUM>",
      "position" : 3
    },
    {
      "token" : "Felling",
      "start_offset" : 16,
      "end_offset" : 23,
      "type" : "<ALPHANUM>",
      "position" : 104
    },
    {
      "token" : "sad",
      "start_offset" : 24,
      "end_offset" : 26,
      "type" : "<ALPHANUM>",
      "position" : 105
    },
    {
      "token" : "today",
      "start_offset" : 27,
      "end_offset" : 32,
      "type" : "<ALPHANUM>",
      "position" : 106
    }
  ]
}

GET _analyze
{
  "tokenizer": "standard",
  "char_filter": [
    {
      "type": "pattern_replace",
      "pattern": "http://(.*)",
      "replacement": "$1"
    }  
  ],
  "text": ["http://www.elastic.co"]
}
{
  "tokens" : [
    {
      "token" : "www.elastic.co",
      "start_offset" : 0,
      "end_offset" : 21,
      "type" : "<ALPHANUM>",
      "position" : 0
    }
  ]
}

POST _analyze
{
  "tokenizer": "path_hierarchy",
  "text": "/user/fgrapp/a/b/c/d/e"
}
{
  "tokens" : [
    {
      "token" : "/user",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp",
      "start_offset" : 0,
      "end_offset" : 12,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp/a",
      "start_offset" : 0,
      "end_offset" : 14,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp/a/b",
      "start_offset" : 0,
      "end_offset" : 16,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp/a/b/c",
      "start_offset" : 0,
      "end_offset" : 18,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp/a/b/c/d",
      "start_offset" : 0,
      "end_offset" : 20,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "/user/fgrapp/a/b/c/d/e",
      "start_offset" : 0,
      "end_offset" : 22,
      "type" : "word",
      "position" : 0
    }
  ]
}

```
```