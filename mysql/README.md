# MySQL 开发环境

这是一个基于 Docker Compose 的 MySQL 开发环境配置，使用 MySQL 8.0 版本。

## 环境要求

- Docker
- Docker Compose

## 目录结构

```
mysql/
├── docker-compose.yml    # Docker Compose 配置文件
├── README.md            # 本文档
├── data/               # MySQL 数据目录
├── conf/               # MySQL 配置文件目录
└── logs/               # MySQL 日志目录
```

## 服务说明

### MySQL
- 版本：8.0
- 端口：3306
- 主要配置：
  - 字符集：utf8mb4
  - 排序规则：utf8mb4_unicode_ci
  - 认证方式：mysql_native_password
  - 自动重启：unless-stopped

## 快速开始

### 1. 启动服务

```bash
# 创建必要的目录
mkdir -p data conf logs

# 设置目录权限
chmod 777 data conf logs

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

### 3. 连接数据库

```bash
# 使用命令行连接
mysql -h localhost -P 3306 -u dev_user -pdev123 dev_db

# 或使用其他 MySQL 客户端工具连接
# 主机：localhost
# 端口：3306
# 用户名：dev_user
# 密码：dev123
# 数据库：dev_db
```

## 用户信息

### 普通用户
- 用户名：dev_user
- 密码：dev123
- 默认数据库：dev_db

### 管理员用户
- 用户名：root
- 密码：root123

## 配置说明

### 环境变量
- `MYSQL_ROOT_PASSWORD=root123`：root 用户密码
- `MYSQL_DATABASE=dev_db`：默认数据库名
- `MYSQL_USER=dev_user`：普通用户名
- `MYSQL_PASSWORD=dev123`：普通用户密码

### 数据持久化
- 数据文件：`./data:/var/lib/mysql`
- 配置文件：`./conf:/etc/mysql/conf.d`
- 日志文件：`./logs:/var/log/mysql`

### 网络配置
- 使用独立的 `mysql_network` 网络
- 端口映射：3306:3306

## 常用操作

### 创建新数据库

```sql
CREATE DATABASE new_database;
```

### 创建新用户

```sql
CREATE USER 'new_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database_name.* TO 'new_user'@'%';
FLUSH PRIVILEGES;
```

### 导入数据

```bash
# 进入容器
docker exec -it mysql_dev bash

# 导入 SQL 文件
mysql -u dev_user -pdev123 dev_db < /path/to/your/file.sql
```

### 导出数据

```bash
# 进入容器
docker exec -it mysql_dev bash

# 导出数据库
mysqldump -u dev_user -pdev123 dev_db > /path/to/backup.sql
```

## 故障排除

1. 如果遇到权限问题：
   ```bash
   chmod 777 data conf logs
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
   rm -rf data conf logs
   
   # 重新创建目录并启动服务
   mkdir data conf logs
   chmod 777 data conf logs
   docker-compose up -d
   ```

## 注意事项

1. 这是一个开发环境配置，不建议用于生产环境
2. 数据持久化存储在本地目录中
3. 默认配置适合开发和测试使用
4. 生产环境需要根据实际需求调整配置参数
5. 建议定期备份数据目录 