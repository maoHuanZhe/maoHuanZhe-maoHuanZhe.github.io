---
title: Elasticsearch系列之分词
date: 2022-04-02 14:55
abbrlink: 727bbf74
permalink: /pages/6e238e/
categories: 
  - Elasticsearch
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## Analysis 与 Analyzer
- Analysis:文本分析是把全文本转换为一系列单词(term/token)的过程，也叫分词
- Analysis 是通过 Analyzer 来实现的，可使用 Elasticsearch 内置的分析器/或者按需定制化分析器
- 除了在数据写入时转换词条，匹配 Query 语句时候也需要用相同的分析器对查询语句进行分析
## Analyzer 的组成
- 分词器时专门处理分词的组件
    - Character Filter:针对原始文本处理，例如去除 html
    - Tokenizer:按照规则切分为单词
    - Token Filter:将切分的单词进行加工，小写，删除 stopwords，增加同义词
## Elasticsearch 的内置分词器
- Standard Analyzer:默认分词器，按词切分，小写处理
- Simple Analyzer:按照非字母切分(符号被过滤)，小写处理
- Stop Analyzer:小写处理，停用词过滤(the，a，is)
- Whitespace Analyzer:按照空格切分，不转小写
- Keyword Analyzer:不分词，直接将输入当作输出
- Patter Analyzer:正则表达式，默认\W+(非字符分隔)
- Language:提供了 30 多种常见语言的分词器
- Customer Analyzer:自定义分词器
## 使用_analyzer API
- 直接指定 Analyzer 进行测试
- 指定索引的字段进行测试
- 自定义分词器进行测试
## Standard Analyzer
默认分词器，按词切分，小写处理
```
GET _analyze
{
  "analyzer": "standard",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening"
}
{
  "tokens" : [
    {
      "token" : "2",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "<NUM>",
      "position" : 0
    },
    {
      "token" : "running",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "brown",
      "start_offset" : 16,
      "end_offset" : 21,
      "type" : "<ALPHANUM>",
      "position" : 3
    },
    {
      "token" : "foxes",
      "start_offset" : 22,
      "end_offset" : 27,
      "type" : "<ALPHANUM>",
      "position" : 4
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "<ALPHANUM>",
      "position" : 5
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "<ALPHANUM>",
      "position" : 6
    },
    {
      "token" : "lazy",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "<ALPHANUM>",
      "position" : 7
    },
    {
      "token" : "dogs",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "<ALPHANUM>",
      "position" : 8
    },
    {
      "token" : "in",
      "start_offset" : 48,
      "end_offset" : 50,
      "type" : "<ALPHANUM>",
      "position" : 9
    },
    {
      "token" : "the",
      "start_offset" : 51,
      "end_offset" : 54,
      "type" : "<ALPHANUM>",
      "position" : 10
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "<ALPHANUM>",
      "position" : 11
    },
    {
      "token" : "evening",
      "start_offset" : 62,
      "end_offset" : 69,
      "type" : "<ALPHANUM>",
      "position" : 12
    }
  ]
}
```
## Simple Analyzer
按照非字母切分，非字母的都被去除，小写处理
```
GET _analyze
{
  "analyzer": "simple",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "running",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "brown",
      "start_offset" : 16,
      "end_offset" : 21,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "foxes",
      "start_offset" : 22,
      "end_offset" : 27,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "lazy",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "dogs",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "in",
      "start_offset" : 48,
      "end_offset" : 50,
      "type" : "word",
      "position" : 8
    },
    {
      "token" : "the",
      "start_offset" : 51,
      "end_offset" : 54,
      "type" : "word",
      "position" : 9
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "word",
      "position" : 10
    },
    {
      "token" : "evening",
      "start_offset" : 62,
      "end_offset" : 69,
      "type" : "word",
      "position" : 11
    }
  ]
}
```
## Whitespace Analyzer
按照空格切分
```
GET _analyze
{
  "analyzer": "whitespace",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "2",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "running",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "Quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "brown-foxes",
      "start_offset" : 16,
      "end_offset" : 27,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "lazy",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "dogs",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "in",
      "start_offset" : 48,
      "end_offset" : 50,
      "type" : "word",
      "position" : 8
    },
    {
      "token" : "the",
      "start_offset" : 51,
      "end_offset" : 54,
      "type" : "word",
      "position" : 9
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "word",
      "position" : 10
    },
    {
      "token" : "evening.",
      "start_offset" : 62,
      "end_offset" : 70,
      "type" : "word",
      "position" : 11
    }
  ]
}
```
## Stop Analyzer
相比 Simple Analyzer 多了 stop fileter，会把 the，a，is 等修饰词语去除
```
GET _analyze
{
  "analyzer": "stop",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "running",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "brown",
      "start_offset" : 16,
      "end_offset" : 21,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "foxes",
      "start_offset" : 22,
      "end_offset" : 27,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "lazy",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "dogs",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "word",
      "position" : 10
    },
    {
      "token" : "evening",
      "start_offset" : 62,
      "end_offset" : 69,
      "type" : "word",
      "position" : 11
    }
  ]
}
```
## Keyword Analyzer
不分词，直接将输入当一个 term 输出
```
GET _analyze
{
  "analyzer": "keyword",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "2 running Quick brown-foxes leap over lazy dogs in the summer evening.",
      "start_offset" : 0,
      "end_offset" : 70,
      "type" : "word",
      "position" : 0
    }
  ]
}
```
## Pattern Analyzer
通过正则表达式进行分词，默认是\W+，非字符的符号进行分隔
```
GET _analyze
{
  "analyzer": "pattern",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "2",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "running",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "brown",
      "start_offset" : 16,
      "end_offset" : 21,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "foxes",
      "start_offset" : 22,
      "end_offset" : 27,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "lazy",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "dogs",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "word",
      "position" : 8
    },
    {
      "token" : "in",
      "start_offset" : 48,
      "end_offset" : 50,
      "type" : "word",
      "position" : 9
    },
    {
      "token" : "the",
      "start_offset" : 51,
      "end_offset" : 54,
      "type" : "word",
      "position" : 10
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "word",
      "position" : 11
    },
    {
      "token" : "evening",
      "start_offset" : 62,
      "end_offset" : 69,
      "type" : "word",
      "position" : 12
    }
  ]
}
```
## Language Analyzer
```
GET _analyze
{
  "analyzer": "english",
  "text": "2 running Quick brown-foxes leap over lazy dogs in the summer evening."
}
{
  "tokens" : [
    {
      "token" : "2",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "<NUM>",
      "position" : 0
    },
    {
      "token" : "run",
      "start_offset" : 2,
      "end_offset" : 9,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "quick",
      "start_offset" : 10,
      "end_offset" : 15,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "brown",
      "start_offset" : 16,
      "end_offset" : 21,
      "type" : "<ALPHANUM>",
      "position" : 3
    },
    {
      "token" : "fox",
      "start_offset" : 22,
      "end_offset" : 27,
      "type" : "<ALPHANUM>",
      "position" : 4
    },
    {
      "token" : "leap",
      "start_offset" : 28,
      "end_offset" : 32,
      "type" : "<ALPHANUM>",
      "position" : 5
    },
    {
      "token" : "over",
      "start_offset" : 33,
      "end_offset" : 37,
      "type" : "<ALPHANUM>",
      "position" : 6
    },
    {
      "token" : "lazi",
      "start_offset" : 38,
      "end_offset" : 42,
      "type" : "<ALPHANUM>",
      "position" : 7
    },
    {
      "token" : "dog",
      "start_offset" : 43,
      "end_offset" : 47,
      "type" : "<ALPHANUM>",
      "position" : 8
    },
    {
      "token" : "summer",
      "start_offset" : 55,
      "end_offset" : 61,
      "type" : "<ALPHANUM>",
      "position" : 11
    },
    {
      "token" : "even",
      "start_offset" : 62,
      "end_offset" : 69,
      "type" : "<ALPHANUM>",
      "position" : 12
    }
  ]
}
```
## 中文分词的难点
- 中文句子，切分成一个一个词(不是一个一个字)
- 英文中，单词有自然的空格作为分隔
- 一句中文，在不同的上下文有不同的理解
    - 这个苹果，不大好吃/这个苹果，不大，好吃！
- 一些例子
    - 他说的确实在理
    - 这事的确定不下来
## ICU Analyzer
需要安装 plugin:Elasticsearch-plugin install analysis-icu
提供了 Unicode 的支持，更好的支持亚洲语言

```
GET _analyze
{
  "analyzer": "standard",
  "text": "他说的确实在理"
}
GET _analyze
{
  "analyzer": "icu_analyzer",
  "text": "他说的确实在理"
}
```