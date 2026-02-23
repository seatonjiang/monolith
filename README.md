# Monolith

基于 Docker 轻松构建现代 PHP 应用服务器，集成了 Caddy、PHP、MariaDB、Redis、Memcached 等服务。

## 🚀 快速入门

### 第一步：克隆仓库

国外用户可以使用 GitHub 克隆仓库：

```bash
git clone --depth 1 https://github.com/seatonjiang/monolith.git
```

国内用户可以使用 CNB 克隆仓库：

```bash
git clone --depth 1 https://cnb.cool/seatonjiang/monolith.git
```

### 第二步：编辑配置

进入项目文件夹：

```bash
cd monolith/
```

重命名环境配置文件：

```bash
cp env.example .env
```

编辑 `.env` 文件，根据需要修改配置：

```bash
vi .env
```

重点配置项：

```ini
# PHP 版本
PHP_VERSION=8.5-fpm-alpine

# MariaDB 默认数据库名称
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin 访问端口
PHPMYADMIN_WEB_PORT=28080
```

> 提示：云服务器需要在防火墙中放通 80、443 以及 phpMyAdmin 访问端口（默认为 28080）。

### 第三步：修改密码

修改 `secrets` 目录中的配置文件：

- `mariadb-root-pwd`：MariaDB 管理员密码（账号为 `root`）
- `mariadb-user-name`：MariaDB 用户名称（默认为 `monolith`）
- `mariadb-user-pwd`：MariaDB 用户密码

> 提示：在生产环境中，请务必修改默认密码，并确保使用强密码，使用用户级权限进行访问。

### 第四步：构建容器

构建并后台运行全部容器：

```bash
docker compose up -d
```

### 第五步：网站浏览

- 本地环境：`http://127.0.0.1`
- 线上环境：`http://<服务器 IP 地址>`

### 第六步：安全清理

默认站点目录为 `wwwroot/default`，测试完成后请立即删除该目录及 `services/caddy/Caddyfile.d/monolith.caddyfile` 配置文件，避免暴露配置信息。

## 📦 镜像列表

### 构建的镜像

| 镜像名称 | 官方镜像 | 分发镜像 | 镜像标签 | 构建时间 |
| :--- | :--- | :--- | :--- | :--- |
| Caddy | `seatonjiang/caddy` | `ghcr.io/seatonjiang/caddy` <br> `docker.cnb.cool/seatonjiang/monolith/caddy` | alpine | 2026-02-23 |
| PHP 8.3 | `seatonjiang/php` | `ghcr.io/seatonjiang/php` <br> `docker.cnb.cool/seatonjiang/monolith/php` | 8.3-fpm-alpine | 2026-02-23 |
| PHP 8.4 | `seatonjiang/php` | `ghcr.io/seatonjiang/php` <br> `docker.cnb.cool/seatonjiang/monolith/php` | 8.4-fpm-alpine | 2026-02-16 |
| PHP 8.5 | `seatonjiang/php` | `ghcr.io/seatonjiang/php` <br> `docker.cnb.cool/seatonjiang/monolith/php` | 8.5-fpm-alpine | 2026-02-16 |

### 同步的镜像

| 镜像名称 | 官方镜像 | 分发镜像 | 镜像标签 | 同步日期 |
| :--- | :--- | :--- | :--- | :--- |
| mariadb | `seatonjiang/mariadb` | `ghcr.io/seatonjiang/mariadb` <br> `docker.cnb.cool/seatonjiang/monolith/mariadb` | 11.4,11.8 | 2026-02-19 |
| memcached | `seatonjiang/memcached` | `ghcr.io/seatonjiang/memcached` <br> `docker.cnb.cool/seatonjiang/monolith/memcached` | 1.6-alpine | 2026-01-30 |
| phpmyadmin | `seatonjiang/phpmyadmin` | `ghcr.io/seatonjiang/phpmyadmin` <br> `docker.cnb.cool/seatonjiang/monolith/phpmyadmin` | 5.2 | 2026-02-07 |
| redis | `seatonjiang/redis` | `ghcr.io/seatonjiang/redis` <br> `docker.cnb.cool/seatonjiang/monolith/redis` | 8.4-alpine | 2026-02-12 |

