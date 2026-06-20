#!/usr/bin/env bash

export LC_ALL=C.UTF-8

set -u
set -o pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
ENV_FILE="$PROJECT_ROOT/.env"
SECRETS_DIR="$PROJECT_ROOT/secrets"

if command -v tput >/dev/null 2>&1 && [ -t 1 ] && [ -n "${TERM:-}" ]; then
    COLOR_INFO="$(tput setaf 6)$(tput bold)"
    readonly COLOR_INFO
    COLOR_NOTICE="$(tput setaf 3)$(tput bold)"
    readonly COLOR_NOTICE
    COLOR_SUCCESS="$(tput setaf 2)$(tput bold)"
    readonly COLOR_SUCCESS
    COLOR_ERROR="$(tput setaf 1)$(tput bold)"
    readonly COLOR_ERROR
    COLOR_RESET="$(tput sgr0)"
    readonly COLOR_RESET
else
    COLOR_INFO=""
    readonly COLOR_INFO
    COLOR_NOTICE=""
    readonly COLOR_NOTICE
    COLOR_SUCCESS=""
    readonly COLOR_SUCCESS
    COLOR_ERROR=""
    readonly COLOR_ERROR
    COLOR_RESET=""
    readonly COLOR_RESET
fi

function msg_format()
{
    local _VAR
    _VAR="$1"
    shift
    if (( $# > 1 )); then
        printf -v "${_VAR}" "$@"
    else
        printf -v "${_VAR}" "%s" "$1"
    fi
}

function msg_info()
{
    local MSG
    msg_format MSG "$@"
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_INFO}" "${MSG}" "${COLOR_RESET}" >&3 2>/dev/null \
            || printf '%s%s%s' "${COLOR_INFO}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    else
        printf '%s%s%s' "${COLOR_INFO}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    fi
}

function msg_notic()
{
    local MSG
    msg_format MSG "$@"
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_NOTICE}" "${MSG}" "${COLOR_RESET}" >&3 2>/dev/null \
            || printf '%s%s%s' "${COLOR_NOTICE}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    else
        printf '%s%s%s' "${COLOR_NOTICE}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    fi
}

function msg_succ()
{
    local MSG
    msg_format MSG "$@"
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_SUCCESS}" "${MSG}" "${COLOR_RESET}" >&3 2>/dev/null \
            || printf '%s%s%s' "${COLOR_SUCCESS}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    else
        printf '%s%s%s' "${COLOR_SUCCESS}" "${MSG}" "${COLOR_RESET}" 2>/dev/null
    fi
}

function msg_error()
{
    local MSG
    msg_format MSG "$@"
    if [[ -e /dev/fd/4 ]]; then
        printf '%s%s%s' "${COLOR_ERROR}" "${MSG}" "${COLOR_RESET}" >&4 2>/dev/null \
            || printf '%s%s%s' "${COLOR_ERROR}" "${MSG}" "${COLOR_RESET}" >&2 2>/dev/null
    else
        printf '%s%s%s' "${COLOR_ERROR}" "${MSG}" "${COLOR_RESET}" >&2 2>/dev/null
    fi
}

function monolith_logo()
{
    msg_info '\n%s\n' '   ██╗      ███╗   ███╗ ██████╗ ███╗   ██╗ ██████╗ ██╗     ██╗████████╗██╗  ██╗'
    msg_info '%s\n'   '   ╚██╗     ████╗ ████║██╔═══██╗████╗  ██║██╔═══██╗██║     ██║╚══██╔══╝██║  ██║'
    msg_info '%s\n'   '    ╚██╗    ██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║██║     ██║   ██║   ███████║'
    msg_info '%s\n'   '    ██╔╝    ██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║██║     ██║   ██║   ██╔══██║'
    msg_info '%s\n'   '   ██╔╝     ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║╚██████╔╝███████╗██║   ██║   ██║  ██║'
    msg_info '%s\n\n' '   ╚═╝      ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝   ╚═╝  ╚═╝'
    msg_info '%s\n'   '基于 Docker 轻松构建现代 PHP 应用服务器，集成了 Caddy、PHP、MariaDB、Redis、Memcached 等服务'
    msg_info '%s\n'   '使用前请先阅读使用说明，项目地址: https://github.com/seatonjiang/monolith'
}

