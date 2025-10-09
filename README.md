# Monolith

Easily build PHP production environment based on Docker, integrating commonly used services such as OpenResty, PHP, MariaDB, Redis, Memcached.

## 🚀 Quick Start

### Step 1: Clone Repository

```bash
git clone --depth 1 https://github.com/seatonjiang/monolith.git
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

Configuration items:

```ini
# PHP version
PHP_VERSION=8.4-fpm-alpine

# MariaDB default database name
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin access port
PHPMYADMIN_WEB_PORT=28080
```

### Step 3: Modify Passwords

Modify the configuration files in the `secrets` directory:

- `mariadb-root-pwd`: MariaDB administrator password (username is `root`)
- `mariadb-user-name`: MariaDB username (default is `user`)
- `mariadb-user-pwd`: MariaDB user password

> **Tip**: In production environments, be sure to change the default passwords, ensure strong passwords are used, and access with user-level permissions.

### Step 4: Build Containers

Build and run all containers in the background:

```bash
docker compose up -d
```

### Step 5: Website Browsing

- **Local environment**: `http://localhost`
- **Online environment**: `http://server IP address`

> **Tip**: The default site directory is `wwwroot/default`. For improved security in production environments, uncomment the `return 403;` configuration in `default.conf` (`services/openresty/conf.d/default.conf`), and delete or backup the default site directory. This prevents unauthorized access and potential security risks.

## 📂 Directory Structure

Project directory structure:

```bash
monolith
├── data                            Data persistence directory
│   ├── mariadb                     MariaDB data directory
│   └── redis                       Redis data directory
├── logs                            Log storage directory
│   ├── mariadb                     MariaDB log directory
│   ├── openresty                   OpenResty log directory
│   ├── php                         PHP log directory
│   └── redis                       Redis log directory
├── secrets                         Secret configuration directory
│   ├── mariadb-root-pwd            MariaDB administrator password
│   ├── mariadb-user-name           MariaDB username
│   └── mariadb-user-pwd            MariaDB user password
├── services                        Service configuration directory
│   ├── mariadb                     MariaDB configuration directory
│   ├── memcached                   Memcached configuration directory
│   ├── openresty                   OpenResty configuration directory
│   ├── php                         PHP configuration directory
│   ├── phpmyadmin                  phpMyAdmin configuration directory
│   └── redis                       Redis configuration directory
├── wwwroot                         Web service root directory
│   └── default                     Default site directory
├── compose.yaml                    Docker Compose configuration file
└── env.example                     Environment configuration example file
```

## 💻 Management Commands

### Container Management

```bash
# Build and run all containers in the background
docker compose up -d

# Build and run specific containers (without running phpMyAdmin)
docker compose up -d openresty php mariadb redis memcached

# Stop all containers and remove network
docker compose down

# Manage specific services (using PHP container as an example)
docker compose start php            # Start service
docker compose stop php             # Stop service
docker compose restart php          # Restart service
docker compose build php            # Rebuild service
```

### Enter Containers

During operations, `docker exec -it` is often used to enter containers. Here are common commands:

```bash
# Enter running PHP container
docker exec -it php /bin/sh

# Enter running OpenResty container
docker exec -it openresty /bin/sh

# Enter running MariaDB container
docker exec -it mariadb /bin/bash

# Enter running Redis container
docker exec -it redis /bin/sh

# Enter running Memcached container
docker exec -it memcached /bin/sh

# Enter running phpMyAdmin container
docker exec -it phpmyadmin /bin/bash
```

## 🔧 Performance Optimization

### PHP Optimization

You can optimize PHP performance by modifying the `services/php/php.ini` file according to your actual situation. Below are the optimized contents:

```ini
# Execution time and memory limits
max_execution_time = 180              # Maximum script execution time (seconds)
memory_limit = 256M                   # Maximum memory available for PHP processes
max_input_time = 300                  # Maximum time for each script to parse request data (seconds)

# Form and upload limits
max_input_vars = 5000                 # Maximum number of input variables
post_max_size = 65M                   # Maximum POST data size
upload_max_filesize = 64M             # Maximum upload file size

# Regional settings
date.timezone = Asia/Shanghai         # Timezone setting

# Error handling
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT      # Error reporting level
error_log = /var/log/php/error.log                       # Error log location
```

### MariaDB Optimization

You can optimize MariaDB performance by modifying the `services/mariadb/mariadb.cnf` file according to your actual situation. Below are optimization suggestions based on server resources:

