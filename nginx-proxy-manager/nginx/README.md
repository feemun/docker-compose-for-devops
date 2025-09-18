# 自定义Nginx配置说明

## 目录结构

```
nginx/
├── nginx.conf                    # 主配置文件
├── sites-enabled/               # 站点配置目录
│   └── smart-calendar.conf      # 智能日历服务配置
└── README.md                    # 本说明文件
```

## 配置说明

### nginx.conf
- Nginx主配置文件
- 包含基本的HTTP、SSL、Gzip等配置
- 通过`include`指令加载站点配置

### smart-calendar.conf
- 智能日历服务的代理配置
- 配置了HTTP到HTTPS的重定向
- 实现了路径重写：`/smart-calendar` → `/`
- 包含SSL、安全头、WebSocket支持等配置

## 使用方法

1. **重启容器应用配置**：
   ```bash
   # Windows
   restart-with-custom-config.bat
   
   # 或手动执行
   docker-compose down
   docker-compose up -d
   ```

2. **访问服务**：
   - 智能日历服务：`https://localhost/smart-calendar`
   - NPM管理界面：`http://localhost:81`

## 多服务管理

### 快速创建服务配置

**方法一：使用配置生成工具**
```bash
# 创建单个服务
create-service-config.bat user-service 3001 /users

# 批量创建服务
create-service-config.bat batch
# 然后按提示输入服务信息
```

**方法二：复制模板文件**
```bash
# 复制模板
copy nginx\sites-enabled\service-template.conf.example nginx\sites-enabled\your-service.conf
# 然后编辑配置文件
```

### 服务管理工具

```bash
# 列出所有服务
manage-services.bat list

# 启用/禁用服务
manage-services.bat enable user-service
manage-services.bat disable order-service

# 删除服务配置
manage-services.bat delete old-service

# 测试配置语法
manage-services.bat test
```

### 十个服务示例

参考 `example-services.txt` 文件，包含了十个常见服务的配置示例：
- 用户管理服务 (3001端口, /users路径)
- 订单管理服务 (3002端口, /orders路径)
- 商品管理服务 (3003端口, /products路径)
- 支付服务 (3004端口, /payments路径)
- 文件上传服务 (3005端口, /files路径)
- 通知服务 (3006端口, /notifications路径)
- 日志服务 (3007端口, /logs路径)
- 监控服务 (3008端口, /monitor路径)
- 配置管理服务 (3009端口, /config路径)
- 智能日历服务 (8000端口, /smart-calendar路径)

### 目录结构

```
nginx/
├── nginx.conf                           # 主配置文件
├── sites-enabled/                       # 启用的服务配置
│   ├── smart-calendar.conf              # 智能日历服务
│   ├── user-service.conf                # 用户管理服务
│   ├── order-service.conf               # 订单管理服务
│   └── service-template.conf.example    # 配置模板
├── sites-disabled/                      # 禁用的服务配置
│   └── (临时禁用的配置文件)
└── README.md                            # 说明文档
```

## 配置验证

```bash
# 检查Nginx配置语法
docker exec nginx-proxy-manager nginx -t

# 重新加载配置（无需重启）
docker exec nginx-proxy-manager nginx -s reload

# 查看访问日志
docker exec nginx-proxy-manager tail -f /var/log/nginx/access.log
```

## 注意事项

1. **SSL证书**：配置使用`./ssl/`目录下的自签名证书
2. **路径重写**：所有服务都配置了路径前缀去除
3. **安全配置**：包含了基本的安全头和SSL配置
4. **日志**：访问和错误日志会保存到挂载的日志目录
5. **热重载**：修改配置后可以使用`nginx -s reload`热重载