print_line() {
    msg_info '%s\n' "$1"
}

print_title() {
    msg_info '\n%s\n' "$1"
}

print_error() {
    msg_error '错误: %s\n' "$1"
}

print_success() {
    msg_succ '%s\n' "$1"
}

print_kv() {
    local key="$1"
    local value="$2"
    printf '%s%s:%s %s\n' "${COLOR_INFO}" "${key}" "${COLOR_RESET}" "$value"
}

print_menu_item() {
    local index="$1"
    local label="$2"
    msg_info '  %s. %s\n' "$index" "$label"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_runtime() {
    if ! command_exists docker; then
        print_error "项目依赖 Docker, 但是 Docker 没安装"
        exit 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        print_error "项目依赖 Docker Compose, 但是 Docker Compose 没安装"
        exit 1
    fi
}

generate_random_string() {
    LC_ALL=C tr -dc 'A-Za-z0-9!@#%^_+=~' </dev/urandom | head -c 32
    printf '\n'
}

prompt_value() {
    local label="$1"
    local default_value="$2"
    local result

    printf '\n%s%s%s\n' "${COLOR_NOTICE}" "$label" "${COLOR_RESET}" >&2

    if [ -n "$default_value" ]; then
        printf '请输入配置 [%s]: ' "$default_value" >&2
    else
        printf '请输入配置: ' >&2
    fi

    read -r result
    if [ -z "$result" ]; then
        result="$default_value"
    fi

    printf '%s' "$result"
}

prompt_required_value() {
    local label="$1"
    local default_value="$2"
    local result

    while true; do
        result="$(prompt_value "$label" "$default_value")"
        if [ -n "$result" ]; then
            printf '%s' "$result"
            return 0
        fi
        print_error "该项不能为空。"
    done
}

prompt_yes_no() {
    local label="$1"
    local default_answer="$2"
    local hint
    local answer

    if [ "$default_answer" = "Y" ]; then
        hint="Y/n"
    else
        hint="y/N"
    fi

    while true; do
        printf '\n%s%s%s\n' "${COLOR_NOTICE}" "$label" "${COLOR_RESET}" >&2
        printf '请输入选项 [%s]: ' "$hint" >&2
        read -r answer
        if [ -z "$answer" ]; then
            answer="$default_answer"
        fi

        case "$answer" in
            y|Y)
                return 0
                ;;
            n|N)
                return 1
                ;;
            *)
                print_error "请输入 y 或 n。"
                ;;
        esac
    done
}

prompt_yes_no_inline() {
    local label="$1"
    local default_answer="$2"
    local hint
    local answer

    if [ "$default_answer" = "Y" ]; then
        hint="Y/n"
    else
        hint="y/N"
    fi

    while true; do
        printf '\n%s%s%s [%s]: ' "${COLOR_NOTICE}" "$label" "${COLOR_RESET}" "$hint" >&2
        read -r answer
        if [ -z "$answer" ]; then
            answer="$default_answer"
        fi

        case "$answer" in
            y|Y)
                return 0
                ;;
            n|N)
                return 1
                ;;
            *)
                print_error "请输入 y 或 n。"
                ;;
        esac
    done
}

