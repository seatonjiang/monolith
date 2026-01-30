ARG IMAGE_REGISTRY
ARG REDIS_VERSION
FROM ${IMAGE_REGISTRY:-docker.cnb.cool/seatonjiang/monolith}/redis:${REDIS_VERSION:-8.4-alpine}

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

# 安装系统依赖并清理缓存
RUN apk update && apk --no-cache add \
    tzdata \
    logrotate \
    && rm -rf /var/cache/apk/*

# 修复 PID 文件权限问题
RUN mkdir -p /var/run/redis && chown redis:redis /var/run/redis

# 设置日志轮转定时任务
RUN echo "0 0 * * * logrotate -f /etc/logrotate.d/redis" >> /etc/crontabs/root

# 启动服务
CMD ["sh", "-c", "crond -b && redis-server /usr/local/etc/redis/redis.conf"]
