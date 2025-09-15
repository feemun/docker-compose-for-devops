# SQLite 纯净版 Docker Compose 配置

这是一个最简化的 SQLite 数据库 Docker Compose 配置，提供纯净的 SQLite 数据库环境。

## 🚀 功能特性

- **纯净 SQLite**: 基于 Alpine Linux 的轻量级 SQLite 数据库
- **数据持久化**: 本地目录挂载确保数据安全
- **简单易用**: 最小化配置，开箱即用
- **轻量级**: 极小的资源占用

## 📁 目录结构

```
sqlite/
├── docker-compose.yml          # 主配置文件
├── README.md                   # 说明文档
└── data/                       # 数据库文件目录
```

## 🛠️ 使用方法

### 1. 启动服务

```bash
# 启动 SQLite 数据库容器
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 2. 连接数据库

```bash
# 进入容器执行 SQLite 命令
docker-compose exec sqlite sqlite3 /data/database.db

# 示例操作
sqlite> .tables
sqlite> INSERT INTO test (name) VALUES ('Hello SQLite');
sqlite> SELECT * FROM test;
sqlite> .quit
```

### 3. 外部访问数据库文件

数据库文件位于 `./data/database.db`，可以直接使用任何 SQLite 客户端工具访问：

```bash
# 使用本地 SQLite 命令行工具
sqlite3 data/database.db

# 使用其他 SQLite 客户端工具
# 如 DB Browser for SQLite, SQLiteStudio 等
```

## 🔧 配置说明

### 服务配置

- **镜像**: `alpine:latest` - 轻量级 Linux 发行版
- **容器名**: `sqlite_db`
- **数据卷**: `./data:/data` - 本地数据目录挂载
- **重启策略**: `unless-stopped` - 自动重启

### 初始化

容器启动时会自动：
1. 安装 SQLite
2. 创建示例表 `test`
3. 保持容器运行

## 📊 示例操作

### 基本 SQL 操作

```sql
-- 创建表
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
);

-- 插入数据
INSERT INTO users (name, email) VALUES ('张三', 'zhangsan@example.com');
INSERT INTO users (name, email) VALUES ('李四', 'lisi@example.com');

-- 查询数据
SELECT * FROM users;

-- 更新数据
UPDATE users SET email = 'new_email@example.com' WHERE id = 1;

-- 删除数据
DELETE FROM users WHERE id = 2;
```

### SQLite 特殊命令

```sql
-- 显示所有表
.tables

-- 显示表结构
.schema users

-- 导出数据
.output backup.sql
.dump

-- 导入数据
.read backup.sql

-- 显示数据库信息
.dbinfo
```

## 📝 维护命令

```bash
# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 清理数据（谨慎使用）
docker-compose down
rm -rf data/*

# 备份数据库
cp data/database.db data/database_backup_$(date +%Y%m%d).db
```

## 🔍 故障排除

### 常见问题

1. **容器无法启动**
   - 检查 Docker 是否正常运行
   - 确认端口没有被占用
   - 查看容器日志

2. **数据库文件权限问题**
   - 确保 `data` 目录有正确的权限
   - 检查 Docker 用户权限

3. **数据丢失**
   - 确认数据目录挂载正确
   - 检查磁盘空间

### 日志查看

```bash
# 查看容器日志
docker-compose logs sqlite

# 实时查看日志
docker-compose logs -f sqlite
```

## 🎯 性能优化

对于生产环境，可以考虑以下优化：

```sql
-- 启用 WAL 模式（更好的并发性能）
PRAGMA journal_mode=WAL;

-- 设置缓存大小
PRAGMA cache_size=10000;

-- 启用外键约束
PRAGMA foreign_keys=ON;

-- 设置同步模式
PRAGMA synchronous=NORMAL;
```

## 📚 相关资源

- [SQLite 官方文档](https://www.sqlite.org/docs.html)
- [SQLite 命令行工具](https://www.sqlite.org/cli.html)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

**注意**: 这是一个轻量级的开发环境配置。对于生产环境或需要高并发的场景，建议考虑使用专门的数据库服务器。