prompt_choice() {
    local title="$1"
    local default_value="$2"
    shift 2
    local options=("$@")
    local i
    local answer

    printf '\n%s%s%s\n' "${COLOR_NOTICE}" "$title" "${COLOR_RESET}" >&2
    for ((i = 0; i < ${#options[@]}; i++)); do
        printf '  %s. %s\n' "$((i + 1))" "${options[$i]}" >&2
    done

    while true; do
        if [ -n "$default_value" ]; then
            printf '请输入选项 [%s]: ' "$default_value" >&2
        else
            printf '请输入选项: ' >&2
        fi
        read -r answer

        if [ -z "$answer" ]; then
            answer="$default_value"
        fi

        if [[ "$answer" =~ ^[0-9]+$ ]] && [ "$answer" -ge 1 ] && [ "$answer" -le "${#options[@]}" ]; then
            printf '%s' "${options[$((answer - 1))]}"
            return 0
        fi

        for i in "${!options[@]}"; do
            if [ "$answer" = "${options[$i]}" ]; then
                printf '%s' "${options[$i]}"
                return 0
            fi
        done

        print_error "无效选项，请重新输入。"
    done
}

is_initialized() {
    [ -f "$ENV_FILE" ]
}

registry_label_from_value() {
    case "$1" in
        seatonjiang)
            printf '%s' "Docker Hub（海外）"
            ;;
        ghcr.io/seatonjiang)
            printf '%s' "GHCR（海外）"
            ;;
        docker.cnb.cool/seatonjiang/monolith)
            printf '%s' "CNB（国内）"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

registry_value_from_label() {
    case "$1" in
        "Docker Hub（海外）")
            printf '%s' "seatonjiang"
            ;;
        "GHCR（海外）")
            printf '%s' "ghcr.io/seatonjiang"
            ;;
        "CNB（国内）")
            printf '%s' "docker.cnb.cool/seatonjiang/monolith"
            ;;
        *)
            printf '%s' "docker.cnb.cool/seatonjiang/monolith"
            ;;
    esac
}

alpine_mirror_default_index() {
    local current="$1"
    local options=("mirrors.ustc.edu.cn" "mirrors.tuna.tsinghua.edu.cn" "mirrors.cs.odu.edu" "mirrors.aliyun.com" "mirrors.cloud.tencent.com")
    local i
    for ((i = 0; i < ${#options[@]}; i++)); do
        if [ "$current" = "${options[$i]}" ]; then
            printf '%s' "$((i + 1))"
            return 0
        fi
    done
    printf '%s' "5"
}

ubuntu_mirror_default_index() {
    local current="$1"
    local options=("mirrors.ustc.edu.cn" "mirrors.tuna.tsinghua.edu.cn" "mirrors.mit.edu" "mirrors.aliyun.com" "mirrors.cloud.tencent.com")
    local i
    for ((i = 0; i < ${#options[@]}; i++)); do
        if [ "$current" = "${options[$i]}" ]; then
            printf '%s' "$((i + 1))"
            return 0
        fi
    done
    printf '%s' "5"
}

choose_registry() {
    local title="$1"
    local current_value="$2"
    local default_index="3"
    local current_label
    local selected_label

    current_label="$(registry_label_from_value "$current_value")"
    case "$current_label" in
        "Docker Hub（海外）")
            default_index="1"
            ;;
        "GHCR（海外）")
            default_index="2"
            ;;
        "CNB（国内）")
            default_index="3"
            ;;
    esac

    selected_label="$(prompt_choice "$title" "$default_index" "Docker Hub（海外）" "GHCR（海外）" "CNB（国内）")"
    registry_value_from_label "$selected_label"
}

choose_alpine_mirror() {
    local title="$1"
    local current_value="$2"
    local default_index
    local selected_label
    default_index="$(alpine_mirror_default_index "$current_value")"
    selected_label="$(prompt_choice "$title" "$default_index" "中国科学技术大学镜像源（国内）" "清华大学镜像源（国内）" "老道明大学镜像源（海外）" "阿里云镜像源（国内）" "腾讯云镜像源（国内）")"

    case "$selected_label" in
        "中国科学技术大学镜像源（国内）") printf '%s' "mirrors.ustc.edu.cn" ;;
        "清华大学镜像源（国内）") printf '%s' "mirrors.tuna.tsinghua.edu.cn" ;;
        "老道明大学镜像源（海外）") printf '%s' "mirrors.cs.odu.edu" ;;
        "阿里云镜像源（国内）") printf '%s' "mirrors.aliyun.com" ;;
        "腾讯云镜像源（国内）") printf '%s' "mirrors.cloud.tencent.com" ;;
        *) printf '%s' "mirrors.cloud.tencent.com" ;;
    esac
}

