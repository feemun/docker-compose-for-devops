@echo off
setlocal enabledelayedexpansion

echo ========================================
echo     Nginx服务配置文件生成工具
echo ========================================
echo.

if "%1"=="" (
    echo 使用方法：
    echo   create-service-config.bat [服务名] [端口] [路径前缀]
    echo.
    echo 示例：
    echo   create-service-config.bat user-service 3001 /users
    echo   create-service-config.bat order-service 3002 /orders
    echo   create-service-config.bat file-service 3003 /files
    echo.
    echo 批量创建示例：
    echo   create-service-config.bat batch
    echo.
    goto :end
)

if "%1"=="batch" (
    echo 进入批量创建模式...
    echo.
    echo 请按以下格式输入服务信息（每行一个服务）：
    echo 格式：服务名 端口 路径前缀
    echo 示例：user-service 3001 /users
    echo 输入完成后按 Ctrl+Z 然后回车结束输入
    echo.
    
    set /p services=<con
    for /f "tokens=1,2,3" %%a in ('more') do (
        call :create_config "%%a" "%%b" "%%c"
    )
    goto :end
)

if "%3"=="" (
    echo 错误：缺少参数
    echo 使用方法：create-service-config.bat [服务名] [端口] [路径前缀]
    goto :end
)

call :create_config "%1" "%2" "%3"
goto :end

:create_config
set service_name=%~1
set service_port=%~2
set service_path=%~3
set config_file=nginx\sites-enabled\%service_name%.conf

echo 正在创建 %service_name% 的配置文件...

(
echo # %service_name% 服务配置
echo # 自动生成于 %date% %time%
echo server {
echo     listen 80;
echo     server_name localhost;
echo     
echo     # HTTP重定向到HTTPS
echo     return 301 https://$server_name$request_uri;
echo }
echo.
echo server {
echo     listen 443 ssl http2;
echo     server_name localhost;
echo.
echo     # SSL证书配置
echo     ssl_certificate /etc/nginx/ssl/server.crt;
echo     ssl_certificate_key /etc/nginx/ssl/server.key;
echo.
echo     # SSL安全配置
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
echo     ssl_prefer_server_ciphers off;
echo     ssl_session_cache shared:SSL:10m;
echo     ssl_session_timeout 10m;
echo.
echo     # 安全头
echo     add_header X-Frame-Options DENY;
echo     add_header X-Content-Type-Options nosniff;
echo     add_header X-XSS-Protection "1; mode=block";
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo.
echo     # %service_name% 服务代理配置
echo     # 将 https://localhost%service_path% 代理到 http://host.docker.internal:%service_port%
echo     # %service_path% 是服务别名，不是后台服务的实际路径
echo     location %service_path% {
echo         # 去掉路径前缀，直接转发到后台服务根路径
echo         rewrite ^%service_path%/?^(.*^)$ /$1 break;
echo         
echo         # 代理到 %service_name% 服务
echo         # 代理到后台服务，注意这里使用 host.docker.internal 访问宿主机服务
echo         proxy_pass http://host.docker.internal:%service_port%;
echo         
echo         # 代理头设置
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_set_header X-Forwarded-Host $server_name;
echo         proxy_set_header X-Forwarded-Port $server_port;
echo         
echo         # 超时设置
echo         proxy_connect_timeout 30s;
echo         proxy_send_timeout 30s;
echo         proxy_read_timeout 30s;
echo         
echo         # 缓冲设置
echo         proxy_buffering on;
echo         proxy_buffer_size 4k;
echo         proxy_buffers 8 4k;
echo         
echo         # WebSocket支持
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection "upgrade";
echo     }
echo.
echo     # 健康检查端点
echo     location %service_path%/health {
echo         access_log off;
echo         proxy_pass http://host.docker.internal:%service_port%/health;
echo         proxy_set_header Host $host;
echo     }
echo }
) > "%config_file%"

echo   ✓ 配置文件已创建：%config_file%
echo   ✓ 服务路径：https://localhost%service_path%
echo   ✓ 后端地址：http://host.docker.internal:%service_port%
echo.
goto :eof

:end
echo.
echo 配置文件创建完成！
echo 请运行 restart-with-custom-config.bat 应用配置
echo.
pause