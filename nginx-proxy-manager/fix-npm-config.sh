#!/bin/bash

# NPM配置修复脚本
# 用于删除默认nginx配置文件以解决server_name冲突问题

echo "开始修复NPM配置..."

# 检查容器是否运行
if ! docker ps | grep -q nginx-proxy-manager; then
    echo "错误: nginx-proxy-manager容器未运行"
    echo "请先启动容器: docker-compose up -d"
    exit 1
fi

echo "备份默认配置文件..."
# 备份默认配置文件
docker exec nginx-proxy-manager cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.backup 2>/dev/null || echo "备份失败或文件不存在"

echo "删除冲突的默认配置文件..."
# 删除默认配置文件
docker exec nginx-proxy-manager rm -f /etc/nginx/conf.d/default.conf

if [ $? -eq 0 ]; then
    echo "默认配置文件已删除"
else
    echo "删除配置文件失败"
    exit 1
fi

echo "重新加载nginx配置..."
# 重新加载nginx配置
docker exec nginx-proxy-manager nginx -s reload

if [ $? -eq 0 ]; then
    echo "nginx配置已重新加载"
else
    echo "重新加载配置失败，尝试重启容器..."
    docker restart nginx-proxy-manager
    
    if [ $? -eq 0 ]; then
        echo "容器已重启"
    else
        echo "重启容器失败"
        exit 1
    fi
fi

echo "等待容器启动..."
sleep 5

echo "检查容器状态..."
docker ps | grep nginx-proxy-manager

echo "检查nginx进程..."
docker exec nginx-proxy-manager ps aux | grep nginx

echo "修复完成！现在可以正常使用localhost域名的代理主机配置了。"
echo "建议测试访问: https://localhost/"