## 📂 目录结构

项目目录结构说明：

```bash
monolith
├── data                            数据持久化目录
│   ├── caddy                       Caddy 数据目录
│   ├── mariadb                     MariaDB 数据目录
│   └── redis                       Redis 数据目录
├── logs                            日志存储目录
│   ├── caddy                       Caddy 日志目录
│   ├── mariadb                     MariaDB 日志目录
│   ├── php                         PHP 日志目录
│   └── redis                       Redis 日志目录
├── secrets                         密钥配置目录
│   ├── mariadb-root-pwd            MariaDB 管理员密码
│   ├── mariadb-user-name           MariaDB 用户名称
│   └── mariadb-user-pwd            MariaDB 用户密码
├── services                        服务配置目录
│   ├── caddy                       Caddy 配置目录
│   ├── mariadb                     MariaDB 配置目录
│   ├── memcached                   Memcached 配置目录
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

# 构建并后台运行指定容器（不运行 phpMyAdmin 容器）
docker compose up -d caddy php mariadb redis memcached

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

# 进入运行中的 Caddy 容器
docker exec -it caddy /bin/sh

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

## 📚 常见问题

### Caddy 新增网站

要在 Caddy 中添加新网站，请按照以下步骤操作：

#### 第一步：编辑网站配置文件

在 `services/caddy/Caddyfile.d/` 目录添加新的网站配置文件，例如 `example.com.caddyfile`，并在文件中添加新的网站配置，例如：

```caddyfile
example.com {
    # 日志配置
    import log example.com
    # 安全配置
    import security
    # 缓存配置
    import static
    # 压缩配置
    import encode

    # 网站目录
    root * /var/www/example.com

    # 本地 SSL 证书
    tls /etc/caddy/ssl/example.com.crt /etc/caddy/ssl/example.com.key

    # PHP-FPM 配置
    php_fastcgi php:9000
    # 文件服务器配置
    file_server
}
```

> 提示：更多配置说明可以参考 [Caddy 官方文档](https://caddyserver.com/docs/caddyfile)，如果是 WordPress 网站可以添加 `import wordpress` 配置。

#### 第二步：创建网站目录

在 `wwwroot` 目录下创建对应的网站目录，例如 `example.com`。

#### 第三步：重新加载

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### 第四步：测试访问

在浏览器中输入 `https://example.com` 测试网站是否正常访问。

### Caddy 自动配置 SSL 证书

要在 Caddy 中自动配置 SSL 证书（以 `example.com` 域名为例），请按照以下步骤操作：

#### 第一步：添加证书配置

在 `services/caddy/Caddyfile.d/example.com.caddyfile` 文件中添加证书配置，如果已经手动配置了证书，需要将 `tls` 部分改为以下内容：

```caddyfile
example.com {
    ...
    # 手动配置证书（如果已配置证书，需要将这行注释掉）
    # tls /etc/caddy/ssl/example.com.crt /etc/caddy/ssl/example.com.key

    # 自动配置证书（以腾讯云 DNS 为例）
    tls name@example.com {
        dns tencentcloud {
            secret_id <TENCENTCLOUD_SECRET_ID>
            secret_key <TENCENTCLOUD_SECRET_KEY>
        }
    }
    ...
}
```

Monolith 的 Caddy 镜像编译了以下 DNS 模块：

- `dns.providers.tencentcloud`
- `dns.providers.alidns`
- `dns.providers.route53`
- `dns.providers.cloudflare`
- `dns.providers.godaddy`
- `dns.providers.digitalocean`

可以根据实际情况选择不同的 DNS 提供商，以下是各个供应商的配置示例：

