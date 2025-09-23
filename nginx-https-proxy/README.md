# 内网 HTTPS 代理服务

基于纯 Nginx 的内网 HTTPS 代理解决方案，支持自签名证书和多服务代理。

## 🚀 功能特性

### 核心功能
- **纯 Nginx 架构** - 使用官方 nginx:alpine 镜像，轻量高效
- **HTTPS 代理** - 将 HTTP 服务代理为 HTTPS 访问
- **自签名证书** - 支持内网环境使用自签名证书
- **多服务支持** - 可同时代理多个后台服务
- **服务别名** - 使用友好的 URL 路径访问服务
- **配置热重载** - 支持无重启更新配置

### 安全特性
- **强制 HTTPS** - 自动重定向 HTTP 到 HTTPS
- **安全头** - 内置多种安全响应头
- **现代 TLS** - 支持 TLS 1.2/1.3
- **容器安全** - 非特权运行，资源限制

### 运维特性
- **健康检查** - 内置服务健康监控
- **日志管理** - 自动轮转和大小限制
- **资源控制** - 合理的 CPU 和内存限制
- **配置工具** - 自动化配置生成和管理

## 📁 目录结构

```
nginx/
├── docker-compose.yml          # Docker Compose 配置
├── README.md                   # 本文档
├── config-generator/           # 配置生成器目录
│   ├── templates/              # 配置模板
│   │   └── service.conf.template
│   ├── generator/              # 配置生成器
│   │   ├── create-services.sh  # 服务配置生成工具
│   │   ├── http-service-config.txt # HTTP服务配置文件
│   │   └── service.conf.template   # Nginx配置模板
│   └── examples/               # 示例配置
│       └── my-app.conf         # 完整配置示例
├── nginx-config/               # Nginx 配置目录
│   ├── nginx.conf             # 主配置文件
│   └── sites-enabled/         # 启用的站点配置
└── ssl/                       # SSL 证书目录
    ├── cert.conf              # 证书配置
    ├── server.crt             # SSL 证书
    └── server.key             # SSL 私钥
```

## 🚀 快速开始

### 1. 准备 SSL 证书

如果没有证书，可以生成自签名证书：

```bash
# 生成自签名证书（Linux/macOS）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/localhost.key \
  -out ssl/localhost.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Dev/CN=localhost"

# Windows PowerShell
$cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My"
Export-Certificate -Cert $cert -FilePath "ssl\localhost.crt"
Export-PfxCertificate -Cert $cert -FilePath "ssl\localhost.pfx" -Password (ConvertTo-SecureString -String "password" -Force -AsPlainText)
```

### 2. 启动服务

```bash
# 启动 Nginx 代理服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f nginx
```

### 3. 配置服务代理

#### 方法一：使用配置工具（推荐）

```bash
# 进入工具目录
cd config-generator/generator

# 批量创建服务配置（使用默认配置文件）
./create-services.sh

# 或指定自定义配置文件
./create-services.sh -f custom-config.txt
```

#### 方法二：手动创建配置

```bash
# 复制模板文件
cp config-generator/templates/service.conf.template nginx-config/sites-enabled/my-service.conf

# 编辑配置文件，替换占位符：
# {{SERVICE_ALIAS}} -> 服务别名
# {{SERVICE_PORT}} -> 服务端口
```

### 4. 重新加载配置

```bash
# 测试配置
docker-compose exec nginx nginx -t

# 重新加载配置（无需重启）
docker-compose exec nginx nginx -s reload
```

## 🔧 配置说明

### 端口配置

| 端口 | 用途 | 访问地址 |
|------|------|----------|
| 80 | HTTP（重定向到HTTPS） | http://localhost |
| 443 | HTTPS代理 | https://localhost |

### 代理规则

- **访问格式**: `https://localhost/{service-alias}`
- **代理目标**: `http://host.docker.internal:{service-port}`
- **路径重写**: 自动移除服务别名前缀

### 示例配置

```nginx
# 将 https://localhost/my-app 代理到 http://localhost:8080
location /my-app {
    rewrite ^/my-app(/.*)$ $1 break;
    rewrite ^/my-app$ / break;
    proxy_pass http://host.docker.internal:8080;
    # ... 其他代理设置
}
```

## 🛠️ 管理命令

### Docker 操作

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart nginx

# 查看日志
docker-compose logs -f nginx

# 进入容器
docker-compose exec nginx sh
```

### Nginx 操作

```bash
# 测试配置
docker-compose exec nginx nginx -t

# 重新加载配置
docker-compose exec nginx nginx -s reload

# 查看配置
docker-compose exec nginx nginx -T

# 查看进程
docker-compose exec nginx ps aux
```

### 配置管理

```bash
# 创建新服务配置
cd config-generator/generator
./create-services.sh -f http-service-config.txt

# 查看生成的配置
cat ../../nginx-config/sites-enabled/api.conf
```

## 🔍 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # Windows 查看端口占用
   netstat -ano | findstr :80
   netstat -ano | findstr :443
   
   # 修改 docker-compose.yml 中的端口映射
   ```

2. **证书问题**
   - 确保证书文件存在：`ssl/localhost.crt` 和 `ssl/localhost.key`
   - 检查证书权限和格式
   - 浏览器添加证书信任

3. **配置错误**
   ```bash
   # 测试配置语法
   docker-compose exec nginx nginx -t
   
   # 查看错误日志
   docker-compose logs nginx
   ```

4. **服务无法访问**
   - 检查后台服务是否运行
   - 确认端口映射正确
   - 检查防火墙设置

### 日志位置

- **容器日志**: `docker-compose logs nginx`
- **访问日志**: 容器内 `/var/log/nginx/access.log`
- **错误日志**: 容器内 `/var/log/nginx/error.log`

## ⚡ 性能优化

### 资源配置

当前默认配置：
- **CPU 限制**: 1 核心
- **内存限制**: 512MB
- **CPU 预留**: 0.25 核心
- **内存预留**: 128MB

可根据实际负载调整 `docker-compose.yml` 中的资源配置。

### 缓存优化

```nginx
# 在服务配置中添加缓存设置
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🔒 安全建议

1. **证书管理**
   - 定期更新证书
   - 使用强密码保护私钥
   - 考虑使用内部 CA

2. **网络安全**
   - 限制管理端口访问
   - 使用防火墙规则
   - 定期更新镜像

3. **访问控制**
   - 添加基本认证
   - 实施 IP 白名单
   - 监控访问日志

## 🆚 与其他方案对比

| 特性 | 纯 Nginx | Nginx Proxy Manager | Traefik |
|------|----------|-------------------|----------|
| 资源占用 | 低 | 中等 | 中等 |
| 配置方式 | 配置文件 | Web UI | 配置文件/标签 |
| 学习成本 | 中等 | 低 | 中等 |
| 灵活性 | 高 | 中等 | 高 |
| 性能 | 高 | 中等 | 中等 |
| 自动发现 | 否 | 否 | 是 |

## 📝 更新日志

- **v2.0** - 重构为纯 Nginx 架构
- **v2.1** - 添加配置管理工具
- **v2.2** - 完善目录结构和文档
- **v2.3** - 添加批量配置支持

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

MIT License