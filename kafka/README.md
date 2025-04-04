# Kafka 开发环境 (KRaft 模式)

## 环境说明

本配置使用 Kafka KRaft 模式，无需 Zookeeper 组件。

### 目录结构
```
kafka/
├── docker-compose.yml   # Docker 编排配置文件
├── kafka_data/         # Kafka 数据目录
└── README.md           # 说明文档
```

### 服务说明

#### Kafka
- 版本：4.0 (bitnami/kafka)
- 端口：
  - 9092 (PLAINTEXT，主机访问)
  - 9094 (EXTERNAL，容器间访问)
- 配置特点：
  - KRaft 模式运行（无 Zookeeper）
  - 节点 ID：1
- 监听器配置：
  - PLAINTEXT://:9092
  - CONTROLLER://:9093
  - EXTERNAL://:9094
- 广告监听器：
  - PLAINTEXT://localhost:9092
  - EXTERNAL://kafka_1:9094
  - 角色：controller + broker
  - 自动创建主题：启用
  - 删除主题：启用
  - 默认分区数：3
  - 默认副本因子：1
  - 内存配置：最小 256M，最大 512M

#### Kafdrop
- 版本：3.30.0
- 端口：9000
- Web 管理界面：http://localhost:9000
- Kafka Broker 连接：kafka_1:9094
- 内存配置：最小 32M，最大 64M

## 快速开始

### 1. 准备工作
```bash
# 创建数据目录
mkdir -p kafka_data

# 设置目录权限
chmod 777 kafka_data
```

### 2. 启动服务
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f
```

### 3. 访问服务
- Kafdrop 管理界面：http://localhost:9000

## 常用操作

### 主题管理
```bash
# 进入 Kafka 容器
docker exec -it kafka bash

# 创建主题
kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 查看主题列表
kafka-topics.sh --list --bootstrap-server localhost:9092

# 查看主题详情
kafka-topics.sh --describe --topic my-topic --bootstrap-server localhost:9092
```

### 消息操作
```bash
# 发送消息
kafka-console-producer.sh --topic my-topic --bootstrap-server localhost:9092

# 消费消息
kafka-console-consumer.sh --topic my-topic --from-beginning --bootstrap-server localhost:9092
```

## 环境重置
```bash
# 停止并删除所有容器和卷
docker-compose down -v

# 删除数据目录
rm -rf kafka_data

# 重新创建目录
mkdir kafka_data
chmod 777 kafka_data

# 重新启动服务
docker-compose up -d
```

## 故障排查

1. 如果 Kafdrop 无法连接到 Kafka：
   - 检查网络连接：`docker exec -it kafdrop ping kafka`
   - 检查 Kafka 状态：`docker exec -it kafka kafka-topics.sh --list --bootstrap-server localhost:9092`
   - 查看服务日志：`docker-compose logs -f`

2. 如果 Kafka 启动失败：
   - 检查数据目录权限
   - 检查端口占用情况
   - 查看详细日志：`docker-compose logs kafka`

## 配置说明

### Kafka 配置参数
- `KAFKA_CFG_NODE_ID=1`：节点 ID
- `KAFKA_CFG_PROCESS_ROLES=controller,broker`：进程角色
- `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=1@kafka:9093`：控制器选民配置
- `KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093`：监听器配置
- `KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092`：广播地址
- `KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true`：允许自动创建主题
- `KAFKA_CFG_DELETE_TOPIC_ENABLE=true`：允许删除主题
- `KAFKA_CFG_NUM_PARTITIONS=3`：默认分区数
- `KAFKA_CFG_DEFAULT_REPLICATION_FACTOR=1`：默认复制因子
- `KAFKA_HEAP_OPTS=-Xmx512M -Xms256M`：JVM 内存配置

### Kafdrop 配置参数
- `KAFKA_BROKERCONNECT=kafka:9092`：Kafka 连接地址
- `JVM_OPTS=-Xms32M -Xmx64M`：JVM 内存配置
- `SERVER_SERVLET_CONTEXTPATH=/`：Web 上下文路径

## 注意事项

1. 这是一个开发环境配置，不建议用于生产环境
2. 使用了 KRaft 模式，不需要 Zookeeper
3. 数据持久化存储在本地目录中
4. 默认配置适合开发和测试使用
5. 生产环境需要根据实际需求调整配置参数
6. 建议定期备份数据目录
7. 如果需要外部访问，确保防火墙允许相应端口