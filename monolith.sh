#!/usr/bin/env bash

export LC_ALL=C.UTF-8

set -u
set -o pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
ENV_FILE="$PROJECT_ROOT/.env"
EXAMPLE_ENV_FILE="$PROJECT_ROOT/env.example"
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

print_error() {
    msg_error '%s\n' "$1"
}

print_kv() {
    local key="$1"
    local value="$2"
    printf '%s%s:%s %s\n' "${COLOR_INFO}" "${key}" "${COLOR_RESET}" "$value"
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

load_example_defaults() {
    if [ ! -f "$EXAMPLE_ENV_FILE" ]; then
        print_error "未找到 env.example 配置模板。"
        exit 1
    fi

    set -a
    . "$EXAMPLE_ENV_FILE"
    set +a
}

set_env_value() {
    local key="$1"
    local value="$2"
    local tmp_file

    tmp_file="${ENV_FILE}.tmp"
    awk -v key="$key" -v value="$value" '
        index($0, key "=") == 1 {
            $0 = key "=" value
        }
        { print }
    ' "$ENV_FILE" > "$tmp_file" && mv "$tmp_file" "$ENV_FILE"
}

registry_label_from_value() {
    case "$1" in
        seatonjiang)
            printf '%s' "Docker Hub"
            ;;
        docker.cnb.cool/seatonjiang/monolith)
            printf '%s' "CNB"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

registry_value_from_label() {
    case "$1" in
        "Docker Hub")
            printf '%s' "seatonjiang"
            ;;
        "CNB")
            printf '%s' "docker.cnb.cool/seatonjiang/monolith"
            ;;
        *)
            printf '%s' "docker.cnb.cool/seatonjiang/monolith"
            ;;
    esac
}

alpine_mirror_default_index() {
    local current="$1"
    local options=("default" "mirrors.ustc.edu.cn" "mirrors.tuna.tsinghua.edu.cn" "mirrors.aliyun.com" "mirrors.cloud.tencent.com")
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
    local options=("default" "mirrors.ustc.edu.cn" "mirrors.tuna.tsinghua.edu.cn" "mirrors.aliyun.com" "mirrors.cloud.tencent.com")
    local i
    for ((i = 0; i < ${#options[@]}; i++)); do
        if [ "$current" = "${options[$i]}" ]; then
            printf '%s' "$((i + 1))"
            return 0
        fi
    done
    printf '%s' "5"
}

mirror_value_for_display() {
    case "$1" in
        default|"")
            printf '%s' "官方源"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

choose_registry() {
    local title="$1"
    local current_value="$2"
    local default_index="3"
    local current_label
    local selected_label

    current_label="$(registry_label_from_value "$current_value")"
    case "$current_label" in
        "Docker Hub")
            default_index="1"
            ;;
        "CNB")
            default_index="2"
            ;;
    esac

    selected_label="$(prompt_choice "$title" "$default_index" "Docker Hub" "CNB")"
    registry_value_from_label "$selected_label"
}

choose_alpine_mirror() {
    local title="$1"
    local current_value="$2"
    local default_index
    local selected_label
    default_index="$(alpine_mirror_default_index "$current_value")"
    selected_label="$(prompt_choice "$title" "$default_index" "官方源" "中国科学技术大学镜像源" "清华大学镜像源" "阿里云镜像源" "腾讯云镜像源")"

    case "$selected_label" in
        "官方源") printf '%s' "default" ;;
        "中国科学技术大学镜像源") printf '%s' "mirrors.ustc.edu.cn" ;;
        "清华大学镜像源") printf '%s' "mirrors.tuna.tsinghua.edu.cn" ;;
        "阿里云镜像源") printf '%s' "mirrors.aliyun.com" ;;
        "腾讯云镜像源") printf '%s' "mirrors.cloud.tencent.com" ;;
        *) printf '%s' "mirrors.cloud.tencent.com" ;;
    esac
}

choose_ubuntu_mirror() {
    local title="$1"
    local current_value="$2"
    local default_index
    local selected_label
    default_index="$(ubuntu_mirror_default_index "$current_value")"
    selected_label="$(prompt_choice "$title" "$default_index" "官方源" "中国科学技术大学镜像源" "清华大学镜像源" "阿里云镜像源" "腾讯云镜像源")"

    case "$selected_label" in
        "官方源") printf '%s' "default" ;;
        "中国科学技术大学镜像源") printf '%s' "mirrors.ustc.edu.cn" ;;
        "清华大学镜像源") printf '%s' "mirrors.tuna.tsinghua.edu.cn" ;;
        "阿里云镜像源") printf '%s' "mirrors.aliyun.com" ;;
        "腾讯云镜像源") printf '%s' "mirrors.cloud.tencent.com" ;;
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
    cp "$EXAMPLE_ENV_FILE" "$ENV_FILE"

    set_env_value "TIME_ZONE" "$TIME_ZONE"
    set_env_value "IMAGE_REGISTRY" "$IMAGE_REGISTRY"
    set_env_value "ALPINE_MIRROR" "$ALPINE_MIRROR"
    set_env_value "UBUNTU_MIRROR" "$UBUNTU_MIRROR"
    set_env_value "PHP_VERSION" "$PHP_VERSION"
    set_env_value "CADDY_HTTP_PORT" "$CADDY_HTTP_PORT"
    set_env_value "CADDY_HTTPS_PORT" "$CADDY_HTTPS_PORT"
    set_env_value "MARIADB_VERSION" "$MARIADB_VERSION"
    set_env_value "MARIADB_DATABASE_NAME" "$MARIADB_DATABASE_NAME"
    set_env_value "PHPMYADMIN_WEB_PORT" "$PHPMYADMIN_WEB_PORT"
    set_env_value "PHPMYADMIN_UPLOAD_LIMIT" "$PHPMYADMIN_UPLOAD_LIMIT"
}

