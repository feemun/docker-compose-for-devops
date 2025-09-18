@echo off
echo 正在重启Nginx Proxy Manager以应用自定义配置...

echo.
echo 1. 停止当前容器...
docker-compose down

echo.
echo 2. 启动容器（使用自定义Nginx配置）...
docker-compose up -d

echo.
echo 3. 检查容器状态...
docker-compose ps

echo.
echo 4. 查看容器日志（最后20行）...
docker-compose logs --tail=20 nginx-proxy-manager

echo.
echo 5. 测试配置是否生效...
echo 等待5秒让服务完全启动...
timeout /t 5 /nobreak > nul

echo.
echo 测试HTTPS访问智能日历服务...
docker exec nginx-proxy-manager curl -k -v https://localhost/smart-calendar/ || echo 测试失败，请检查配置

echo.
echo 配置应用完成！
echo 访问地址：
echo   - 智能日历服务: https://localhost/smart-calendar
echo   - NPM管理界面: http://localhost:81
echo.
pause