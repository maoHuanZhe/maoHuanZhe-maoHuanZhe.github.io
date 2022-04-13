---
title: Elasticsearch系列之基本概念
date: 2022-03-31 14:51
abbrlink: 8b0efee
permalink: /pages/c1e610/
categories: 
  - Elasticsearch
tags: 
  - 
author: 
  name: xugaoyi
  link: https://github.com/xugaoyi
---
## 文档(Document)
- Elasticsearch 是面向文档的，文档是所有可搜索数据的最小单位
    - 日志文件中的日志项
    - 一本电影的具体信息/一张唱片的详细信息
    - MP3 播放器里的一首歌/一篇 PDF 文档中的具体内容
- 文档会被序列化成 JSON 格式，保存在 Elasticsearch 中
    - JSON 对象由字段组成
    - 每个字段都有对应的字段类型(字符串、数值、布尔、日期、二进制、范围类型)
- 每个文档都有一个 Unique ID
    - 可以自己指定 ID
    - 或者通过 Elasticsearch 自动生成
## JSON 文档
- 一篇文档包含了一系列的字段。类似数据库表中一条记录
- JSON 文档，格式灵活，不需要预先定义格式
    - 字段类型可以指定或者通过 Elasticsearch 自动推算
    - 支持数组
    - 支持嵌套
## 文档的元数据
- 元数据，用于标注文档的相关信息
- _index:文档所属的索引名
- _type:文档所属的类型名
- _id:文档的唯一 id
- _source:文档的原始 Json 数据
- _version:文档的版本信息
- _score:相关性打分
## 索引
- index:索引是文档的容器，是一类文档的结合
    - index 体现了逻辑空间的概念:每一个索引都有自己的 Mapping 定义，用于定义包含的文档的字段名和字段类型
    - Shard 体现了物理空间的概念:索引中的数据分散在 Shard 上
- 索引的 Mapping 与 Settings
    - Mapping 定义文档字段的类型
    - Setting 定义不同的数据分布
### 索引的不同语义
- 名词:一个 Elasticsearch 集群中，可以创建很多不同的索引
- 动词:保存一个文档到 Elasticsearch 的过程也叫索引(indexing)
```
-E cluster.name = fgrapp 指定集群名称
-E node.name=node1 指定节点名称
```
## Master- eligible nodes 和 Master Node
- 每个节点启动后，默认就是一个 Master eligible 节点
    - 可以设置 node.master: false 禁止
- Master- eligible 节点可以参加选主流程，成为 Master 节点
- 当第一个节点启动时候，它会将自己选举成 Master 节点
- 每个节点上都保存了集群的状态，只有 Master 节点才能修改集群的状态信息
    - 集群状态(Cluster State)，维护了一个集群中必要的信息
        - 所有的节点信息
        - 所有的索引和与其相关的 Mapping 与 Setting 信息
        - 分片的路由信息
    - 任意节点都能修改信息会导致数据的不一致性
## Data Node & Coordinating Node
- Date Node:可以保存数据的节点，负责保存分片数据，在数据扩展上起到了至关重要的作用
- Coordinating Node:负责接受 Client 的请求，将请求分发到合适的节点，最终把结果汇集到一起，每个节点默认都起到了 Coordinating Node 的职责
## 其他的节点类型
- Hot & Warm Node:不同硬件配置的 Data Node，用来实现 Hot & Warm 架构，降低集群部署的成本
- Machine Learning Node:负责跑机器学习的 Job，用来做异常测试
- Tribe Node:连接到不同的 Elasticsearch 集群，并支持将这些集群当成一个单独的集群处理
## 配置节点类型
- 开发环境中一个节点可以承担多种角色
- 生产环境中应该设置单一的角色的节点(dedicated node)
## 分片(Primary Shard & Replica Shard)
- 主分片，用以解决数据水平扩展的问题。通过主分片，可以将数据分布到集群内的所有节点之上
    - 一个分片是一个运行的 Lucene 的实例
    - 主分片数载索引创建时指定，后续不允许修改，除非 Reindex
- 副本，用以解决数据高可用的问题。副本是主分片的拷贝
    - 分本分片数，可以动态调整
    - 增加副本数，还可以在一定程度上提高服务的可用性(读取的吞吐量)
- 一个三节点的集群中，blogs 索引的分片分布情况
    - 增加一个节点或改大主分片数对系统的影响
## 分片的设定
- 对于生产环境中分片的设定，需要提前做好容量规划
    - 分片数设置过小
        - 导致后续无法增加节点实现水平扩展
        - 单个分片的数量太大，导致数据重新分配耗时
    - 分片数设置过大，7.0 开始，默认主分片设置成 1，解决了 over-sharding 的问题
        - 影响搜索结果的相关性打分，影响统计结果的准确性
        - 单个节点上过多的分片，会导致资源浪费，同时也会影响性能
## 查看集群的健康状态
```
GET _cluster/health
{
  "cluster_name" : "fgrapp",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 13,
  "active_shards" : 13,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
- green:主分片与副本都正常分配
- yellow:主分片全部正常分配，有副本分片未能正常分配
- red:有主分片未能分配
    - 例如:当服务器的磁盘容量超过 85% 时，去创建了一个新的索引。

