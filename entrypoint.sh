#!/bin/bash
set -e

# 1. 生成UUID
UUID=$(uuidgen)
echo "✅ 生成新UUID: $UUID"

# 2. 生成配置文件（简化版，避免复杂配置）
cat > /tmp/config.json << EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "port": 8080,
    "listen": "0.0.0.0",
    "protocol": "vmess",
    "settings": {
      "clients": [{"id": "$UUID", "alterId": 64}]
    },
    "streamSettings": {"network": "ws", "wsSettings": {"path": "/vmess"}}
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

# 3. 启动V2Ray（指定完整路径）
echo "✅ 启动V2Ray服务..."
/usr/local/bin/v2ray run -config /tmp/config.json &

# 4. 保活服务（单独监听9000端口，避免和V2Ray端口冲突）
echo "✅ 启动保活服务..."
while true; do
  echo -e "HTTP/1.1 200 OK\n\nUUID: $UUID" | nc -l -w 1 -p 9000
  sleep 5
done