choose_ubuntu_mirror() {
    local title="$1"
    local current_value="$2"
    local default_index
    local selected_label
    default_index="$(ubuntu_mirror_default_index "$current_value")"
    selected_label="$(prompt_choice "$title" "$default_index" "中国科学技术大学镜像源（国内）" "清华大学镜像源（国内）" "麻省理工大学镜像源（海外）" "阿里云镜像源（国内）" "腾讯云镜像源（国内）")"

    case "$selected_label" in
        "中国科学技术大学镜像源（国内）") printf '%s' "mirrors.ustc.edu.cn" ;;
        "清华大学镜像源（国内）") printf '%s' "mirrors.tuna.tsinghua.edu.cn" ;;
        "麻省理工大学镜像源（海外）") printf '%s' "mirrors.mit.edu" ;;
        "阿里云镜像源（国内）") printf '%s' "mirrors.aliyun.com" ;;
        "腾讯云镜像源（国内）") printf '%s' "mirrors.cloud.tencent.com" ;;
        *) printf '%s' "mirrors.cloud.tencent.com" ;;
    esac
}

prompt_upload_limit() {
    local title="$1"
    local default_value="$2"
    local value

    while true; do
        value="$(prompt_required_value "$title" "$default_value")"
        value="${value// /}"
        if [[ "$value" =~ ^[0-9]+[mM]$ ]]; then
            value="${value%[mM]}M"
            printf '%s' "$value"
            return 0
        fi
        print_error "输入的内容格式无效，请输入类似 128M 的值。"
    done
}

write_env_file() {
    cat >"$ENV_FILE" <<EOF
# ----------------------------------------------------------------------------
# 基础配置
# ----------------------------------------------------------------------------

# 时区设置
TIME_ZONE=$TIME_ZONE

# ----------------------------------------------------------------------------
# 制品仓库配置
# ----------------------------------------------------------------------------

# 可选制品仓库:
#   - seatonjiang
#   - ghcr.io/seatonjiang
#   - docker.cnb.cool/seatonjiang/monolith
IMAGE_REGISTRY=$IMAGE_REGISTRY

# ----------------------------------------------------------------------------
# 系统镜像源配置
# ----------------------------------------------------------------------------

# Alpine Linux 推荐镜像源:
#   - mirrors.ustc.edu.cn
#   - mirrors.tuna.tsinghua.edu.cn
#   - mirrors.cs.odu.edu
#   - mirrors.aliyun.com
#   - mirrors.cloud.tencent.com
ALPINE_MIRROR=$ALPINE_MIRROR

# Ubuntu 推荐镜像源:
#   - mirrors.ustc.edu.cn
#   - mirrors.tuna.tsinghua.edu.cn
#   - mirrors.mit.edu
#   - mirrors.aliyun.com
#   - mirrors.cloud.tencent.com
UBUNTU_MIRROR=$UBUNTU_MIRROR

# ----------------------------------------------------------------------------
# Web 服务器配置
# ----------------------------------------------------------------------------

# PHP 配置
# 支持版本: 8.3-fpm-alpine, 8.4-fpm-alpine, 8.5-fpm-alpine
PHP_VERSION=$PHP_VERSION

# Caddy 配置
# 支持版本: alpine
CADDY_VERSION=alpine
CADDY_HTTP_PORT=$CADDY_HTTP_PORT
CADDY_HTTPS_PORT=$CADDY_HTTPS_PORT

# ----------------------------------------------------------------------------
# 数据库配置
# ----------------------------------------------------------------------------

# MariaDB 配置
# 支持版本: 11.4, 11.8
MARIADB_VERSION=$MARIADB_VERSION
MARIADB_DATABASE_NAME=$MARIADB_DATABASE_NAME

# phpMyAdmin 配置
# 支持版本: 5.2
PHPMYADMIN_VERSION=5.2
PHPMYADMIN_WEB_PORT=$PHPMYADMIN_WEB_PORT
PHPMYADMIN_UPLOAD_LIMIT=$PHPMYADMIN_UPLOAD_LIMIT

# ----------------------------------------------------------------------------
# 缓存服务配置
# ----------------------------------------------------------------------------

# Redis 配置
# 支持版本: 8.8-alpine
REDIS_VERSION=8.8-alpine

# Memcached 配置
# 支持版本: 1.6-alpine
MEMCACHED_VERSION=1.6-alpine
EOF
}

