ARG IMAGE_REGISTRY
ARG CADDY_VERSION
FROM ${IMAGE_REGISTRY:-docker.cnb.cool/seatonjiang/monolith}/caddy:${CADDY_VERSION:-alpine}

# 替换 Alpine 镜像源
ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

# 安装系统依赖并清理缓存
RUN apk update && apk --no-cache add \
    tzdata \
    ca-certificates \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates
