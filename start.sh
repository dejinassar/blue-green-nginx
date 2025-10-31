#!/bin/sh
set -e

echo "Starting nginx with pool: ${ACTIVE_POOL}"

# Replace env vars in template
envsubst '$ACTIVE_POOL $ACTIVE_RELEASE' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "Generated nginx.conf:"
cat /etc/nginx/nginx.conf | grep proxy_set_header

nginx -g 'daemon off;'
