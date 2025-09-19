#!/bin/bash
# 自签名证书生成脚本
# 用于生成 HTTPS 代理服务所需的 SSL 证书

set -e

# 默认参数
CERT_NAME="server"
DAYS=365
KEY_SIZE=2048
COUNTRY="CN"
STATE="Beijing"
CITY="Beijing"
ORG="Development"
COMMON_NAME="localhost"

# 显示帮助信息
show_help() {
    echo "SSL 自签名证书生成工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -n, --name <name>      证书文件名前缀 (默认: server)"
    echo "  -d, --days <days>      证书有效期天数 (默认: 365)"
    echo "  -k, --keysize <size>   密钥长度 (默认: 2048)"
    echo "  -c, --country <code>   国家代码 (默认: CN)"
    echo "  -s, --state <state>    省份 (默认: Beijing)"
    echo "  -l, --city <city>      城市 (默认: Beijing)"
    echo "  -o, --org <org>        组织名称 (默认: Development)"
    echo "  -cn, --common-name <cn> 通用名称 (默认: localhost)"
    echo "  -h, --help             显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --name myapp --days 730 --common-name myapp.local"
    echo "  $0 -n api -cn api.localhost"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            CERT_NAME="$2"
            shift 2
            ;;
        -d|--days)
            DAYS="$2"
            shift 2
            ;;
        -k|--keysize)
            KEY_SIZE="$2"
            shift 2
            ;;
        -c|--country)
            COUNTRY="$2"
            shift 2
            ;;
        -s|--state)
            STATE="$2"
            shift 2
            ;;
        -l|--city)
            CITY="$2"
            shift 2
            ;;
        -o|--org)
            ORG="$2"
            shift 2
            ;;
        -cn|--common-name)
            COMMON_NAME="$2"
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

# 检查 OpenSSL 是否安装
if ! command -v openssl &> /dev/null; then
    echo "❌ OpenSSL 未安装，请先安装 OpenSSL"
    echo "   Ubuntu/Debian: sudo apt-get install openssl"
    echo "   CentOS/RHEL: sudo yum install openssl"
    echo "   macOS: brew install openssl"
    exit 1
fi

echo "🔐 SSL 自签名证书生成工具"
echo "证书名称: $CERT_NAME"
echo "有效期: $DAYS 天"
echo "密钥长度: $KEY_SIZE 位"
echo "通用名称: $COMMON_NAME"
echo ""

# 检查并删除旧证书文件
if [ -f "${CERT_NAME}.key" ] || [ -f "${CERT_NAME}.crt" ]; then
    echo "🗑️  检测到旧证书文件，正在删除..."
    
    if [ -f "${CERT_NAME}.key" ]; then
        rm -f "${CERT_NAME}.key"
        echo "   ✅ 已删除旧私钥: ${CERT_NAME}.key"
    fi
    
    if [ -f "${CERT_NAME}.crt" ]; then
        rm -f "${CERT_NAME}.crt"
        echo "   ✅ 已删除旧证书: ${CERT_NAME}.crt"
    fi
    
    echo ""
fi

# 生成私钥
echo "🔑 生成私钥..."
openssl genrsa -out "${CERT_NAME}.key" $KEY_SIZE

if [ $? -eq 0 ]; then
    echo "   ✅ 私钥生成成功: ${CERT_NAME}.key"
else
    echo "   ❌ 私钥生成失败"
    exit 1
fi

# 生成证书签名请求 (CSR)
echo "📝 生成证书签名请求..."
openssl req -new -key "${CERT_NAME}.key" -out "${CERT_NAME}.csr" -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${COMMON_NAME}"

if [ $? -eq 0 ]; then
    echo "   ✅ CSR 生成成功: ${CERT_NAME}.csr"
else
    echo "   ❌ CSR 生成失败"
    exit 1
fi

# 生成自签名证书
echo "📜 生成自签名证书..."
openssl x509 -req -in "${CERT_NAME}.csr" -signkey "${CERT_NAME}.key" -out "${CERT_NAME}.crt" -days $DAYS

if [ $? -eq 0 ]; then
    echo "   ✅ 证书生成成功: ${CERT_NAME}.crt"
else
    echo "   ❌ 证书生成失败"
    exit 1
fi

# 清理临时文件
echo "🧹 清理临时文件..."
rm -f "${CERT_NAME}.csr"
echo "   ✅ 临时文件已清理"

# 设置文件权限
echo "🔒 设置文件权限..."
chmod 600 "${CERT_NAME}.key"
chmod 644 "${CERT_NAME}.crt"
echo "   ✅ 文件权限设置完成"

# 显示证书信息
echo ""
echo "📋 证书信息:"
echo "   私钥文件: ${CERT_NAME}.key"
echo "   证书文件: ${CERT_NAME}.crt"
echo "   有效期: $DAYS 天"
echo "   通用名称: $COMMON_NAME"
echo ""
echo "🔍 查看证书详情:"
echo "   openssl x509 -in ${CERT_NAME}.crt -text -noout"
echo ""
echo "📝 验证证书:"
echo "   openssl verify -CAfile ${CERT_NAME}.crt ${CERT_NAME}.crt"
echo ""
echo "🌐 测试 HTTPS 连接:"
echo "   curl -k https://${COMMON_NAME}"
echo ""
echo "✅ 证书生成完成！"
echo "💡 提示: 在浏览器中访问 HTTPS 站点时，需要手动信任此自签名证书"