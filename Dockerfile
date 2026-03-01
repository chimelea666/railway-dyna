# 轻量基础镜像，内存占用比官方低50%
FROM teddysun/v2ray:latest

# 关键修正：Alpine 使用 apk 安装依赖，替换 apt
# uuidgen -> util-linux；nc -> netcat-openbsd
RUN apk update && apk add --no-cache util-linux netcat-openbsd && rm -rf /var/cache/apk/*

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露端口（Railway自动映射）
EXPOSE 8080

# 启动脚本
ENTRYPOINT ["/entrypoint.sh"]