```ini
# Small server (2GB memory)
innodb_buffer_pool_size=256M          # InnoDB buffer pool size
tmp_table_size=128M                   # Maximum size for in-memory temporary tables
max_heap_table_size=128M              # Maximum size for user-created memory tables

# Medium server (4GB memory)
innodb_buffer_pool_size=512M          # InnoDB buffer pool size
tmp_table_size=256M                   # Maximum size for in-memory temporary tables
max_heap_table_size=256M              # Maximum size for user-created memory tables

# Large server (8GB+ memory)
innodb_buffer_pool_size=2G            # InnoDB buffer pool size
tmp_table_size=512M                   # Maximum size for in-memory temporary tables
max_heap_table_size=512M              # Maximum size for user-created memory tables

# Performance monitoring (enable when needed in low-spec production environments)
performance_schema=ON
performance_schema_max_table_instances=400
```

### Redis Optimization

You can optimize Redis performance by modifying the `services/redis/redis.conf` file according to your actual situation. Below are the optimized contents:

```ini
# Network configuration
bind 0.0.0.0                  # Allow Redis service access from any IP address, Redis service is only used internally, can use 0.0.0.0

# Persistence strategy
save 900 1                    # At least 1 key modified within 900 seconds
save 300 10                   # At least 10 keys modified within 300 seconds
save 60 10000                 # At least 10000 keys modified within 60 seconds

# Security configuration
rename-command FLUSHALL ""    # Disable command to clear all databases
rename-command EVAL     ""    # Disable command to execute Lua scripts
rename-command FLUSHDB  ""    # Disable command to clear current database
```

## 📦 Image List

### Built Images

| Name | Registry | Tag | Build Date |
| :--- | :--- | :--- | :--- |
| PHP 8.3 | `ghcr.io/seatonjiang/php` | 8.3-fpm-alpine | 2025-10-08 |
| PHP 8.4 | `ghcr.io/seatonjiang/php` | 8.4-fpm-alpine | 2025-10-08 |
| OpenResty | `ghcr.io/seatonjiang/openresty` | alpine | 2025-10-06 |
| Caddy | `ghcr.io/seatonjiang/caddy` | alpine | 2025-10-08 |

### Synced Images

| Name | Registry | Tags | Sync Date |
| :--- | :--- | :--- | :--- |
| mariadb | `ghcr.io/seatonjiang/mariadb` | 11.8 | 2025-10-06 |
| memcached | `ghcr.io/seatonjiang/memcached` | 1.6-alpine | 2025-10-09 |
| phpmyadmin | `ghcr.io/seatonjiang/phpmyadmin` | 5.2 | 2025-10-09 |
| redis | `ghcr.io/seatonjiang/redis` | 8.2-alpine | 2025-10-09 |

## 📚 Common Questions

<details>

<summary><strong>Adding New Website to OpenResty</strong></summary>

To add a new website in OpenResty, follow these steps:

#### Step 1: Create Website Configuration File

Create a new configuration file in the `services/openresty/conf.d/` directory, for example `example.com.conf`:

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

Enter `https://example.com` in your browser to test if the website is accessible.

</details>

<details>
<summary><strong>Installing PHP Extensions</strong></summary>

Enter the PHP container and use the `install-php-extensions` command to quickly install extensions:

```bash
docker exec -it php /bin/sh
install-php-extensions smbclient
```

> **Tip**: For a list of supported extensions, please refer to: [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

</details>

<details>
<summary><strong>Enabling PHP Slow Script Logging</strong></summary>

Modify the `services/php/www.conf` file, find the following two lines and uncomment them:

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> **Note**: In production environments, it is recommended to disable slow script logging to improve performance.

</details>

<details>
<summary><strong>Enabling MariaDB Slow Query Logging</strong></summary>

Modify the `services/mariadb/mariadb.cnf` file, set the following parameters to 1:

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> **Note**: In production environments, it is recommended to set these parameters to 0 to improve performance.

</details>

<details>
<summary><strong>MariaDB General Query Log Configuration</strong></summary>

Modify the `services/mariadb/mariadb.cnf` file, set the following parameter to 1:

```ini
general_log=1
```

> **Note**: In production environments, it is recommended to set these parameters to 0 to improve performance.

</details>

<details>
<summary><strong>Setting Redis Password</strong></summary>

Modify the `services/redis/redis.conf` file, find the `requirepass` parameter and set the password:

```ini
requirepass your_strong_password
```

> **Note**: Please use a strong password and avoid using the default password `foobared`.

</details>

## 🤝 Contributing

We welcome all contributions. You can submit any ideas as Pull requests or as Issues, have a good time!

## 📃 License

The project is released under the MIT License, see the [LICENSE](https://github.com/seatonjiang/monolith/blob/main/LICENSE) file for details.
