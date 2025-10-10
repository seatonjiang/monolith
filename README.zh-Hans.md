# Monolith

基于 Docker 轻松构建 PHP 生产环境，集成了 OpenResty、PHP、MariaDB、Redis、Memcached 等常用服务。

## 🚀 快速入门

### 第一步：克隆仓库

```bash
git clone --depth 1 https://cnb.cool/seatonjiang/monolith.git
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
# PHP 版本
PHP_VERSION=8.4-fpm-alpine

# MariaDB 默认数据库名称
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin 访问端口
PHPMYADMIN_WEB_PORT=28080
```

> **提示**：云服务器需要在防火墙中放通 80、443 以及 phpMyAdmin 访问端口（默认端口为 28080）。

### 第三步：修改密码

修改 `secrets` 目录中的配置文件：

- `mariadb-root-pwd`：MariaDB 管理员密码（账号为 `root`）
- `mariadb-user-name`：MariaDB 用户名称（默认为 `user`）
- `mariadb-user-pwd`：MariaDB 用户密码

> **提示**：在生产环境中，请务必修改默认密码，并确保使用强密码，使用用户级权限进行访问。

### 第四步：构建容器

构建并后台运行全部容器：

```bash
docker compose up -d
```

### 第五步：网站浏览

- **本地环境**：`http://localhost`
- **线上环境**：`http://服务器 IP 地址`

> **提示**：默认站点目录为 `wwwroot/default`，为了提高安全性，在生产环境中应取消注释 `default.conf` 中的 `return 403;` 配置（`services/openresty/conf.d/default.conf`），并删除或备份默认站点目录。这样可以防止未经授权的访问和潜在的安全风险。

## 📂 目录结构

项目目录结构说明：

```bash
monolith
├── data                            数据持久化目录
│   ├── mariadb                     MariaDB 数据目录
│   └── redis                       Redis 数据目录
├── logs                            日志存储目录
│   ├── mariadb                     MariaDB 日志目录
│   ├── openresty                   OpenResty 日志目录
│   ├── php                         PHP 日志目录
│   └── redis                       Redis 日志目录
├── secrets                         密钥配置目录
│   ├── mariadb-root-pwd            MariaDB 管理员密码
│   ├── mariadb-user-name           MariaDB 用户名称
│   └── mariadb-user-pwd            MariaDB 用户密码
├── services                        服务配置目录
│   ├── mariadb                     MariaDB 配置目录
│   ├── memcached                   Memcached 配置目录
│   ├── openresty                   OpenResty 配置目录
│   ├── phpmyadmin                  phpMyAdmin 配置目录
│   ├── php                         PHP 配置目录
│   └── redis                       Redis 配置目录
├── wwwroot                         Web 服务根目录
│   └── default                     默认站点目录
├── compose.yaml                    Docker Compose 配置文件
└── env.example                     环境配置示例文件
```

## 💻 管理命令

### 管理容器

```bash
# 构建并后台运行全部容器
docker compose up -d

# 构建并后台运行指定容器（不运行 phpMyAdmin）
docker compose up -d openresty php mariadb redis memcached

# 停止全部容器并移除网络
docker compose down

# 管理指定服务（这里以 PHP 容器为例）
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

## 🔧 性能优化

### PHP 优化

可以通过修改 `services/php/php.ini` 文件根据实际情况优化 PHP 性能，下面是已经优化的内容：

```ini
# 执行时间和内存限制
max_execution_time = 180              # 脚本最大执行时间（秒）
memory_limit = 256M                   # PHP 进程可用最大内存
max_input_time = 300                  # 每个脚本解析请求数据的最大时间（秒）

# 表单和上传限制
max_input_vars = 5000                 # 最大输入变量数量
post_max_size = 65M                   # POST 数据最大尺寸
upload_max_filesize = 64M             # 上传文件最大尺寸

# 区域设置
date.timezone = Asia/Shanghai         # 时区设置

# 错误处理
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT      # 错误报告级别
error_log = /var/log/php/error.log                       # 错误日志位置
```

### MariaDB 优化

可以通过修改 `services/mariadb/mariadb.cnf` 文件根据实际情况优化 MariaDB 性能，以下是根据服务器资源的优化建议：

```ini
# 小型服务器（2GB 内存）
innodb_buffer_pool_size=256M          # InnoDB 缓冲池大小
tmp_table_size=128M                   # 内存临时表最大大小
max_heap_table_size=128M              # 用户创建的内存表最大大小

# 中型服务器（4GB 内存）
innodb_buffer_pool_size=512M          # InnoDB 缓冲池大小
tmp_table_size=256M                   # 内存临时表最大大小
max_heap_table_size=256M              # 用户创建的内存表最大大小

# 大型服务器（8GB+ 内存）
innodb_buffer_pool_size=2G            # InnoDB 缓冲池大小
tmp_table_size=512M                   # 内存临时表最大大小
max_heap_table_size=512M              # 用户创建的内存表最大大小

