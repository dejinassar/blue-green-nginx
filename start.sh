#!/bin/sh
# Generate nginx.conf from template
envsubst '$ACTIVE_POOL $INACTIVE_POOL' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start nginx in the foreground
nginx -g 'daemon off;'
