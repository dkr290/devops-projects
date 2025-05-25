#!/bin/bash
apt update && apt install -y nginx && \
mkdir -p /var/www/app1 && echo '<!DOCTYPE html><html><head><title>Hi</title></head><body><h1>Hi</h1></body></html>' > /var/www/app1/index.html && \
rm /etc/nginx/sites-available/default && echo "server { listen 80; root /var/www/app1; index index.html; server_name _; location / { try_files \$uri \$uri/ =404; } }" > /etc/nginx/sites-available/app1 && \
ln -s /etc/nginx/sites-available/app1 /etc/nginx/sites-enabled/app1 && nginx -t && systemctl reload nginx
