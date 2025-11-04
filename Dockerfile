# ---------- Builder ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json index.js ./
RUN npm install

# ---------- Runtime ----------
FROM alpine:3.20

# 安装 Node.js、Nginx、常用工具
RUN apk update && apk upgrade && \
    apk add --no-cache \
        nodejs npm \
        nginx \
        openssl curl bash coreutils gcompat iproute2 && \
    rm -rf /var/cache/apk/*

# 复制 Node 代码
WORKDIR /app
COPY --from=builder /app /app
COPY index.js package.json ./

# 复制 Nginx 配置模板
COPY nginx/nginx.conf.tpl /etc/nginx/nginx.conf.tpl

# 暴露端口（默认 80，运行时可通过环境变量覆盖）
EXPOSE 80

# 启动脚本（负责变量替换 + 启动 Nginx + Node）
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "index.js"]