```caddyfile
# 腾讯云 DNS
dns tencentcloud {
    secret_id <TENCENTCLOUD_SECRET_ID>
    secret_key <TENCENTCLOUD_SECRET_KEY>
}

# 阿里云 DNS
dns alidns {
    access_key_id <ALIYUN_ACCESS_KEY_ID>
    access_key_secret <ALIYUN_ACCESS_KEY_SECRET>
}

# Route53 DNS
dns route53 {
    access_key_id <AWS_ACCESS_KEY_ID>
    secret_access_key <AWS_SECRET_ACCESS_KEY>
}

# Cloudflare DNS
dns cloudflare <CF_API_TOKEN>

# Godaddy DNS
dns godaddy {
    api_token <GODADDY_API_TOKEN>
}

# DigitalOcean DNS
dns digitalocean <DIGITALOCEAN_API_TOKEN>
```

#### 第二步：重新加载

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### 第三步：测试访问

在浏览器中输入 `https://example.com` 测试网站是否正常访问。

### Caddy 使用 Google Trust Services 签发证书

要使用 Google Trust Services 签发证书，请按照以下步骤操作：

#### 第一步：获取 EAB 密钥

通过 [Google Cloud Shell](https://console.cloud.google.com/welcome) 获取 EAB 密钥，执行以下命令：

```bash
gcloud publicca external-account-keys create
```

> 提示：在获得 EAB 密钥后的 7 天内需要使用该密钥，如果 7 天内未使用密钥将会过期。但使用 EAB 密钥注册的 ACME 账号没有到期时间。

#### 第二步：添加 EAB 密钥到 Caddyfile

在 `services/caddy/Caddyfile` 文件中取消注释并添加获取到的 EAB 密钥配置，例如：

```caddyfile
# 使用 Google Trust Services 签发证书
acme_ca https://dv.acme-v02.api.pki.goog/directory
acme_eab {
    key_id cea2c36a8r7eae1009df9688ed320315
    mac_key xE3fSdsfDS32rfds2KMq0zyGFfd34T3crvyYe-q1CLLsV0w-U7Dimy0fdsaf0Qt0lwYgwfnWOWyqYz
}
```

#### 第三步：重新加载

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### 第四步：测试访问

在浏览器中输入 `https://example.com` 测试网站是否正常访问并查看证书颁发者。

### PHP 安装扩展

进入 PHP 容器，使用 `install-php-extensions` 命令快速安装扩展：

```bash
docker exec -it php /bin/sh
install-php-extensions smbclient
```

> 提示：支持的扩展列表参考 [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

### PHP 开启慢脚本日志

修改 `services/php/www.conf` 文件，找到下面两行内容并取消注释：

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> 提示：生产环境中建议关闭慢脚本日志，以提高性能。

### MariaDB 开启慢查询日志

修改 `services/mariadb/mariadb.cnf` 文件，将以下两个参数设置为 1：

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> 提示：生产环境建议将这些参数设置为 0，以提高性能。

### MariaDB 通用查询日志配置

修改 `services/mariadb/mariadb.cnf` 文件，找到 `general_log` 参数并设置为 1：

```ini
general_log=1
```

> 提示：生产环境建议将这些参数设置为 0，以提高性能。

### Redis 设置密码

修改 `services/redis/redis.conf` 文件，找到 `requirepass` 参数并设置密码：

```ini
requirepass your_strong_password
```

> 提示：请使用强密码，避免使用默认密码 `foobared`。

## 💖 项目支持

如果这个项目为你带来了便利，请考虑为这个项目点个 Star 或者通过微信赞赏码支持我，每一份支持都是我持续优化和添加新功能的动力源泉！

<div align="center">
    <b>微信赞赏码</b>
    <br>
    <img src=".github/assets/wechat-reward.png" width="230">
</div>

## 🤝 参与共建

我们欢迎所有的贡献，你可以将任何想法作为 [Pull Requests](https://github.com/seatonjiang/monolith/pulls) 或 [Issues](https://github.com/seatonjiang/monolith/issues) 提交。

## 📃 开源许可

项目基于 MIT 许可证发布，详细说明请参阅 [LICENSE](https://github.com/seatonjiang/monolith/blob/main/LICENSE) 文件。
