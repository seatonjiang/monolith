# Monolith

Easily build PHP production environments based on Docker, integrating commonly used services such as OpenResty, Caddy, PHP, MariaDB, Redis, Memcached.

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

Rename the environment configuration file (if you don't execute this command, default configuration will be used):

```bash
cp env.example .env
```

Edit the `.env` file and modify the configuration as needed:

```bash
vi .env
```

Key configuration items:

```ini
# PHP Version
PHP_VERSION=8.4-fpm-alpine

# MariaDB Default Database Name
MARIADB_DATABASE_NAME=monolith

# phpMyAdmin Access Port
PHPMYADMIN_WEB_PORT=28080
```

> Tip: Cloud servers need to open ports 80, 443, and phpMyAdmin access port (default 28080) in the firewall.

### Step 3: Modify Passwords

Modify the configuration files in the `secrets` directory:

- `mariadb-root-pwd`: MariaDB administrator password (username: `root`)
- `mariadb-user-name`: MariaDB username (default: `user`)
- `mariadb-user-pwd`: MariaDB user password

> Tip: In production environments, be sure to modify default passwords and ensure strong passwords are used, with user-level permissions for access.

### Step 4: Build Containers

Build and run all containers in the background:

```bash
docker compose up -d
```

> Tip: OpenResty is used as the web server by default. If you need to use Caddy as the web server, please modify the relevant configuration in `compose.yaml`.

### Step 5: Website Browsing

- **Local Environment**: `http://localhost`
- **Online Environment**: `http://Server IP Address`

### Step 6: Security Cleanup

- The default site directory is `wwwroot/default`. Please delete this directory and corresponding configuration immediately after testing to avoid exposing default pages.
- If using OpenResty as the web server, edit the `services/openresty/conf.d/default.conf` file, delete test environment configuration and write production environment configuration.
- If using Caddy as the web server, edit the `services/caddy/Caddyfile` file, delete test environment configuration and write production environment configuration.

## 📂 Directory Structure

Project directory structure description:

```bash
monolith
├── data                            Data persistence directory
│   ├── caddy                       Caddy data directory
│   ├── mariadb                     MariaDB data directory
│   └── redis                       Redis data directory
├── logs                            Log storage directory
│   ├── caddy                       Caddy log directory
│   ├── mariadb                     MariaDB log directory
│   ├── openresty                   OpenResty log directory
│   ├── php                         PHP log directory
│   └── redis                       Redis log directory
├── secrets                         Secret configuration directory
│   ├── mariadb-root-pwd            MariaDB administrator password
│   ├── mariadb-user-name           MariaDB username
│   └── mariadb-user-pwd            MariaDB user password
├── services                        Service configuration directory
│   ├── caddy                       Caddy configuration directory
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

# Build and run specified containers in the background (without running Caddy and phpMyAdmin)
docker compose up -d openresty php mariadb redis memcached

# Stop all containers and remove networks
docker compose down

# Manage specified services (using PHP container as example)
docker compose start php            # Start service
docker compose stop php             # Stop service
docker compose restart php          # Restart service
docker compose build php            # Rebuild service
```

### Enter Containers

During operations, `docker exec -it` is frequently used to enter containers. Here are common commands:

```bash
# Enter running PHP container
docker exec -it php /bin/sh

# Enter running OpenResty container
docker exec -it openresty /bin/sh

# Enter running Caddy container
docker exec -it caddy /bin/sh

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

You can optimize PHP performance by modifying the `services/php/php.ini` file according to actual conditions. Here are the optimized contents:

```ini
# Execution time and memory limits
max_execution_time = 180              # Maximum script execution time (seconds)
memory_limit = 256M                   # Maximum memory available to PHP processes
max_input_time = 300                  # Maximum time for each script to parse request data (seconds)

# Form and upload limits
max_input_vars = 5000                 # Maximum number of input variables
post_max_size = 65M                   # Maximum size of POST data
upload_max_filesize = 64M             # Maximum upload file size

# Locale settings
date.timezone = Asia/Shanghai         # Timezone setting

# Error handling
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT      # Error reporting level
error_log = /var/log/php/error.log                       # Error log location
```

### MariaDB Optimization

You can optimize MariaDB performance by modifying the `services/mariadb/mariadb.cnf` file according to actual conditions. Here are optimization recommendations based on server resources:

```ini
# Small server (2GB memory)
innodb_buffer_pool_size=256M          # InnoDB buffer pool size
tmp_table_size=128M                   # Maximum size of memory temporary tables
max_heap_table_size=128M              # Maximum size of user-created memory tables

# Medium server (4GB memory)
innodb_buffer_pool_size=512M          # InnoDB buffer pool size
tmp_table_size=256M                   # Maximum size of memory temporary tables
max_heap_table_size=256M              # Maximum size of user-created memory tables

# Large server (8GB+ memory)
innodb_buffer_pool_size=2G            # InnoDB buffer pool size
tmp_table_size=512M                   # Maximum size of memory temporary tables
max_heap_table_size=512M              # Maximum size of user-created memory tables

# Performance monitoring (enable when needed in low-spec production environments)
performance_schema=ON
performance_schema_max_table_instances=400
```

### Redis Optimization

You can optimize Redis performance by modifying the `services/redis/redis.conf` file according to actual conditions. Here are the optimized contents:

```ini
# Network configuration
bind 0.0.0.0                  # Allow access to Redis service from any IP address, Redis service is only used internally, can use 0.0.0.0

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
| PHP 8.3 | `ghcr.io/seatonjiang/php` | 8.3-fpm-alpine | 2025-10-13 |
| PHP 8.4 | `ghcr.io/seatonjiang/php` | 8.4-fpm-alpine | 2025-10-13 |
| OpenResty | `ghcr.io/seatonjiang/openresty` | alpine | 2025-10-06 |
| Caddy | `ghcr.io/seatonjiang/caddy` | alpine | 2025-10-14 |

### Synced Images

| Name | Registry | Tags | Sync Date |
| :--- | :--- | :--- | :--- |
| mariadb | `ghcr.io/seatonjiang/mariadb` | 11.8 | 2025-10-11 |
| memcached | `ghcr.io/seatonjiang/memcached` | 1.6-alpine | 2025-10-09 |
| phpmyadmin | `ghcr.io/seatonjiang/phpmyadmin` | 5.2 | 2025-10-09 |
| redis | `ghcr.io/seatonjiang/redis` | 8.2-alpine | 2025-10-12 |

## 📚 FAQ

<details>

<summary><strong>Adding New Website in OpenResty</strong></summary>

To add a new website in OpenResty, please follow these steps:

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

Place SSL certificates in the `services/openresty/ssl/` directory, with certificate file named `example.com.crt` and private key file named `example.com.key`.

#### Step 4: Reload OpenResty Configuration

```bash
docker exec -it openresty nginx -s reload
```

> Tip: You can refer to the `example.com.conf.example` example file in the `services/openresty/conf.d/` directory to create new website configurations.

#### Step 5: Test Access

Enter `https://example.com` in your browser to test if the website is accessible normally.

</details>

<details>
<summary><strong>Adding New Website in Caddy</strong></summary>

To add a new website in Caddy, please follow these steps:

#### Step 1: Edit Website Configuration File

Add new website configuration in the `services/caddy/Caddyfile` file, for example:

```caddy
http://example.com {
    redir https://example.com{uri} permanent
        header {
        -Server
        -Via
    }
}

example.com {
    log {
        output file /var/log/caddy/example.com.log {
            roll_size 100mb
            roll_keep 5
            roll_keep_for 720h
        }
        format json
        level WARN
    }

    root * /var/www/example.com

    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'self'; object-src 'none'; base-uri 'self'"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=()"
        -Server
        -Via
    }

    tls /config/ssl/example.com.pem /config/ssl/example.com.pem

    encode {
        gzip 6
        zstd
        minimum_length 1024
        match {
            header Content-Type text/*
            header Content-Type application/json*
            header Content-Type application/javascript*
            header Content-Type application/xml*
            header Content-Type image/svg+xml*
        }
    }

    @static {
        file
        path *.css *.js *.png *.jpg *.jpeg *.gif *.ico *.svg *.woff *.woff2 *.ttf *.eot *.webp
    }
    header @static {
        Cache-Control "public, max-age=31536000, immutable"
        Vary "Accept-Encoding"
    }

    @forbidden {
        path /.* /composer.* /package.* *.log *.bak *.backup *.sql *.env*
    }
    respond @forbidden 403

    php_fastcgi php:9000 {
        env PHP_ADMIN_VALUE "open_basedir=/var/www/example.com:/tmp"
        env PHP_ADMIN_VALUE "disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"
        read_timeout 30s
        write_timeout 30s
        dial_timeout 3s
        index index.php
    }

    file_server {
        hide .htaccess .env .git .gitignore composer.json composer.lock package.json
        index index.php index.html index.htm
    }
}
```

> Tip: For more configuration instructions, please refer to the official Caddy documentation [Caddy Documentation](https://caddyserver.com/docs/caddyfile)

#### Step 2: Create Website Directory

Create the corresponding website directory in the `wwwroot` directory, for example `example.com`.

#### Step 3: Reload

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### Step 4: Test Access

Enter `https://example.com` in your browser to test if the website is accessible normally.

</details>

<details>
<summary><strong>Caddy Automatic SSL Certificate Configuration</strong></summary>

To automatically configure SSL certificates in Caddy, please follow these steps:

#### Step 1: Add Domain Configuration

Add configuration in the specified domain in the `services/caddy/Caddyfile` file. If you have manually configured certificates, you need to change the `tls` section to the following:

```caddy
example.com {
    ...
    # Manual certificate configuration (if certificates are already configured, this line needs to be commented out)
    # tls /config/ssl/example.com.pem /config/ssl/example.com.pem

    # Automatic certificate configuration (using Tencent Cloud DNS as example)
    tls {
        dns tencentcloud {
            secret_id <TENCENTCLOUD_SECRET_ID>
            secret_key <TENCENTCLOUD_SECRET_KEY>
        }
    }
    ...
}
```

Monolith's Caddy image compiles the following DNS modules:

- `dns.providers.tencentcloud`
- `dns.providers.alidns`
- `dns.providers.route53`
- `dns.providers.cloudflare`
- `dns.providers.godaddy`
- `dns.providers.digitalocean`

You can choose different DNS providers according to actual conditions. Here are configuration examples for various providers:

```caddy
# Tencent Cloud DNS
dns tencentcloud {
    secret_id <TENCENTCLOUD_SECRET_ID>
    secret_key <TENCENTCLOUD_SECRET_KEY>
}

# Alibaba Cloud DNS
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

#### Step 2: Reload

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### Step 3: Test Access

Enter `https://example.com` in your browser to test if the website is accessible normally.

</details>

<details>
<summary><strong>Using Google Trust Services to Issue Certificates in Caddy</strong></summary>

To use Google Trust Services to issue certificates, please follow these steps:

#### Step 1: Obtain EAB Keys

Obtain EAB keys through Google Cloud Shell by executing the following command:

```bash
gcloud publicca external-account-keys create
```

> Tip: The EAB keys need to be used within 7 days after obtaining them. If not used within 7 days, the keys will expire. However, ACME accounts registered with EAB keys have no expiration time.

#### Step 2: Add EAB Keys to Caddyfile

Uncomment and add the obtained EAB key configuration in the `Global Configuration` section of the `services/caddy/Caddyfile` file, for example:

```caddy
# Use Google Trust Services to issue certificates (optional)
acme_ca https://dv.acme-v02.api.pki.goog/directory
acme_eab {
    key_id XXXXXXXXXXXXXXXXX
    mac_key XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
}
```

#### Step 3: Reload

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### Step 4: Test Access

Enter `https://example.com` in your browser to test if the website is accessible normally and check the certificate issuer.

</details>

<details>
<summary><strong>Installing PHP Extensions</strong></summary>

Enter the PHP container and use the `install-php-extensions` command to quickly install extensions:

```bash
docker exec -it php /bin/sh
install-php-extensions smbclient
```

> Tip: For supported extension list, refer to [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

</details>

<details>
<summary><strong>Enabling PHP Slow Script Logging</strong></summary>

Modify the `services/php/www.conf` file, find the following two lines and uncomment them:

```ini
slowlog = /var/log/php/slowlog.log
request_slowlog_timeout = 3
```

> Tip: It's recommended to disable slow script logging in production environments to improve performance.

</details>

<details>
<summary><strong>Enabling MariaDB Slow Query Logging</strong></summary>

Modify the `services/mariadb/mariadb.cnf` file and set the following two parameters to 1:

```ini
slow_query_log=1
log_queries_not_using_indexes=1
```

> Tip: It's recommended to set these parameters to 0 in production environments to improve performance.

</details>

<details>
<summary><strong>MariaDB General Query Log Configuration</strong></summary>

Modify the `services/mariadb/mariadb.cnf` file, find the `general_log` parameter and set it to 1:

```ini
general_log=1
```

> Tip: It's recommended to set these parameters to 0 in production environments to improve performance.

</details>

<details>
<summary><strong>Setting Redis Password</strong></summary>

Modify the `services/redis/redis.conf` file, find the `requirepass` parameter and set a password:

```ini
requirepass your_strong_password
```

> Tip: Please use strong passwords and avoid using the default password `foobared`.

</details>

## 🤝 Contributing

We welcome all contributions. You can submit any ideas as Pull Requests or Issues.

## 📃 License

The project is released under the MIT License, see the [LICENSE](https://github.com/seatonjiang/monolith/blob/main/LICENSE) file for details.
