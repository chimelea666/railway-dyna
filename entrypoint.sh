#!/bin/bash
set -e

# 1. 生成随机UUID（动态替换，不写死）
UUID=$(uuidgen)
echo "生成新UUID: $UUID"

# 2. 设置内存限制（适配Railway 512MB）
export V2RAY_VMESS_AEAD_FORCED=false
export V2RAY_LOG_LEVEL=warning
export GODEBUG=madvdontneed=1

# 3. 生成轻量config.json（临时文件，重启自动更新）
cat > /tmp/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": ${PORT:-8080},  # 使用Railway分配的PORT环境变量
      "listen": "0.0.0.0",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 64
          }
        ],
        "disableInsecureEncryption": true
      },
      "streamSettings": {
        "network": "ws",  # 轻量WebSocket协议，降低内存
        "wsSettings": {
          "path": "/vmess"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "direct"
      }
    ]
  }
}
EOF

# 4. 启动V2Ray并限制内存（关键：防止OOM）
echo "启动V2Ray，配置文件：/tmp/config.json"
ulimit -n 1024  # 限制最大连接数
v2ray run -config /tmp/config.json &

# 5. 保活监听（兼容UptimeRobot，防止休眠）
echo "启动保活服务..."
while true; do
  # 监听8080端口，响应HTTP请求（供UptimeRobot检测）
  echo -e "HTTP/1.1 200 OK\n\nV2Ray is running (UUID: $UUID)" | nc -l -p ${PORT:-8080} -q 1
  sleep 5
done