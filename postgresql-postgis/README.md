# PostgreSQL + PostGIS 开发环境

这是一个使用 Docker Compose 配置的 PostgreSQL + PostGIS 开发环境，采用单一数据库实例 + PostGIS 扩展的部署方式，这是生产环境中最常见和推荐的配置。

## 环境要求

- Docker
- Docker Compose

## 目录结构

```
postgresql-postgis/
├── docker-compose.yml    # Docker Compose 配置文件
└── README.md            # 本文档
```

## 服务组件

### PostgreSQL + PostGIS 数据库
- **镜像**: postgis/postgis:16-3.4（PostgreSQL 16 + PostGIS 3.4）
- **容器名**: postgresql_postgis
- **端口**: 5432
- **主要数据库**:
  - `postgres`: 默认数据库
  - `testdb`: 普通业务数据库（包含测试数据）
  - `gisdb`: PostGIS空间数据库（包含空间测试数据）
- **用户**:
  - `postgres/postgres`: 超级用户
  - `testuser/testpass`: 普通数据库专用用户
  - `gisuser/gispass`: PostGIS数据库专用用户

#### 主要特性
- 预装PostGIS空间数据库扩展
- 优化的PostgreSQL配置参数
- 数据持久化存储
- 自动重启策略

#### 性能优化配置
- 最大连接数: 200
- 共享缓冲区: 256MB
- 有效缓存大小: 1GB
- 维护工作内存: 64MB
- 工作内存: 4MB
- WAL缓冲区: 16MB



## 快速开始

### 1. 启动服务

```bash
# 进入目录
cd postgresql-postgis

# 启动服务
docker-compose up -d
```

### 2. 验证服务状态

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs postgresql-postgis
```

### 3. 连接数据库

#### 连接默认数据库
```bash
# 使用容器内连接
docker-compose exec postgresql-postgis psql -U postgres -d postgres

# 或者从主机直接连接
psql -h localhost -p 5432 -U postgres -d postgres
```

#### 连接普通业务数据库
```bash
# 使用容器内连接（超级用户）
docker-compose exec postgresql-postgis psql -U postgres -d testdb

# 使用容器内连接（专用用户）
docker-compose exec postgresql-postgis psql -U testuser -d testdb

# 或者从主机直接连接
psql -h localhost -p 5432 -U testuser -d testdb
```

#### 连接PostGIS空间数据库
```bash
# 使用容器内连接（超级用户）
docker-compose exec postgresql-postgis psql -U postgres -d gisdb

# 使用容器内连接（专用用户）
docker-compose exec postgresql-postgis psql -U gisuser -d gisdb

# 或者从主机直接连接
psql -h localhost -p 5432 -U gisuser -d gisdb
```

#### 使用Navicat连接

使用Navicat连接PostgreSQL数据库：
1. 新建连接 → PostgreSQL
2. 连接设置：
   - 主机：localhost
   - 端口：5432
   - 用户名：postgres
   - 密码：postgres
   - 数据库：postgres（或testdb、gisdb）
3. 测试连接成功后即可管理所有数据库

连接后可以看到三个数据库：postgres、testdb（包含测试数据）和 gisdb（PostGIS空间数据库）

### 4. 验证PostGIS扩展

连接到gisdb数据库后，运行以下命令验证扩展：

```bash
# 连接到空间数据库
docker exec -it postgresql_postgis psql -U postgres -d gisdb
```

```sql
-- 检查PostGIS版本
SELECT PostGIS_Version();

-- 检查已安装的扩展
\dx

-- 创建PostGIS扩展（如果尚未创建）
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- 创建一个简单的空间表进行测试
CREATE TABLE test_points (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(POINT, 4326)
);

-- 插入测试数据
INSERT INTO test_points (name, geom) 
VALUES ('Test Point', ST_GeomFromText('POINT(-74.0059 40.7128)', 4326));

-- 查询测试数据
SELECT id, name, ST_AsText(geom) FROM test_points;

-- 验证空间功能
SELECT ST_AsText(ST_MakePoint(-71.060316, 42.358431));
```

## 测试数据说明

### 普通业务数据库（testdb）

包含完整的电商业务测试数据：

#### 数据表结构
- **users**: 用户表（5个测试用户）
- **categories**: 商品分类表（主分类和子分类）
- **products**: 商品表（8个测试商品）
- **orders**: 订单表（5个测试订单）
- **order_items**: 订单项表（订单详情）

#### 测试查询示例
```sql
-- 连接到testdb数据库
\c testdb

