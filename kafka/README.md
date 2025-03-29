# Kafka 开发环境

这是一个基于 Docker Compose 的 Kafka 开发环境配置，包含了 Kafka、Zookeeper 和 Kafdrop 管理工具。

## 环境要求

- Docker
- Docker Compose

## 目录结构

```
kafka/
├── docker-compose.yml    # Docker Compose 配置文件
├── README.md            # 本文档
├── zookeeper_data/      # Zookeeper 数据目录
├── kafka_data/         # Kafka 数据目录
└── kafka_logs/         # Kafka 日志目录
```

## 服务说明

### 1. Kafka
- 版本：3.5.1
- 端口：9092
- 主要配置：
  - 自动创建主题
  - 允许删除主题
  - 默认分区数：3
  - 复制因子：1
  - 日志保留时间：168小时
  - JVM 内存：最大 512MB，初始 256MB

### 2. Zookeeper
- 版本：3.8.1
- 端口：2181
- 配置：
  - 允许匿名登录
  - 单节点模式

### 3. Kafdrop
- 版本：3.30.0
- 端口：9000
- 功能：Kafka 集群的可视化管理工具

## 快速开始

### 1. 启动服务

```bash
# 创建必要的目录
mkdir -p zookeeper_data kafka_data kafka_logs

# 设置目录权限
chmod 777 zookeeper_data kafka_data kafka_logs

# 启动服务
docker-compose up -d
```

### 2. 验证服务状态

```bash
# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f
```

### 3. 访问管理界面

打开浏览器访问：http://localhost:9000

## 常用操作

### 创建主题

```bash
# 进入 Kafka 容器
docker exec -it kafka_01 bash

# 创建主题
kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
```

### 查看主题列表

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

### 发送消息

```bash
# 进入 Kafka 容器
docker exec -it kafka_01 bash

# 发送消息
kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic
```

### 接收消息

```bash
# 进入 Kafka 容器
docker exec -it kafka_01 bash

# 接收消息
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```

## 配置说明

### Kafka 主要配置参数

- `KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true`：允许自动创建主题
- `KAFKA_CFG_DELETE_TOPIC_ENABLE=true`：允许删除主题
- `KAFKA_CFG_NUM_PARTITIONS=3`：默认分区数
- `KAFKA_CFG_DEFAULT_REPLICATION_FACTOR=1`：默认复制因子
- `KAFKA_CFG_LOG_RETENTION_HOURS=168`：日志保留时间（7天）
- `KAFKA_HEAP_OPTS=-Xmx512M -Xms256M`：JVM 内存配置

### Zookeeper 配置

- `ALLOW_ANONYMOUS_LOGIN=yes`：允许匿名登录
- `ZOO_SERVER_ID=1`：服务器 ID
- `ZOO_SERVERS=server.1=zookeeper:2888:3888`：服务器配置

## 故障排除

1. 如果遇到权限问题：
   ```bash
   chmod 777 zookeeper_data kafka_data kafka_logs
   ```

2. 如果服务无法启动：
   ```bash
   # 查看详细日志
   docker-compose logs -f
   
   # 重启服务
   docker-compose restart
   ```

3. 如果需要完全重置：
   ```bash
   # 停止并删除所有容器和卷
   docker-compose down -v
   
   # 删除数据目录
   rm -rf zookeeper_data kafka_data kafka_logs
   
   # 重新创建目录并启动服务
   mkdir zookeeper_data kafka_data kafka_logs
   chmod 777 zookeeper_data kafka_data kafka_logs
   docker-compose up -d
   ```

## 注意事项

1. 这是一个开发环境配置，不建议用于生产环境
2. 数据持久化存储在本地目录中
3. 默认配置适合开发和测试使用
4. 生产环境需要根据实际需求调整配置参数 