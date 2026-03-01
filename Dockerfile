# 轻量基础镜像，内存占用比官方低50%
FROM teddysun/v2ray:latest

# 安装依赖（uuidgen、nc）
RUN apt update && apt install -y netcat-traditional uuid-runtime && rm -rf /var/lib/apt/lists/*

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露端口（Railway自动映射）
EXPOSE 8080

# 启动脚本
ENTRYPOINT ["/entrypoint.sh"]
