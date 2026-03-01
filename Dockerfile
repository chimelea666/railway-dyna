# 使用官方极简Alpine镜像，从头安装V2Ray，避免兼容问题
FROM alpine:3.20

# 安装所有必要依赖（V2Ray+uuid+nc）
RUN apk add --no-cache \
    wget \
    unzip \
    util-linux \
    netcat-openbsd \
    bash && \
    # 下载并安装V2Ray（适配ARM/AMD架构）
    wget -O /tmp/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip /tmp/v2ray.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/v2ray && \
    # 清理临时文件
    rm -rf /tmp/v2ray.zip /var/cache/apk/*

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露端口
EXPOSE 8080

# 启动脚本
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