# 性能监控（如果是低配生产环境，在需要的时候开启）
performance_schema=ON
performance_schema_max_table_instances=400
```

### Redis 优化

可以通过修改 `services/redis/redis.conf` 文件根据实际情况优化 Redis 性能，下面是已经优化的内容：

```ini
# 网络配置
bind 0.0.0.0                  # 允许从任何 IP 地址访问 Redis 服务，Redis 服务只在内部使用，可以使用 0.0.0.0

# 持久化策略
save 900 1                    # 900 秒内至少有 1 个键被修改
save 300 10                   # 300 秒内至少有 10 个键被修改
save 60 10000                 # 60 秒内至少有 10000 个键被修改

# 安全配置
rename-command FLUSHALL ""    # 禁用清空所有数据库的命令
rename-command EVAL     ""    # 禁用执行Lua脚本的命令
rename-command FLUSHDB  ""    # 禁用清空当前数据库的命令
```

## 📦 镜像列表

### 构建的镜像

| 镜像名称 | 镜像地址 | 镜像标签 | 构建时间 |
| :--- | :--- | :--- | :--- |
| PHP 8.3 | `docker.cnb.cool/seatonjiang/monolith/php` | 8.3-fpm-alpine | 2025-10-08 |
| PHP 8.4 | `docker.cnb.cool/seatonjiang/monolith/php` | 8.4-fpm-alpine | 2025-10-08 |
| OpenResty | `docker.cnb.cool/seatonjiang/monolith/openresty` | alpine | 2025-10-06 |
| Caddy | `docker.cnb.cool/seatonjiang/monolith/caddy` | alpine | 2025-10-08 |

### 同步的镜像

| 镜像名称 | 镜像地址 | 标签 | 同步日期 |
| :--- | :--- | :--- | :--- |
| mariadb | `docker.cnb.cool/seatonjiang/monolith/mariadb` | 11.8 | 2025-10-11 |
| memcached | `docker.cnb.cool/seatonjiang/monolith/memcached` | 1.6-alpine | 2025-10-09 |
| phpmyadmin | `docker.cnb.cool/seatonjiang/monolith/phpmyadmin` | 5.2 | 2025-10-09 |
| redis | `docker.cnb.cool/seatonjiang/monolith/redis` | 8.2-alpine | 2025-10-09 |

## 📚 常见问题

<details>

<summary><strong>OpenResty 新增网站</strong></summary>

要在 OpenResty 中添加新网站，请按照以下步骤操作：

#### 第一步：创建网站配置文件

在 `services/openresty/conf.d/` 目录下创建新的配置文件，例如 `example.com.conf`：

```nginx
server {
    listen 80 reuseport;
    listen [::]:80 reuseport;

    server_name example.com;

    location / {
        return 301 https://example.com$request_uri;
    }
}

server {
    listen 443 ssl reuseport;
    listen [::]:443 ssl reuseport;
    http2 on;

    server_name example.com;
    root /var/www/example.com;
    index index.html index.php;

    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;

    access_log /var/log/nginx/example.com.access.log combined buffer=1m flush=5m;
    error_log /var/log/nginx/example.com.error.log warn;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_pass php:9000;
        include fastcgi.conf;
        include fastcgi-php.conf;
    }

    include /etc/nginx/rewrite/general.conf;
    include /etc/nginx/rewrite/security.conf;
    include /etc/nginx/rewrite/wordpress.conf;
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

</details>

<details>
<summary><strong>PHP 安装扩展</strong></summary>

进入 PHP 容器，使用 `install-php-extensions` 命令快速安装扩展：

```bash
docker exec -it php /bin/sh
install-php-extensions smbclient
```

> **提示**：支持的扩展列表请参考：[docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

</details>

<details>
<summary><strong>PHP 开启慢脚本日志</strong></summary>

修改 `services/php/www.conf` 文件，找到下面两行内容并取消注释：

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> **注意**：生产环境中建议关闭慢脚本日志，以提高性能。

</details>

<details>
<summary><strong>MariaDB 开启慢查询日志</strong></summary>

修改 `services/mariadb/mariadb.cnf` 文件，将下面参数设置为 1：

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> **注意**：生产环境建议将这些参数设置为 0，以提高性能。

</details>

<details>
<summary><strong>MariaDB 通用查询日志配置</strong></summary>

修改 `services/mariadb/mariadb.cnf` 文件，将下面参数设置为 1：

```ini
general_log=1
```

> **注意**：生产环境建议将这些参数设置为 0，以提高性能。

</details>

<details>
<summary><strong>Redis 设置密码</strong></summary>

修改 `services/redis/redis.conf` 文件，找到 `requirepass` 参数并设置密码：

```ini
requirepass your_strong_password
```

> **注意**：请使用强密码，避免使用默认密码 `foobared`。

</details>

## 🤝 参与共建

我们欢迎所有的贡献，你可以将任何想法作为 Pull Requests 或 Issues 提交。

## 📃 开源许可

项目基于 MIT 许可证发布，详细说明请参阅 [LICENSE](https://cnb.cool/seatonjiang/monolith/-/blob/main/LICENSE) 文件。
