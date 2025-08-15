# Monolith

> 基于 Docker 轻松构建 PHP 生产环境，集成了 OpenResty、PHP、MariaDB、Redis、Memcached 等常用服务。

## 🚀 快速入门

### 环境准备

在开始之前，请确保服务器已安装以下软件：

- Git
- Docker
- Docker Compose

### 第一步：克隆仓库

```bash
git clone https://cnb.cool/seatonjiang/monolith.git
```

### 第二步：编辑配置

进入项目文件夹：

```bash
cd monolith/
```

重命名环境配置文件（如果不执行此命令，将使用默认配置）：

```bash
cp env.example .env
```

编辑 `.env` 文件，根据需要修改配置：

```bash
vi .env
```

重点配置项说明：

```ini
# PHP 预装扩展库
PHP_EXTENSIONS=redis,memcached,opcache,pdo_mysql,mysqli,zip,gd,imagick,igbinary,bz2,exif,bcmath,intl

# MariaDB 默认数据库名称
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin 访问端口
PHPMYADMIN_WEB_PORT=28080
```

### 第三步：修改密码

修改 `secrets` 目录中的配置文件：

- `mariadb-root-pwd`：MariaDB 管理员密码（账号为 `root`）
- `mariadb-user-name`：MariaDB 用户名称（默认为 `user`）
- `mariadb-user-pwd`：MariaDB 用户密码

> **安全提示**：在生产环境中，请务必修改默认密码，并确保使用强密码。

### 第四步：构建容器

构建并后台运行所有容器：

```bash
docker compose up -d
```

### 第五步：网站浏览

- **本地环境**：`http://localhost`
- **线上环境**：`http://服务器 IP 地址`

> **安全提示**：默认站点目录为 `wwwroot/default`，为了提高安全性，在生产环境中应取消注释 `default.conf` 中的 `return 403;` 配置（位于 `services/openresty/conf.d/default.conf` 文件中），并删除或备份默认站点目录。这样可以防止未经授权的访问和潜在的安全风险。

## 📂 目录结构

项目目录结构说明：

```bash
monolith
├── data                      数据持久化目录
│   ├── mariadb               MariaDB 数据目录
│   └── redis                 Redis 数据目录
├── logs                      日志存储目录
│   ├── mariadb               MariaDB 日志目录
│   ├── openresty             OpenResty 日志目录
│   ├── php                   PHP 日志目录
│   └── redis                 Redis 日志目录
├── secrets                   密钥配置目录
│   ├── mariadb-root-pwd      MariaDB 管理员密码
│   ├── mariadb-user-name     MariaDB 用户名称
│   └── mariadb-user-pwd      MariaDB 用户密码
├── services                  服务配置目录
│   ├── mariadb               MariaDB 配置目录
│   ├── openresty             OpenResty 配置目录
│   ├── php                   PHP 配置目录
│   └── redis                 Redis 配置目录
├── wwwroot                   Web 服务根目录
│   └── default               默认站点目录
├── compose.yaml              Docker Compose 配置文件
└── env.example               环境配置示例文件
```

## 💻 管理命令

### 管理容器

```bash
# 构建并后台运行所有容器
docker compose up -d

# 构建并后台运行指定容器
docker compose up -d openresty php mariadb

# 停止所有容器并移除网络
docker compose down

# 管理指定服务（此处以 PHP 为例）
docker compose start php            # 启动服务
docker compose stop php             # 停止服务
docker compose restart php          # 重启服务
docker compose build php            # 重新构建服务
```

### 进入容器

运维过程中经常会使用 `docker exec -it` 进入容器，下面是常用的命令：

```bash
# 进入运行中的 PHP 容器
docker exec -it php /bin/sh

# 进入运行中的 OpenResty 容器
docker exec -it openresty /bin/sh

# 进入运行中的 MariaDB 容器
docker exec -it mariadb /bin/bash

# 进入运行中的 Redis 容器
docker exec -it redis /bin/sh

# 进入运行中的 Memcached 容器
docker exec -it memcached /bin/sh

# 进入运行中的 phpMyAdmin 容器
docker exec -it phpmyadmin /bin/bash
```

## 📚 常见问题

### OpenResty 新增网站

要在 OpenResty 中添加新网站，请按照以下步骤操作：

#### 第一步：创建网站配置文件

在 `services/openresty/conf.d/` 目录下创建新的配置文件，例如 `example.com.conf`：

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name example.com;

    # HTTP 重定向到 HTTPS
    location / {
        return 301 https://example.com$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;

    server_name example.com;
    root /var/www/example.com;
    index index.html index.php;

    # SSL 证书配置
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;

    # 日志配置
    access_log /var/log/nginx/example.com.access.log combined buffer=512k flush=1m;
    error_log /var/log/nginx/example.com.error.log warn;

    # 默认路由规则
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_pass php:9000;
        include fastcgi-php.conf;
        include fastcgi_params;
    }

    # 通用规则
    include /etc/nginx/rewrite/general.conf;
    include /etc/nginx/rewrite/security.conf;

    # 如果是 WordPress 网站，取消下面的注释
    # include /etc/nginx/rewrite/wordpress.conf;
}
```

#### 第二步：创建网站目录

在 `wwwroot` 目录下创建对应的网站目录，例如 `example.com`。

#### 第三步：配置 SSL 证书

将 SSL 证书放置在 `services/openresty/ssl/` 目录下，证书文件名称为 `example.com.crt`，私钥文件名称为 `example.com.key`。

#### 第四步：重新加载 OpenResty 配置

```bash
docker exec -it openresty nginx -s reload
```

> **提示**：可以参考 `services/openresty/conf.d/` 目录下的 `example.com.conf.example` 示例文件来创建新的网站配置。

#### 第五步：测试访问

在浏览器中输入 `https://example.com` 测试网站是否正常访问。

