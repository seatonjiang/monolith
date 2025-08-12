ARG REDIS_VERSION
FROM redis:${REDIS_VERSION:-8.2-alpine}

# 修复 PID 文件权限问题
RUN mkdir /var/run/redis && chown redis:redis /var/run/redis

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
