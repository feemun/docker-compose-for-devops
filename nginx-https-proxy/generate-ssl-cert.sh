#!/bin/bash

# 自签名SSL证书生成脚本
# 用于nginx HTTPS代理

set -e

# 证书存储目录
SSL_DIR="./ssl"
CERT_FILE="$SSL_DIR/server.crt"
KEY_FILE="$SSL_DIR/server.key"

# 创建SSL目录
mkdir -p "$SSL_DIR"

echo "正在生成自签名SSL证书..."

# 生成私钥
openssl genrsa -out "$KEY_FILE" 2048

# 生成证书签名请求配置文件
cat > "$SSL_DIR/cert.conf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=CN
ST=Beijing
L=Beijing
O=Local Development
OU=IT Department
CN=localhost

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# 生成自签名证书
openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 -config "$SSL_DIR/cert.conf" -extensions v3_req

# 设置文件权限
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "SSL证书生成完成！"
echo "证书文件: $CERT_FILE"
echo "私钥文件: $KEY_FILE"
echo "证书有效期: 365天"
echo ""
echo "注意: 这是自签名证书，浏览器会显示安全警告。"
echo "在生产环境中，请使用由受信任的CA签发的证书。"

# 显示证书信息
echo ""
echo "证书信息:"
openssl x509 -in "$CERT_FILE" -text -noout | grep -A 2 "Subject:"
openssl x509 -in "$CERT_FILE" -text -noout | grep -A 5 "Subject Alternative Name"