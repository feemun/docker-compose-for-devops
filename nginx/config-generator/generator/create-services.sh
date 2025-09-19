#!/bin/bash
# 批量创建Nginx服务配置工具
# 用法: ./create-services.sh [-f <config_file>]

set -e

# 默认参数
CONFIG_FILE=""

# 显示帮助信息
show_help() {
    echo "批量创建Nginx服务配置工具"
    echo ""
    echo "用法: $0 -f <config_file>"
    echo ""
    echo "参数:"
    echo "  -f, --file     配置文件路径 (默认: http-service-config.txt)"
    echo "  -h, --help     显示帮助信息"
    echo ""
    echo "配置文件格式 (每行一个服务):"
    echo "  service_name:port:alias"
    echo "  或"
    echo "  service_name:port"
    echo ""
    echo "示例:"
    echo "  my-app:3000:myapp"
    echo "  api-service:8080"
}

# 验证服务名称
validate_service_name() {
    local service_name="$1"
    if [[ ! "$service_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
}

# 验证端口号
validate_port() {
    local port="$1"
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        return 1
    fi
    return 0
}

# 解析配置行
parse_config_line() {
    local line="$1"
    local -n result_array="$2"
    
    # 跳过空行和注释行
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        return 1
    fi
    
    # 解析配置行
    IFS=':' read -ra CONFIG <<< "$line"
    
    if [ ${#CONFIG[@]} -lt 2 ]; then
        return 2
    fi
    
    result_array[0]="${CONFIG[0]}"
    result_array[1]="${CONFIG[1]}"
    result_array[2]="${CONFIG[2]:-${CONFIG[0]}}"
    
    return 0
}

# 显示统计结果
show_statistics() {
    local total="$1"
    local success="$2"
    local fail="$3"
    
    echo "📊 批量创建完成"
    echo "   总计: $total 个服务"
    echo "   成功: $success 个"
    echo "   失败: $fail 个"
    
    if [ $success -gt 0 ]; then
        echo ""
        echo "🔄 下一步操作:"
        echo "   1. 检查所有配置: docker-compose exec nginx nginx -t"
        echo "   2. 重载配置: docker-compose exec nginx nginx -s reload"
        echo "   3. 查看服务状态: docker-compose ps"
    fi
    
    if [ $fail -gt 0 ]; then
        echo ""
        echo "⚠️  有 $fail 个服务配置创建失败，请检查配置文件格式"
    fi
}

# 单个服务配置创建函数
create_single_service() {
    local service_name="$1"
    local service_port="$2"
    local service_alias="$3"
    
    # 检查模板文件
    local template_file="./service.conf.template"
    if [ ! -f "$template_file" ]; then
        echo "❌ 错误: 模板文件不存在: $template_file"
        return 1
    fi
    
    # 输出目录
    local output_dir="../../nginx-config/sites-enabled"
    mkdir -p "$output_dir"
    
    # 输出文件
    local output_file="$output_dir/${service_name}.conf"
    
    # 读取模板并替换占位符
    sed -e "s/{{SERVICE_ALIAS}}/$service_alias/g" \
        -e "s/{{SERVICE_PORT}}/$service_port/g" \
        "$template_file" > "$output_file"
    
    return $?
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 -h 查看帮助信息"
            exit 1
            ;;
    esac
done

# 如果未指定配置文件，使用默认的http-service-config.txt
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="http-service-config.txt"
fi

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误: 配置文件不存在: $CONFIG_FILE"
    echo "提示: 请创建配置文件或使用 -f 参数指定其他配置文件"
    exit 1
fi

echo "📋 批量创建Nginx服务配置"
echo "配置文件: $CONFIG_FILE"
echo ""

# 统计变量
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# 读取配置文件并处理每一行
while IFS= read -r line || [ -n "$line" ]; do
    declare -a config_parts
    
    # 解析配置行
    parse_result=$(parse_config_line "$line" config_parts)
    case $parse_result in
        1) # 空行或注释行
            continue
            ;;
        2) # 格式错误
            echo "❌ 跳过无效配置: $line (格式错误)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            continue
            ;;
        0) # 解析成功
            TOTAL_COUNT=$((TOTAL_COUNT + 1))
            ;;
    esac
    
    SERVICE_NAME="${config_parts[0]}"
    SERVICE_PORT="${config_parts[1]}"
    SERVICE_ALIAS="${config_parts[2]}"
    
    # 验证服务名称和端口
    if ! validate_service_name "$SERVICE_NAME"; then
        echo "❌ 跳过无效服务名称: $SERVICE_NAME"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    if ! validate_port "$SERVICE_PORT"; then
        echo "❌ 跳过无效端口: $SERVICE_PORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    echo "🔧 处理服务: $SERVICE_NAME (端口: $SERVICE_PORT, 别名: $SERVICE_ALIAS)"
    
    # 直接创建服务配置
    if create_single_service "$SERVICE_NAME" "$SERVICE_PORT" "$SERVICE_ALIAS"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "✅ 服务 $SERVICE_NAME 配置创建成功"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "❌ 服务 $SERVICE_NAME 配置创建失败"
    fi
    
    echo ""
done < "$CONFIG_FILE"

# 显示统计结果
show_statistics "$TOTAL_COUNT" "$SUCCESS_COUNT" "$FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
fi