### PHP 安装扩展

有两种方式可以安装 PHP 扩展：

#### 方式一：通过环境变量安装（推荐）

使用 `install-php-extensions` 安装 PHP 扩展，需要在 `.env` 配置文件中修改 `PHP_EXTENSIONS` 变量，然后重新构建 PHP 容器：

```bash
# 停止并删除现有的 PHP 容器
docker compose stop php
docker compose rm -f php

# 重新构建 PHP 容器
docker compose build --no-cache php

# 启动新构建的 PHP 容器
docker compose up -d php
```

#### 方式二：进入容器快速安装

也可以直接进入 PHP 容器，使用 `install-php-extensions` 命令快速安装扩展：

```bash
docker exec -it php /bin/sh
install-php-extensions apcu
```

> **提示**：支持的扩展列表请参考：[docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

### PHP 开启慢脚本日志

修改 `services/php/www.conf` 文件，找到下面两行内容并取消注释：

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> **注意**：生产环境中建议关闭慢脚本日志，以提高性能。

### MariaDB 开启慢查询日志

修改 `services/mariadb/mariadb.cnf` 文件，将下面参数设置为 1：

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> **注意**：生产环境建议将这些参数设置为 0，以提高性能。

### Redis 设置密码

修改 `services/redis/redis.conf` 文件，找到 `requirepass` 参数并设置密码：

```ini
requirepass your_strong_password
```

> **安全提示**：请使用强密码，避免使用默认密码 `foobared`。

## 🔧 性能优化

### PHP 优化

可以通过修改 `services/php/php.ini` 文件根据实际情况优化 PHP 性能，下面是已经优化的内容：

```ini
# 执行时间和内存限制
max_execution_time = 180        # 脚本最大执行时间（秒）
memory_limit = 256M             # PHP 进程可用最大内存
max_input_time = 300            # 每个脚本解析请求数据的最大时间（秒）

# 表单和上传限制
max_input_vars = 5000                   # 最大输入变量数量
post_max_size = 65M                     # POST 数据最大尺寸
upload_max_filesize = 64M               # 上传文件最大尺寸

# 错误处理
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT   # 错误报告级别
error_log = /var/log/php/error.log                  # 错误日志位置

# 区域设置
date.timezone = Asia/Shanghai   # 时区设置
```

### MariaDB 优化

可以通过修改 `services/mariadb/mariadb.cnf` 文件根据实际情况优化 MariaDB 性能，以下是根据服务器资源的优化建议：

```ini
# 小型服务器（2GB 内存）
innodb_buffer_pool_size=256M     # InnoDB 缓冲池大小
tmp_table_size=128M              # 内存临时表最大大小
max_heap_table_size=128M         # 用户创建的内存表最大大小

# 中型服务器（4GB 内存）
innodb_buffer_pool_size=512M     # InnoDB 缓冲池大小
tmp_table_size=256M              # 内存临时表最大大小
max_heap_table_size=256M         # 用户创建的内存表最大大小

# 大型服务器（8GB+ 内存）
innodb_buffer_pool_size=2G       # InnoDB 缓冲池大小
tmp_table_size=512M              # 内存临时表最大大小
max_heap_table_size=512M         # 用户创建的内存表最大大小
```

### Redis 优化

可以通过修改 `services/redis/redis.conf` 文件根据实际情况优化 Redis 性能，下面是已经优化的内容：

```ini
# 网络配置：允许从任何 IP 地址访问 Redis 服务
bind 0.0.0.0

# 持久化策略：根据写入量自动触发 RDB 快照
# 900 秒内至少有 1 个键被修改
save 900 1
# 300 秒内至少有 10 个键被修改
save 300 10
# 60 秒内至少有 10000 个键被修改
save 60 10000

# 安全配置：禁用危险命令
# 禁用清空所有数据库的命令
rename-command FLUSHALL ""
# 禁用执行Lua脚本的命令
rename-command EVAL     ""
# 禁用清空当前数据库的命令
rename-command FLUSHDB  ""
```

## 🤝 参与共建

我们欢迎所有的贡献，你可以将任何想法作为 Pull Requests 或 Issues 提交。

## 📃 开源许可

项目基于 MIT 许可证发布，详细说明请参阅 [LICENSE](https://cnb.cool/seatonjiang/monolith/-/blob/main/LICENSE) 文件。
