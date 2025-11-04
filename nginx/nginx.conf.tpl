events {
    worker_connections 1024;
}

http {
    upstream node_app {
        server 127.0.0.1:${HTTP_PORT};
    }
    upstream argo_tunnel {
        server 127.0.0.1:${ARGO_PORT};
    }

    server {
        listen ${NGINX_PORT};
        location /sub {
            proxy_pass http://node_app/sub;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location / {
            proxy_pass http://argo_tunnel;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Connection "";
            proxy_http_version 1.1;
            chunked_transfer_encoding off;
            proxy_buffering off;
            proxy_cache off;
        }
    }
}
