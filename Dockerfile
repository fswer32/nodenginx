# ---------- Builder ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json index.js ./
RUN npm install

# ---------- Runtime ----------
FROM alpine:3.20

# 安装 Node.js、Nginx、gettext（提供 envsubst）等
RUN apk update && apk upgrade && \
    apk add --no-cache \
        nodejs npm \
        nginx \
        gettext \
        openssl curl bash coreutils gcompat iproute2 && \
    rm -rf /var/cache/apk/*

# 复制 Node 代码
WORKDIR /app
COPY --from=builder /app /app
COPY index.js package.json ./

# 复制 Nginx 配置模板
COPY nginx/nginx.conf.tpl /etc/nginx/nginx.conf.tpl

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露 Nginx 端口
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "index.js"]
