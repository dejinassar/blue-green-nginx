#!/bin/sh
# Generate final nginx.conf from template
envsubst '$ACTIVE_POOL $ACTIVE_RELEASE' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
exec "$@"
