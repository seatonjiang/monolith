ARG IMAGE_REGISTRY
ARG MARIADB_VERSION
FROM ${IMAGE_REGISTRY:-docker.cnb.cool/seatonjiang/monolith}/mariadb:${MARIADB_VERSION:-11.8}

# 替换 Ubuntu 镜像源
ARG UBUNTU_MIRROR
RUN sed -Ei "s@(security|ports|archive).ubuntu.com@${UBUNTU_MIRROR:-mirrors.cloud.tencent.com}@g" /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update

# 安装系统依赖
RUN apt-get install -y logrotate cron && rm -rf /var/lib/apt/lists/*

# 设置日志轮转定时任务
RUN echo "0 0 * * * root logrotate -f /etc/logrotate.d/mariadb" >> /etc/crontab

# 启动 Mariadb
CMD ["mariadbd"]
