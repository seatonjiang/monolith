ARG IMAGE_REGISTRY
ARG PHP_VERSION
FROM ${IMAGE_REGISTRY:-docker.cnb.cool/seatonjiang/monolith}/php:${PHP_VERSION:-8.5-fpm-alpine}

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

# 安装系统依赖
RUN apk update && apk --no-cache add \
    tzdata \
    shadow \
    ghostscript \
    logrotate \
    && rm -rf /var/cache/apk/*

# 设置用户和组权限
RUN groupmod -o -g 1000 www-data && \
    usermod -o -u 1000 -g www-data www-data

# 设置工作目录
WORKDIR /var/www

# 设置日志轮转定时任务
RUN echo "0 0 * * * logrotate -f /etc/logrotate.d/php" >> /etc/crontabs/root

# 启动 PHP-FPM
CMD ["sh", "-c", "crond -b && php-fpm"]
