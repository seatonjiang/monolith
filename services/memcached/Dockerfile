ARG IMAGE_REGISTRY
ARG MEMCACHED_VERSION
FROM ${IMAGE_REGISTRY:-seatonjiang}/memcached:${MEMCACHED_VERSION:-1.6-alpine}

USER root

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.ustc.edu.cn}/g" /etc/apk/repositories

# 安装系统依赖并清理缓存
RUN apk update && apk --no-cache add tzdata && rm -rf /var/cache/apk/*

USER memcache

# 启动服务
CMD ["memcached"]