-- 查看所有用户
SELECT * FROM users;

-- 查看商品及其分类
SELECT p.name, p.price, c.name as category 
FROM products p 
JOIN categories c ON p.category_id = c.id;

-- 查看用户订单统计
SELECT u.username, COUNT(o.id) as order_count, SUM(o.total_amount) as total_spent
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.id, u.username;

-- 查看热销商品
SELECT p.name, SUM(oi.quantity) as total_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_sold DESC;
```

### PostGIS空间数据库（gisdb）

包含丰富的地理空间测试数据：

#### 空间数据表
- **cities**: 世界主要城市（点数据，8个城市）
- **roads**: 著名道路（线数据，4条道路）
- **districts**: 行政区域（面数据，4个区域）
- **points_of_interest**: 兴趣点（POI，8个著名景点）

#### 空间查询示例
```sql
-- 连接到gisdb数据库
\c gisdb

-- 查看所有城市
SELECT name, country, population, ST_AsText(geom) as coordinates FROM cities;

-- 查找距离北京最近的3个城市
SELECT name, country, 
       ST_Distance(geom, (SELECT geom FROM cities WHERE name = '北京')) as distance
FROM cities 
WHERE name != '北京'
ORDER BY distance LIMIT 3;

-- 查找指定区域内的兴趣点
SELECT poi.name, poi.category, poi.address
FROM points_of_interest poi, districts d
WHERE d.name = '朝阳区' AND ST_Within(poi.geom, d.geom);

-- 计算道路长度统计
SELECT road_type, COUNT(*) as count, 
       ROUND(AVG(length_km)::numeric, 2) as avg_length,
       ROUND(SUM(length_km)::numeric, 2) as total_length
FROM roads 
GROUP BY road_type;

-- 空间缓冲区查询（查找城市周围10公里内的兴趣点）
SELECT c.name as city, poi.name as poi_name, poi.category
FROM cities c, points_of_interest poi
WHERE ST_DWithin(c.geom::geography, poi.geom::geography, 10000)
ORDER BY c.name, poi.name;
```

### 性能优化

两个数据库都已创建了适当的索引：
- **普通索引**: 用于常规字段查询优化
- **空间索引**: 使用GiST索引优化空间查询性能
- **唯一索引**: 保证数据完整性

## 数据管理

### 备份数据库
```bash
# 备份普通业务数据库
docker exec postgresql_postgis pg_dump -U postgres testdb > testdb_backup.sql

# 备份PostGIS空间数据库
docker exec postgresql_postgis pg_dump -U postgres gisdb > gisdb_backup.sql

# 备份所有数据库
docker exec postgresql_postgis pg_dumpall -U postgres > all_databases_backup.sql
```

### 恢复数据库
```bash
# 恢复普通业务数据库
docker exec -i postgresql_postgis psql -U postgres testdb < testdb_backup.sql

# 恢复PostGIS空间数据库
docker exec -i postgresql_postgis psql -U postgres gisdb < gisdb_backup.sql

# 恢复所有数据库
docker exec -i postgresql_postgis psql -U postgres < all_databases_backup.sql
```

## 停止服务

```bash
# 停止服务
docker-compose down

# 停止服务并删除数据卷（谨慎使用）
docker-compose down -v
```

## 故障排除

### 常见问题

1. **连接被拒绝**
   - 确保容器正在运行：`docker-compose ps`
   - 检查端口是否被占用：`netstat -an | findstr 5432`

2. **PostGIS扩展未安装**
   ```sql
   -- 手动创建扩展
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```

3. **性能问题**
   - 根据实际内存调整shared_buffers和effective_cache_size
   - 监控连接数，避免超过max_connections限制

### 查看日志
```bash
# 查看数据库日志
docker logs postgresql_postgis
```

## 配置自定义

如需修改配置，可以编辑docker-compose.yml文件中的环境变量和命令参数，然后重新启动服务：

```bash
docker-compose down
docker-compose up -d
```

## 安全建议

1. 在生产环境中修改默认密码
2. 限制网络访问，仅允许必要的IP连接
3. 定期备份数据
4. 监控数据库性能和连接数
5. 及时更新镜像版本以获取安全补丁