ARG OPENRESTY_VERSION
FROM openresty/openresty:${OPENRESTY_VERSION:-1.27.1.2-3-alpine}

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

# 安装系统依赖并清理缓存
RUN apk update && apk --no-cache add \
    tzdata \
    logrotate \
    && rm -rf /var/cache/apk/*

# 复制日志轮转配置
COPY logrotate/openresty /etc/logrotate.d/openresty

# 设置日志轮转定时任务
RUN echo "0 0 * * * logrotate -f /etc/logrotate.d/openresty" >> /etc/crontabs/root

# 启动服务
CMD ["sh", "-c", "crond -b && /usr/local/openresty/bin/openresty -g 'daemon off;'"]
