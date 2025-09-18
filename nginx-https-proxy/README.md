# Nginx HTTPS 代理

通过自签名证书和 Nginx 将内网 HTTP 服务转换为 HTTPS 服务的 Docker Compose 配置。

## 功能特性

- ✅ HTTP 自动重定向到 HTTPS
- ✅ 自签名 SSL 证书生成
- ✅ 安全的 SSL/TLS 配置
- ✅ 代理到内网 HTTP 服务
- ✅ 健康检查
- ✅ 安全头设置
- ✅ 日志记录

## 目录结构

```
nginx-https-proxy/
├── docker-compose.yml          # Docker Compose 配置文件
├── nginx.conf                  # Nginx 配置文件
├── generate-ssl-cert.sh        # SSL 证书生成脚本 (Linux/Mac)
├── generate-ssl-cert.bat       # SSL 证书生成脚本 (Windows)
├── README.md                  # 说明文档
├── ssl/                       # SSL 证书目录 (运行后生成)
│   ├── server.crt            # SSL 证书
│   ├── server.key            # SSL 私钥
│   └── cert.conf             # 证书配置文件
└── logs/                      # 日志目录 (运行后生成)
    ├── access.log            # 访问日志
    └── error.log             # 错误日志
```

## 快速开始

### 1. 生成 SSL 证书

**Linux/Mac 用户:**
```bash
chmod +x generate-ssl-cert.sh
./generate-ssl-cert.sh
```

**Windows 用户:**
```cmd
generate-ssl-cert.bat
```

### 2. 配置内网服务地址

编辑 `nginx.conf` 文件，修改第 52 行的代理地址：

```nginx
# 将 your-internal-service:8080 替换为实际的内网服务地址
proxy_pass http://your-internal-service:8080;
```

### 3. 启动服务

```bash
docker-compose up -d
```

### 4. 访问服务

- HTTP: http://localhost (自动重定向到 HTTPS)
- HTTPS: https://localhost
- 健康检查: https://localhost/nginx-health

## 配置说明

### 服务访问配置

本配置支持两个后台HTTP服务的代理：

#### 访问路径说明

- **API服务 (8000端口)**：通过 `https://localhost/api/` 访问
- **应用服务 (8080端口)**：通过 `https://localhost/app/` 访问  
- **默认路由**：直接访问 `https://localhost/` 会代理到8080端口服务

#### 服务配置

当前配置使用了**简化的upstream配置**，代理到本地服务：
- API服务 (8000端口)：`api_service` upstream
- 应用服务 (8080端口)：`app_service` upstream

#### 添加新服务的步骤

1. **在nginx.conf中添加upstream定义**：
```nginx
upstream new_service {
    server 127.0.0.1:9000;  # 新服务的地址和端口
}
```

2. **添加location配置**：
```nginx
location /new/ {
    proxy_pass http://new_service/;
    include /etc/nginx/proxy_params;
}
```

#### 配置优势

- **简化配置**：使用 `proxy_params` 文件统一管理代理参数
- **易于维护**：新增服务只需2-3行配置
- **统一管理**：所有代理设置集中在 `proxy_params` 文件中
- **支持负载均衡**：upstream可以配置多个后端服务器

**注意事项：**
- 确保所有后台服务都已启动并监听对应端口
- 修改服务地址只需编辑对应的upstream配置
- 可以根据需要修改location路径

### 端口配置

修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "80:80"     # HTTP 端口
  - "443:443"   # HTTPS 端口
```

### SSL 证书配置

#### 使用自定义域名

1. 修改 `generate-ssl-cert.sh` 或 `generate-ssl-cert.bat` 中的域名配置
2. 重新生成证书
3. 修改 `nginx.conf` 中的 `server_name`

#### 使用现有证书

将现有证书文件放置到 `ssl/` 目录：
- `ssl/server.crt` - SSL 证书
- `ssl/server.key` - SSL 私钥

## 安全配置

### SSL/TLS 安全设置

- 支持 TLS 1.2 和 TLS 1.3
- 使用安全的加密套件
- 启用 HSTS (HTTP Strict Transport Security)
- 设置安全响应头

### 生产环境建议

1. **使用受信任的 CA 证书**
   - 替换自签名证书为正式 SSL 证书
   - 配置证书自动续期

2. **网络安全**
   - 限制访问来源 IP
   - 配置防火墙规则
   - 使用 VPN 或内网访问

3. **监控和日志**
   - 配置日志轮转
   - 设置监控告警
   - 定期检查安全日志

## 故障排除

### 常见问题

1. **证书生成失败**
   - 确保已安装 OpenSSL
   - 检查文件权限
   - 查看错误日志

2. **无法访问第三方服务**
   - 检查代理地址配置
   - 确认第三方服务正常运行
   - 检查网络连通性
   - 确认防火墙设置允许访问

3. **浏览器安全警告**
   - 自签名证书会显示安全警告，这是正常现象
   - 可以选择"继续访问"或添加证书例外

### 查看日志

```bash
# 查看容器日志
docker-compose logs nginx-https-proxy

# 查看 Nginx 访问日志
docker-compose exec nginx-https-proxy tail -f /var/log/nginx/access.log

# 查看 Nginx 错误日志
docker-compose exec nginx-https-proxy tail -f /var/log/nginx/error.log
```

### 重新生成证书

```bash
# 停止服务
docker-compose down

# 删除旧证书
rm -rf ssl/

# 重新生成证书
./generate-ssl-cert.sh  # Linux/Mac
# 或
generate-ssl-cert.bat   # Windows

# 重启服务
docker-compose up -d
```

## 高级配置

### 负载均衡

如果需要代理多个后端服务，可以配置负载均衡：

```nginx
upstream backend {
    server 192.168.1.100:8080;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}

server {
    # ...
    location / {
        proxy_pass http://backend;
        # ...
    }
}
```

### 路径代理

代理不同路径到不同服务：

```nginx
location /api/ {
    proxy_pass http://api-service:3000/;
}

location /web/ {
    proxy_pass http://web-service:8080/;
}
```

### WebSocket 支持

如果需要支持 WebSocket：

```nginx
location /ws/ {
    proxy_pass http://websocket-service:8080/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！