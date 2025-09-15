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
  - 认证方式：caching_sha2_password（MySQL 8.0 默认）
  - 自动重启：unless-stopped
  - 最大数据包：128MB
  - InnoDB 缓冲池：256MB
  - 时间戳模式：严格模式

## 快速开始

### 1. 启动服务

```bash
# 启动服务（Docker 卷会自动创建）
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
# 使用 root 用户连接
mysql -h localhost -P 3306 -u root -p

# 或使用普通用户连接
mysql -h localhost -P 3306 -u dev_user -p
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
- `MYSQL_ROOT_HOST=%`：允许从任何主机连接 root 用户

### 数据持久化
使用 Docker 卷进行数据持久化，避免本地目录依赖：
- 数据文件：`mysql_01_data:/var/lib/mysql`
- 配置文件：`mysql_01_conf:/etc/mysql/conf.d`
- 日志文件：`mysql_01_logs:/var/log/mysql`
- 初始化脚本：`./init-scripts:/docker-entrypoint-initdb.d`

Docker 卷的优势：
- 数据完全由 Docker 管理，不依赖本地目录结构
- 更好的跨平台兼容性
- 自动处理权限问题
- 便于备份和迁移

### 数据库初始化
项目包含了完整的测试数据初始化脚本 `init-scripts/01-init-test-data.sql`，包含：
- **经典业务表结构**：用户、商品分类、商品、订单、订单详情、购物车等
- **测试数据**：预置了用户、商品、订单等测试数据
- **数据库视图**：订单统计、库存预警、用户购买统计等实用视图
- **存储过程**：购物车总金额计算、库存更新等
- **触发器**：订单创建自动减库存
- **函数**：订单折扣计算
- **系统配置表**：网站配置参数

首次启动容器时，MySQL会自动执行 `init-scripts` 目录下的所有 `.sql` 文件。

### MySQL 配置参数
- `character-set-server=utf8mb4`：使用 UTF8MB4 字符集
- `collation-server=utf8mb4_unicode_ci`：使用 Unicode 排序规则
- `default-authentication-plugin=caching_sha2_password`：使用 MySQL 8.0 默认认证方式
- `explicit_defaults_for_timestamp=1`：启用严格的时间戳模式
- `max_allowed_packet=128M`：最大允许的数据包大小
- `innodb_buffer_pool_size=256M`：InnoDB 缓冲池大小

### 网络配置
- 使用独立的 `mysql_network` 网络
- 端口映射：3306:3306

## 测试数据说明

### 预置表结构

1. **users** - 用户表
   - 包含用户基本信息：用户名、邮箱、密码、手机号等
   - 预置5个测试用户（admin, john_doe, jane_smith, bob_wilson, alice_brown）

2. **categories** - 商品分类表
   - 支持多级分类结构
   - 预置电子产品、服装鞋帽、家居用品等分类

3. **products** - 商品表
   - 完整的商品信息：名称、SKU、价格、库存、重量等
   - 预置10个测试商品（iPhone、MacBook、Nike鞋等）

4. **orders** - 订单表
   - 订单状态管理、支付信息、地址信息
   - 预置5个不同状态的测试订单

5. **order_items** - 订单详情表
   - 订单商品明细信息

6. **shopping_cart** - 购物车表
   - 用户购物车商品管理

7. **system_config** - 系统配置表
   - 网站配置参数管理

### 预置视图

- **order_summary** - 订单汇总视图
- **low_stock_products** - 低库存商品预警视图  
- **user_purchase_stats** - 用户购买统计视图

### 预置存储过程

- **GetCartTotal** - 计算用户购物车总金额
- **UpdateProductStock** - 安全更新商品库存

### 预置函数

- **CalculateDiscount** - 根据订单金额计算折扣

### 测试查询示例

```sql
-- 查看所有用户
SELECT * FROM users;

-- 查看商品库存情况
SELECT * FROM low_stock_products;

-- 查看订单统计
SELECT * FROM order_summary;

-- 查看用户购买统计
SELECT * FROM user_purchase_stats;

-- 调用存储过程计算购物车总额
CALL GetCartTotal(2, @total);
SELECT @total as cart_total;

-- 使用函数计算折扣
SELECT CalculateDiscount(5000) as discount_amount;
```

## 常用操作

### 创建新数据库

```sql
CREATE DATABASE new_database;
```

### 创建新用户

```sql
CREATE USER 'new_user'@'%' IDENTIFIED WITH caching_sha2_password BY 'password';
GRANT ALL PRIVILEGES ON database_name.* TO 'new_user'@'%';
FLUSH PRIVILEGES;
```

### 修改认证方式
如果使用旧版本客户端工具连接遇到认证问题，可以执行：

```sql
ALTER USER 'dev_user'@'%' IDENTIFIED WITH mysql_native_password BY 'dev123';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root123';
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

1. 如果需要查看 Docker 卷信息：
   ```bash
   # 查看所有卷
   docker volume ls
   
   # 查看特定卷的详细信息
   docker volume inspect mysql_mysql_01_data
   docker volume inspect mysql_mysql_01_conf
   docker volume inspect mysql_mysql_01_logs
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
   
   # 重新启动服务（卷会自动重新创建）
   docker-compose up -d
   ```

4. 备份和恢复数据：
   ```bash
   # 备份数据卷
   docker run --rm -v mysql_mysql_01_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz -C /data .
   
   # 恢复数据卷
   docker run --rm -v mysql_mysql_01_data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql_backup.tar.gz -C /data
   ```

## 注意事项

1. 这是一个开发环境配置，不建议用于生产环境
2. 数据使用 Docker 卷进行持久化存储，由 Docker 统一管理
3. 默认配置适合开发和测试使用
4. 生产环境需要根据实际需求调整配置参数
5. 建议定期备份 Docker 卷数据
6. MySQL 8.0 默认使用 caching_sha2_password 认证方式，某些旧版本客户端可能需要修改认证方式
7. Docker 卷数据在容器删除后仍会保留，除非使用 `docker-compose down -v` 强制删除