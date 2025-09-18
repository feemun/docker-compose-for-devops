# Nginx Proxy Manager 完整配置

这是一个完善的 Nginx Proxy Manager Docker Compose 配置，包含了生产环境的最佳实践。

## 功能特性

### 🚀 核心功能
- **可视化管理界面** - 通过Web界面管理所有代理配置
- **自动SSL证书** - 支持Let's Encrypt自动申请和续期
- **自定义SSL证书** - 支持上传和使用自定义证书
- **反向代理** - 完整的HTTP/HTTPS反向代理功能

### 🛡️ 安全配置
- **非root用户运行** - 提高容器安全性
- **安全选项** - 禁用新权限获取
- **资源限制** - 防止资源滥用
- **健康检查** - 自动监控服务状态

### 📊 运维功能
- **日志管理** - 自动轮转和大小限制
- **数据持久化** - 配置和证书数据持久保存
- **时区设置** - 正确的时间显示
- **调试模式** - 可配置的调试选项

## 目录结构

```
nginx-proxy-manager/
├── docker-compose.yml    # 主配置文件
├── data/                 # NPM数据目录（自动创建）
├── letsencrypt/         # Let's Encrypt证书（自动创建）
├── ssl/                 # 自定义SSL证书目录
├── logs/                # Nginx日志目录
└── README.md           # 说明文档
```

## 端口配置

| 端口 | 用途 | 访问地址 |
|------|------|----------|
| 81 | 管理界面 | http://localhost:81 |
| 8080 | HTTP代理 | http://localhost:8080 |
| 8443 | HTTPS代理 | https://localhost:8443 |

## 快速开始

### 1. 启动服务

```bash
# 进入目录
cd nginx-proxy-manager

# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 2. 访问管理界面

1. 打开浏览器访问：http://localhost:81
2. 默认登录信息：
   - 邮箱：`admin@example.com`
   - 密码：`changeme`
3. **首次登录后请立即修改密码！**

### 3. 添加代理主机

1. 点击 "Proxy Hosts" → "Add Proxy Host"
2. 填写基本信息：
   - **Domain Names**: `localhost` 或你的域名
   - **Forward Hostname/IP**: 目标服务地址（如 `localhost` 或 `host.docker.internal`）
   - **Forward Port**: 目标服务端口（如 `8000`）
3. 配置SSL（可选）：
   - 切换到 "SSL" 标签页
   - 选择证书类型（Let's Encrypt 或 自定义）
4. 高级配置（可选）：
   - 切换到 "Advanced" 标签页
   - 添加自定义 Nginx 配置

## 高级配置示例

### 自定义Location配置

在 "Advanced" 标签页的 "Custom Nginx Configuration" 中添加：

```nginx
# API路径代理
location /api/ {
    proxy_pass http://localhost:8000/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# 静态文件代理
location /static/ {
    proxy_pass http://localhost:3000/assets/;
    proxy_set_header Host $host;
}

# WebSocket支持
location /ws/ {
    proxy_pass http://localhost:8000/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}
```

### 使用自定义SSL证书

1. 将证书文件放入 `ssl/` 目录：
   ```
   ssl/
   ├── your-domain.crt
   └── your-domain.key
   ```

2. 在NPM管理界面中：
   - 选择 "Custom" SSL类型
   - 上传证书文件

## 常用命令

```bash
# 查看服务状态
docker-compose ps

# 查看实时日志
docker-compose logs -f nginx-proxy-manager

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 更新镜像
docker-compose pull
docker-compose up -d

# 备份数据
tar -czf npm-backup-$(date +%Y%m%d).tar.gz data/ letsencrypt/

# 进入容器
docker-compose exec nginx-proxy-manager /bin/sh
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :80
   netstat -tulpn | grep :443
   
   # 修改docker-compose.yml中的端口映射
   ```

2. **权限问题**
   ```bash
   # 修复目录权限
   sudo chown -R 1000:1000 data/ letsencrypt/ logs/ ssl/
   ```

3. **健康检查失败**
   ```bash
   # 检查容器状态
   docker-compose ps
   
   # 查看详细日志
   docker-compose logs nginx-proxy-manager
   ```

4. **SSL证书问题**
   - 确保域名DNS解析正确
   - 检查防火墙设置
   - 验证Let's Encrypt限制

### 日志位置

- **容器日志**: `docker-compose logs nginx-proxy-manager`
- **Nginx访问日志**: `logs/access.log`
- **Nginx错误日志**: `logs/error.log`
- **NPM应用日志**: `data/logs/`

## 性能优化

### 资源配置

当前配置的资源限制：
- **CPU限制**: 2核心
- **内存限制**: 1GB
- **CPU预留**: 0.5核心
- **内存预留**: 256MB

根据实际负载调整 `docker-compose.yml` 中的资源配置。

### 网络优化

- 使用自定义网络 `npm-network`
- 子网：`172.25.0.0/16`
- 可根据需要调整网络配置

## 安全建议

1. **修改默认密码** - 首次登录后立即修改
2. **启用2FA** - 在用户设置中启用双因素认证
3. **定期备份** - 定期备份配置和证书数据
4. **监控日志** - 定期检查访问和错误日志
5. **更新镜像** - 定期更新到最新版本
6. **网络隔离** - 使用防火墙限制管理端口访问

## 更新日志

- **v1.0** - 初始配置
- **v1.1** - 添加健康检查和资源限制
- **v1.2** - 完善安全配置和日志管理
- **v1.3** - 添加自定义SSL证书支持