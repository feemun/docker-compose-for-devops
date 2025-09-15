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
  - `maindb`: 业务数据库
  - `gisdb`: 空间数据库（已启用PostGIS扩展）
- **用户**:
  - `postgres/postgres`: 超级用户
  - `gisuser/gispassword`: 空间数据库专用用户

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

#### 连接业务数据库
```bash
# 使用容器内连接
docker-compose exec postgresql-postgis psql -U postgres -d maindb

# 或者从主机直接连接
psql -h localhost -p 5432 -U postgres -d maindb
```

#### 连接空间数据库
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
   - 数据库：postgres（或maindb、gisdb）
3. 测试连接成功后即可管理所有数据库

连接后可以看到三个数据库：postgres、maindb 和 gisdb（带有PostGIS扩展）

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

## 常用PostGIS操作示例

### 创建空间表
```sql
-- 创建包含几何字段的表
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(POINT, 4326)
);

-- 插入空间数据
INSERT INTO locations (name, geom) 
VALUES ('Boston', ST_GeomFromText('POINT(-71.060316 42.358431)', 4326));

-- 空间查询
SELECT name, ST_AsText(geom) 
FROM locations 
WHERE ST_DWithin(geom, ST_GeomFromText('POINT(-71.0 42.0)', 4326), 0.1);
```

### 创建空间索引
```sql
-- 创建空间索引提高查询性能
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);
```

## 数据管理

### 备份数据库
```bash
# 备份业务数据库
docker exec postgresql_postgis pg_dump -U postgres maindb > maindb_backup.sql

# 备份空间数据库
docker exec postgresql_postgis pg_dump -U postgres gisdb > gisdb_backup.sql

# 备份所有数据库
docker exec postgresql_postgis pg_dumpall -U postgres > all_databases_backup.sql
```

### 恢复数据库
```bash
# 恢复业务数据库
docker exec -i postgresql_postgis psql -U postgres maindb < maindb_backup.sql

# 恢复空间数据库
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