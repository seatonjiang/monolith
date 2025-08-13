# Monolith

> Easily build PHP production environment based on Docker, integrating common services such as OpenResty, PHP, MariaDB, Redis, Memcached, etc.

## 🚀 Quick Start

### Environment Preparation

Before starting, please ensure the following software is installed on your server:

- Git
- Docker
- Docker Compose

### Step 1: Clone Repository

```bash
git clone https://github.com/seatonjiang/monolith.git
```

### Step 2: Edit Configuration

Enter the project folder:

```bash
cd monolith/
```

Rename the environment configuration file (if you don't execute this command, the default configuration will be used):

```bash
cp env.example .env
```

Edit the `.env` file and modify the configuration as needed:

```bash
vi .env
```

Key configuration items explanation:

```ini
# PHP pre-installed extensions
PHP_EXTENSIONS=redis,memcached,opcache,pdo_mysql,mysqli,zip,gd,imagick,igbinary,bz2,exif,bcmath,intl

# MariaDB default database name
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin access port
PHPMYADMIN_WEB_PORT=28080
```

### Step 3: Modify Passwords

Modify the configuration files in the `secrets` directory:

- `mariadb-root-pwd`: MariaDB administrator password (account is `root`)
- `mariadb-user-name`: MariaDB username (default is `user`)
- `mariadb-user-pwd`: MariaDB user password

> **Security Tip**: In production environments, be sure to change the default passwords and ensure strong passwords are used.

### Step 4: Build Containers

Build and run all containers in the background:

```bash
docker compose up -d
```

### Step 5: Website Browsing

- **Local Environment**: `http://localhost`
- **Online Environment**: `http://Server IP Address`

> **Security Tip**: The default site directory is `wwwroot/default`. For enhanced security in production environments, uncomment the `return 403;` configuration in `default.conf` (located in the `services/openresty/conf.d/default.conf` file), and delete or backup the default site directory. This prevents unauthorized access and potential security risks.

## 📂 Directory Structure

Project directory structure explanation:

```bash
monolith
├── data                      Data persistence directory
│   ├── composer              Composer data directory
│   ├── mariadb               MariaDB data directory
│   └── redis                 Redis data directory
├── logs                      Log storage directory
│   ├── mariadb               MariaDB log directory
│   ├── openresty             OpenResty log directory
│   ├── php                   PHP log directory
│   └── redis                 Redis log directory
├── secrets                   Secret configuration directory
│   ├── mariadb-root-pwd      MariaDB administrator password
│   ├── mariadb-user-name     MariaDB username
│   └── mariadb-user-pwd      MariaDB user password
├── services                  Service configuration directory
│   ├── mariadb               MariaDB configuration directory
│   ├── openresty             OpenResty configuration directory
│   ├── php                   PHP configuration directory
│   └── redis                 Redis configuration directory
├── wwwroot                   Web service root directory
│   └── default               Default site directory
├── compose.yaml              Docker Compose configuration file
└── env.example               Environment configuration example file
```

## 💻 Management Commands

### Container Management

```bash
# Build and run all containers in the background
docker compose up -d

# Build and run specific containers in the background
docker compose up -d openresty php mariadb

# Stop all containers and remove networks
docker compose down

# Manage specific services (using PHP as an example)
docker compose start php            # Start service
docker compose stop php             # Stop service
docker compose restart php          # Restart service
docker compose build php            # Rebuild service
```

### Entering Containers

During operations, `docker exec -it` is frequently used to enter containers. Here are common commands:

```bash
# Enter the running PHP container
docker exec -it php /bin/sh

# Enter the running OpenResty container
docker exec -it openresty /bin/sh

# Enter the running MariaDB container
docker exec -it mariadb /bin/bash

# Enter the running Redis container
docker exec -it redis /bin/sh

# Enter the running Memcached container
docker exec -it memcached /bin/sh

# Enter the running phpMyAdmin container
docker exec -it phpmyadmin /bin/bash
```

## 📚 Common Issues

### Adding New Website to OpenResty

To add a new website in OpenResty, follow these steps:

#### Step 1: Create Website Configuration File

Create a new configuration file in the `services/openresty/conf.d/` directory, for example `example.com.conf`:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name example.com;

    # HTTP redirect to HTTPS
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

    # SSL certificate configuration
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;

    # Log configuration
    access_log /var/log/nginx/example.com.access.log combined buffer=512k flush=1m;
    error_log /var/log/nginx/example.com.error.log warn;

    # Default routing rules
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_pass php:9000;
        include fastcgi-php.conf;
        include fastcgi_params;
    }

    # General rules
    include /etc/nginx/rewrite/general.conf;
    include /etc/nginx/rewrite/security.conf;

    # If it's a WordPress website, uncomment the line below
    # include /etc/nginx/rewrite/wordpress.conf;
}
```

#### Step 2: Create Website Directory

Create the corresponding website directory in the `wwwroot` directory, for example `example.com`.

#### Step 3: Configure SSL Certificate

Place the SSL certificate in the `services/openresty/ssl/` directory, with the certificate file named `example.com.crt` and the private key file named `example.com.key`.

#### Step 4: Reload OpenResty Configuration

```bash
docker exec -it openresty nginx -s reload
```

> **Tip**: You can refer to the `example.com.conf.example` example file in the `services/openresty/conf.d/` directory to create a new website configuration.

#### Step 5: Test Access

Enter `https://example.com` in your browser to test if the website is accessible normally.

