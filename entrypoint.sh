#!/bin/sh
set -e

# ---------- 环境变量（全部可覆盖） ----------
# Node 服务端口（订阅服务）
HTTP_PORT=${HTTP_PORT:-3000}
# Argo 隧道监听端口（Xray 核心）
ARGO_PORT=${ARGO_PORT:-8001}
# Nginx 对外监听端口
NGINX_PORT=${NGINX_PORT:-80}
# 订阅路径（默认 /sub）
# ---------- 订阅路径保护 ----------
SUB_PATH=${SUB_PATH:-sub}
[ "$SUB_PATH" = "/" ] && SUB_PATH="sub"
[ -z "$SUB_PATH" ] && SUB_PATH="sub"

# 运行目录（tmp）
FILE_PATH=${FILE_PATH:-/tmp}

# ---------- 创建运行目录 ----------
mkdir -p "$FILE_PATH"

# ---------- 生成 Nginx 配置文件 ----------
envsubst '${HTTP_PORT} ${ARGO_PORT} ${NGINX_PORT} ${SUB_PATH}' \
    < /etc/nginx/nginx.conf.tpl \
    > /etc/nginx/nginx.conf

# ---------- 启动 Nginx ----------
nginx -g 'daemon off;' &

# ---------- 启动 Node ----------
exec node index.js
