ARG PHP_VERSION
FROM php:${PHP_VERSION:-8.4-fpm-alpine}

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

# 安装系统依赖
RUN apk update && apk --no-cache add \
    tzdata \
    shadow \
    ghostscript \
    imagemagick \
    && rm -rf /var/cache/apk/*

# 复制并设置 PHP 扩展安装脚本
COPY install-php-extensions /usr/local/bin/install-php-extensions
RUN chmod +x /usr/local/bin/install-php-extensions

# 安装 PHP 扩展
ARG PHP_EXTENSIONS
RUN php_extension_list=$(echo "${PHP_EXTENSIONS}" | sed 's/,/ /g') && \
    install-php-extensions ${php_extension_list}

# 安装 Composer
ARG PHP_COMPOSER_MIRROR
RUN curl -o /usr/bin/composer https://${PHP_COMPOSER_MIRROR:-mirrors.cloud.tencent.com}/composer/composer.phar && \
    chmod +x /usr/bin/composer && \
    composer config -g repos.packagist composer https://${PHP_COMPOSER_MIRROR:-mirrors.cloud.tencent.com}/composer/

# 设置 Composer 环境变量
ENV COMPOSER_HOME=/tmp/composer

# 设置用户和组权限
RUN groupmod -o -g 1000 www-data && \
    usermod -o -u 1000 -g www-data www-data

# 设置工作目录
WORKDIR /var/www

# 启动 PHP-FPM
CMD ["php-fpm"]