write_secret_file() {
    local file_name="$1"
    local value="$2"
    printf '%s\n' "$value" >"$SECRETS_DIR/$file_name"
    chmod 600 "$SECRETS_DIR/$file_name" 2>/dev/null || true
}

fetch_public_ip() {
    local ip=""
    if command -v curl >/dev/null 2>&1; then
        ip="$(curl -fsSL --max-time 3 https://ip.seatonjiang.com 2>/dev/null | tr -d ' \t\r\n')"
    elif command -v wget >/dev/null 2>&1; then
        ip="$(wget -qO- --timeout=3 https://ip.seatonjiang.com 2>/dev/null | tr -d ' \t\r\n')"
    fi

    if [[ "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
        printf '%s' "$ip"
        return 0
    fi
    if [[ "$ip" == *:* ]]; then
        printf '%s' "$ip"
        return 0
    fi

    printf '%s' ""
}

show_config_summary() {
    local mariadb_user_name="$1"
    local mariadb_user_pwd="$2"
    local mariadb_root_pwd="$3"
    local public_ip=""
    local phpmyadmin_host="127.0.0.1"

    print_title "======================== 配置信息 ========================"
    print_kv "项目目录" "$PROJECT_ROOT"
    print_kv "容器时区" "$TIME_ZONE"
    print_kv "制品仓库" "$IMAGE_REGISTRY"
    print_kv "Alpine 镜像源" "$ALPINE_MIRROR"
    print_kv "Ubuntu 镜像源" "$UBUNTU_MIRROR"
    print_kv "PHP 版本" "$PHP_VERSION"
    print_kv "Caddy HTTP 端口" "$CADDY_HTTP_PORT"
    print_kv "Caddy HTTPS 端口" "$CADDY_HTTPS_PORT"
    print_kv "MariaDB 版本" "$MARIADB_VERSION"
    print_kv "MariaDB 数据库名称" "$MARIADB_DATABASE_NAME"
    print_kv "MariaDB 用户名" "$mariadb_user_name"
    print_kv "MariaDB 用户密码" "$mariadb_user_pwd"
    print_kv "MariaDB Root 密码" "$mariadb_root_pwd"
    print_kv "phpMyAdmin 访问端口" "$PHPMYADMIN_WEB_PORT"
    print_kv "phpMyAdmin 上传限制" "$PHPMYADMIN_UPLOAD_LIMIT"
    public_ip="$(fetch_public_ip)"
    if [ -n "$public_ip" ]; then
        if [[ "$public_ip" == *:* ]]; then
            phpmyadmin_host="[$public_ip]"
        else
            phpmyadmin_host="$public_ip"
        fi
    fi
    print_kv "phpMyAdmin 地址" "http://$phpmyadmin_host:$PHPMYADMIN_WEB_PORT"
    msg_info '%s\n' '=========================================================='
}

reload_caddy_if_running() {
    if docker compose ps --status running --services 2>/dev/null | grep -qx 'caddy'; then
        print_line "检测到 Caddy 容器正在运行，开始重载配置..."
        if docker exec -w /etc/caddy caddy caddy reload; then
            print_line "Caddy 配置已重载。"
        else
            print_error "Caddy 重载失败，请检查容器日志。"
        fi
    else
        print_line "当前未检测到运行中的 Caddy 容器，容器启动后会自动生效。"
    fi
}

initialize_project() {
    require_runtime
    mkdir -p "$SECRETS_DIR"

    print_title "检测到 Monolith 尚未初始化，请根据提示进行初始化操作，直接回车将使用默认值。"

    TIME_ZONE="$(prompt_required_value "[1] 容器时区配置" "Asia/Shanghai")"
    IMAGE_REGISTRY="$(choose_registry "[2] 制品仓库配置" "docker.cnb.cool/seatonjiang/monolith")"
    ALPINE_MIRROR="$(choose_alpine_mirror "[3] Alpine 镜像源配置" "mirrors.cloud.tencent.com")"
    UBUNTU_MIRROR="$(choose_ubuntu_mirror "[4] Ubuntu 镜像源配置" "mirrors.cloud.tencent.com")"

    local PHP_VERSION_SHORT
    PHP_VERSION_SHORT="$(prompt_choice "[5] PHP 版本配置" "1" "8.5" "8.4" "8.3")"
    PHP_VERSION="${PHP_VERSION_SHORT}-fpm-alpine"
    CADDY_HTTP_PORT="$(prompt_required_value "[6] Caddy HTTP 端口配置" "80")"
    CADDY_HTTPS_PORT="$(prompt_required_value "[7] Caddy HTTPS 端口配置" "443")"

    MARIADB_VERSION="$(prompt_choice "[8] MariaDB 版本配置" "1" "11.8" "11.4")"
    MARIADB_DATABASE_NAME="$(prompt_required_value "[9] MariaDB 默认数据库名称配置" "monolith")"

    local mariadb_user_pwd=""
    local mariadb_root_pwd=""

    MARIADB_USER_NAME="$(prompt_required_value "[10] MariaDB 用户名配置" "monolith")"

    PHPMYADMIN_WEB_PORT="$(prompt_required_value "[11] phpMyAdmin 访问端口配置" "28080")"
    PHPMYADMIN_UPLOAD_LIMIT="$(prompt_upload_limit "[12] phpMyAdmin 上传限制配置" "128M")"
    mariadb_user_pwd="$(generate_random_string)"
    mariadb_root_pwd="$(generate_random_string)"

    write_env_file
    write_secret_file "mariadb-user-name" "$MARIADB_USER_NAME"
    write_secret_file "mariadb-user-pwd" "$mariadb_user_pwd"
    write_secret_file "mariadb-root-pwd" "$mariadb_root_pwd"

    if prompt_yes_no "[13] 是否立即构建全部容器" "Y"; then
        docker compose build
    fi

    show_config_summary "$MARIADB_USER_NAME" "$mariadb_user_pwd" "$mariadb_root_pwd"
    exit 0
}

manage_containers() {
    local action

    while true; do
        print_title "容器管理"
        print_menu_item "1" "构建并后台启动全部容器"
        print_menu_item "2" "启动核心容器（不含 phpMyAdmin）"
        print_menu_item "3" "停止并删除全部容器与网络"
        print_menu_item "4" "重启全部容器"
        print_menu_item "5" "重载 Caddy 配置"
        print_menu_item "0" "返回"
        msg_notic '%s' '请选择要执行的操作: '
        read -r action

        case "$action" in
            1)
                docker compose up -d
                ;;
            2)
                docker compose up -d caddy php mariadb redis memcached
                ;;
            3)
                docker compose down
                ;;
            4)
                docker compose restart
                ;;
            5)
                reload_caddy_if_running
                ;;
            0)
                return 0
                ;;
            *)
                print_error "无效选项，请重新输入。"
                ;;
        esac
    done
}

upgrade_project() {
    require_runtime

    if ! prompt_yes_no_inline "升级镜像会停止容器、删除旧镜像并重新构建，确认继续吗?" "Y"; then
        return 0
    fi

    docker compose down
    docker system prune -a --volumes -f
    docker compose up -d
    print_success "镜像升级完成，已删除旧镜像并重新构建全部容器。"
    exit 0
}

main_menu() {
    local action

    while true; do
        print_title "管理菜单"
        print_menu_item "1" "容器管理"
        print_menu_item "2" "升级镜像"
        print_menu_item "0" "退出"
        msg_notic '%s' '请选择要执行的操作: '
        read -r action

        case "$action" in
            1)
                manage_containers
                ;;
            2)
                upgrade_project
                ;;
            0)
                exit 0
                ;;
            *)
                print_error "选项无效，请重新输入。"
                ;;
        esac
    done
}

main() {
    cd "$PROJECT_ROOT" || exit 1

    monolith_logo

    if ! is_initialized; then
        initialize_project
    fi

    main_menu
}

main "$@"
