# MongoDB Docker Configuration

这个配置提供了一个MongoDB实例，包含完整的测试数据库用于开发和测试。

## 配置信息

- **端口**: 30001 (映射到容器内的27017)
- **用户名**: root
- **密码**: root
- **认证数据库**: admin
- **数据库**: test

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

根据配置，连接字符串如下：

```properties
# Test数据库连接
spring.data.mongodb.uri=mongodb://root:root@localhost:30001/test?authSource=admin

# 或使用专用用户连接
spring.data.mongodb.uri=mongodb://test_user:test_password@localhost:30001/test
```

## 数据库初始化

容器启动时会自动执行 `init-scripts/01-init-databases.js` 脚本，创建以下内容：

### 数据库和集合
- **test数据库**
- **users集合** - 用户信息（5个测试用户）
- **products集合** - 商品信息（5个测试商品）
- **orders集合** - 订单信息（3个测试订单）
- **categories集合** - 商品分类（4个分类）

### 索引优化
- 用户名和邮箱唯一索引
- 商品名称、分类、价格索引
- 订单号唯一索引、用户ID索引
- 分类名称唯一索引

### 数据库用户
- **test_user** (密码: test_password) - 拥有test数据库读写权限

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

## 测试数据说明

### 用户数据 (users集合)
包含5个测试用户，每个用户包含：
- 用户名、邮箱、年龄、城市
- 兴趣爱好数组
- 创建时间、活跃状态

### 商品数据 (products集合)
包含5个测试商品：
- iPhone 15 Pro、MacBook Air M3、Nike Air Max 270、Samsung 4K TV、Adidas Ultraboost 22
- 每个商品包含：名称、分类、价格、库存、描述、标签、评分、评论数

### 订单数据 (orders集合)
包含3个不同状态的订单：
- 已完成订单、已发货订单、处理中订单
- 包含订单项目、总金额、收货地址、订单日期等

### 分类数据 (categories集合)
包含4个商品分类：
- Electronics（电子产品）- 父分类
- Shoes（鞋类）- 父分类
- Smartphones（智能手机）- Electronics子分类
- Laptops（笔记本电脑）- Electronics子分类

## 连接和查询测试

### 连接数据库
```bash
# 使用mongosh连接
mongosh mongodb://root:root@localhost:30001/test?authSource=admin

# 或使用专用用户连接
mongosh mongodb://test_user:test_password@localhost:30001/test
```

### 常用查询示例
```javascript
// 切换到test数据库
use test;

// 查看所有集合
show collections;

// 查询所有用户
db.users.find().pretty();

// 查询活跃用户
db.users.find({isActive: true});

// 查询特定城市的用户
db.users.find({city: "New York"});

// 查询所有商品
db.products.find().pretty();

// 查询电子产品
db.products.find({category: "Electronics"});

// 查询价格范围内的商品
db.products.find({price: {$gte: 100, $lte: 1000}});

// 查询所有订单
db.orders.find().pretty();

// 查询特定用户的订单
db.orders.find({userId: "john_doe"});

// 查询已完成的订单
db.orders.find({status: "completed"});

// 聚合查询：按分类统计商品数量
db.products.aggregate([
  {$group: {_id: "$category", count: {$sum: 1}, avgPrice: {$avg: "$price"}}}
]);

// 聚合查询：用户订单统计
db.orders.aggregate([
  {$group: {_id: "$userId", totalOrders: {$sum: 1}, totalAmount: {$sum: "$totalAmount"}}}
]);
```