write_secret_file() {
    local file_name="$1"
    local value="$2"
    printf '%s\n' "$value" >"$SECRETS_DIR/$file_name"
    chmod 600 "$SECRETS_DIR/$file_name" 2>/dev/null || true
}

show_config_summary() {
    local mariadb_user_name="$1"
    local mariadb_user_pwd="$2"
    local mariadb_root_pwd="$3"

    msg_info '\n%s\n' "======================== 配置信息 ========================"
    print_kv "项目目录" "$PROJECT_ROOT"
    print_kv "容器时区" "$TIME_ZONE"
    print_kv "制品仓库" "$(registry_label_from_value "$IMAGE_REGISTRY")"

    print_kv "Alpine 镜像源" "$(mirror_value_for_display "$ALPINE_MIRROR")"
    print_kv "Ubuntu 镜像源" "$(mirror_value_for_display "$UBUNTU_MIRROR")"

    print_kv "Caddy HTTP 端口" "$CADDY_HTTP_PORT"
    print_kv "Caddy HTTPS 端口" "$CADDY_HTTPS_PORT"

    print_kv "MariaDB 数据库名称" "$MARIADB_DATABASE_NAME"
    print_kv "MariaDB 用户名" "$mariadb_user_name"
    print_kv "MariaDB 用户密码" "$mariadb_user_pwd"
    print_kv "MariaDB Root 密码" "$mariadb_root_pwd"

    print_kv "phpMyAdmin 访问端口" "$PHPMYADMIN_WEB_PORT"
    print_kv "phpMyAdmin 上传限制" "$PHPMYADMIN_UPLOAD_LIMIT"

    print_kv "PHP 版本" "$PHP_VERSION"
    print_kv "Caddy 版本" "$CADDY_VERSION"
    print_kv "MariaDB 版本" "$MARIADB_VERSION"
    print_kv "Redis 版本" "$REDIS_VERSION"
    print_kv "Memcached 版本" "$MEMCACHED_VERSION"
    print_kv "phpMyAdmin 版本" "$PHPMYADMIN_VERSION"
    msg_info '%s\n' '=========================================================='
}

initialize_project() {
    mkdir -p "$SECRETS_DIR"

    msg_info '\n%s\n' "请根据提示生成配置文件，直接回车将使用默认值。"

    TIME_ZONE="$(prompt_required_value "[1] 容器时区配置" "$TIME_ZONE")"
    IMAGE_REGISTRY="$(choose_registry "[2] 制品仓库配置" "$IMAGE_REGISTRY")"
    ALPINE_MIRROR="$(choose_alpine_mirror "[3] Alpine 源配置" "$ALPINE_MIRROR")"
    UBUNTU_MIRROR="$(choose_ubuntu_mirror "[4] Ubuntu 源配置" "$UBUNTU_MIRROR")"

    CADDY_HTTP_PORT="$(prompt_required_value "[5] Caddy HTTP 端口配置" "$CADDY_HTTP_PORT")"
    CADDY_HTTPS_PORT="$(prompt_required_value "[6] Caddy HTTPS 端口配置" "$CADDY_HTTPS_PORT")"

    MARIADB_DATABASE_NAME="$(prompt_required_value "[7] MariaDB 默认数据库名称配置" "$MARIADB_DATABASE_NAME")"

    local mariadb_user_pwd=""
    local mariadb_root_pwd=""

    MARIADB_USER_NAME="$(prompt_required_value "[8] MariaDB 用户名配置" "monolith")"

    PHPMYADMIN_WEB_PORT="$(prompt_required_value "[9] phpMyAdmin 访问端口配置" "$PHPMYADMIN_WEB_PORT")"
    PHPMYADMIN_UPLOAD_LIMIT="$(prompt_upload_limit "[10] phpMyAdmin 上传限制配置" "$PHPMYADMIN_UPLOAD_LIMIT")"
    mariadb_user_pwd="$(generate_random_string)"
    mariadb_root_pwd="$(generate_random_string)"

    write_env_file
    write_secret_file "mariadb-user-name" "$MARIADB_USER_NAME"
    write_secret_file "mariadb-user-pwd" "$mariadb_user_pwd"
    write_secret_file "mariadb-root-pwd" "$mariadb_root_pwd"

    show_config_summary "$MARIADB_USER_NAME" "$mariadb_user_pwd" "$mariadb_root_pwd"
    exit 0
}

main() {
    cd "$PROJECT_ROOT" || exit 1
    load_example_defaults

    monolith_logo

    if ! is_initialized; then
        initialize_project
    fi

    msg_error '\n%s\n' "检测到配置文件已存在，如需修改配置请直接编辑配置文件。"
}

main "$@"
