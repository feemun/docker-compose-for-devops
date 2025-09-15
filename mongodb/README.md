# MongoDB Docker Configuration

这个配置提供了一个MongoDB实例，用于支持BaseMap和Terrain数据库。

## 配置信息

- **端口**: 30001 (映射到容器内的27017)
- **用户名**: root
- **密码**: root
- **认证数据库**: admin
- **数据库**: BaseMap, Terrain

## 启动服务

```bash
# 启动MongoDB服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f mongodb

# 进入容器
docker exec -it mongodb_01 mongosh
```

## 连接字符串

根据您提供的配置，连接字符串如下：

```properties
# BaseMap数据库连接
spring.data.mongodb.uri=mongodb://root:root@192.168.233.131:30001/BaseMap?authSource=admin
spring.data.mongodb.mapTile.uri=mongodb://root:root@192.168.233.131:30001/BaseMap?authSource=admin

# Terrain数据库连接
spring.data.mongodb.terrainTile.uri=mongodb://root:root@192.168.233.131:30001/Terrain?authSource=admin
```

## 数据库初始化

容器启动时会自动执行 `init-scripts/01-init-databases.js` 脚本，创建以下内容：

- BaseMap数据库
- Terrain数据库
- 相应的数据库用户（可选）

## 数据持久化

数据存储在Docker卷 `mongodb_data` 中，确保数据在容器重启后不会丢失。

## 停止服务

```bash
# 停止服务
docker-compose down

# 停止服务并删除数据卷（谨慎使用）
docker-compose down -v
```

## 故障排除

### 网络连接问题

如果遇到 "failed to resolve reference" 或 "failed to fetch anonymous token" 错误：

1. **检查网络连接**：
   ```bash
   ping docker.io
   ```

2. **配置Docker镜像源**（推荐）：
   - 在Docker Desktop设置中配置国内镜像源
   - 或创建/编辑 `%USERPROFILE%\.docker\daemon.json`：
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://registry.docker-cn.com",
       "https://mirror.ccs.tencentyun.com"
     ]
   }
   ```

   - 或者修改docker-compose.yml使用阿里云镜像：
   ```yaml
   image: registry.cn-hangzhou.aliyuncs.com/library/mongo:5.0
   ```

3. **重启Docker服务**：
   ```bash
   # 重启Docker Desktop
   # 或在管理员PowerShell中：
   Restart-Service docker
   ```

4. **手动拉取镜像**：
   ```bash
   docker pull mongo:5.0
   ```

### 端口冲突

如果30001端口被占用：
```bash
# 检查端口占用
netstat -ano | findstr :30001

# 修改docker-compose.yml中的端口映射
# 例如改为 "30002:27017"
```

## 连接测试

可以使用MongoDB客户端工具连接测试：

```bash
# 使用mongo shell连接
mongo mongodb://root:root@192.168.233.131:30001/admin

# 或使用mongosh
mongosh mongodb://root:root@192.168.233.131:30001/admin
```