### Installing PHP Extensions

There are two ways to install PHP extensions:

#### Method 1: Install via Environment Variables (Recommended)

Use `install-php-extensions` to install PHP extensions by modifying the `PHP_EXTENSIONS` variable in the `.env` configuration file, then rebuild the PHP container:

```bash
docker compose build php
```

#### Method 2: Quick Installation by Entering the Container

You can also directly enter the PHP container and use the `install-php-extensions` command to quickly install extensions:

```bash
docker exec -it php /bin/sh
install-php-extensions apcu
```

> **Tip**: For a list of supported extensions, please refer to: [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

### Composer Mirror Repository

#### Default Mirror

By default, the Tencent Cloud mirror (mirrors.cloud.tencent.com) is used, which is a unified domain for both public and internal networks, solving access issues in different network environments:

- If in a public network environment, it will automatically access through the public network.
- If in a Tencent Cloud VPC internal environment with default cloud DNS configuration, it will prioritize resolving to the internal network link, providing more stable and faster service.

#### Changing Mirror

To change the mirror, for example to the Shanghai Jiao Tong University mirror, execute the following commands:

```bash
docker exec -it php /bin/sh
composer config -g repos.packagist composer https://packagist.mirrors.sjtug.sjtu.edu.cn
```

### Enabling PHP Slow Script Logging

Modify the `services/php/www.conf` file, find the following two lines and uncomment them:

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> **Note**: In production environments, it is recommended to disable slow script logging to improve performance.

### Enabling MariaDB Slow Query Logging

Modify the `services/mariadb/mariadb.cnf` file, set the following parameters to 1:

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> **Note**: In production environments, it is recommended to set these parameters to 0 to improve performance.

### Setting Redis Password

Modify the `services/redis/redis.conf` file, find the `requirepass` parameter and set the password:

```ini
requirepass your_strong_password
```

> **Security Tip**: Please use a strong password and avoid using the default password `foobared`.

## 🔧 Performance Optimization

### PHP Optimization

You can optimize PHP performance by modifying the `services/php/php.ini` file according to your actual situation. Here are the already optimized contents:

```ini
# Execution time and memory limits
max_execution_time = 300        # Maximum script execution time (seconds)
memory_limit = 256M             # Maximum memory available for PHP processes

# Form and upload limits
max_input_vars = 5000           # Maximum number of input variables
post_max_size = 256M            # Maximum POST data size
upload_max_filesize = 256M      # Maximum upload file size

# Error handling
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT   # Error reporting level
error_log = /var/log/php/error.log                    # Error log location

# Region settings
date.timezone = Asia/Shanghai   # Timezone setting
```

### MariaDB Optimization

You can optimize MariaDB performance by modifying the `services/mariadb/mariadb.cnf` file according to your actual situation. Here are optimization suggestions based on server resources:

```ini
# Small server (2GB memory)
innodb_buffer_pool_size=256M     # InnoDB buffer pool size
tmp_table_size=128M              # Maximum size of in-memory temporary tables
max_heap_table_size=128M         # Maximum size of user-created memory tables

# Medium server (4GB memory)
innodb_buffer_pool_size=512M     # InnoDB buffer pool size
tmp_table_size=256M              # Maximum size of in-memory temporary tables
max_heap_table_size=256M         # Maximum size of user-created memory tables

# Large server (8GB+ memory)
innodb_buffer_pool_size=2G       # InnoDB buffer pool size
tmp_table_size=512M              # Maximum size of in-memory temporary tables
max_heap_table_size=512M         # Maximum size of user-created memory tables
```

### Redis Optimization

You can optimize Redis performance by modifying the `services/redis/redis.conf` file according to your actual situation. Here are the already optimized contents:

```ini
# Network configuration: Allow Redis service access from any IP address
bind 0.0.0.0

# Persistence strategy: Automatically trigger RDB snapshots based on write volume
# At least 1 key modified within 900 seconds
save 900 1
# At least 10 keys modified within 300 seconds
save 300 10
# At least 10000 keys modified within 60 seconds
save 60 10000

# Security configuration: Disable dangerous commands
# Disable command to clear all databases
rename-command FLUSHALL ""
# Disable command to execute Lua scripts
rename-command EVAL     ""
# Disable command to clear current database
rename-command FLUSHDB  ""
```

## 🤝 Contributing

We welcome all contributions. You can submit any ideas as Pull Requests or Issues.

## 📃 License

The project is released under the MIT License. For detailed information, please refer to the [LICENSE](https://github.com/seatonjiang/monolith/blob/main/LICENSE) file.