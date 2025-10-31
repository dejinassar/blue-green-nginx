FROM nginx:alpine

# Install envsubst (for environment variable substitution)
RUN apk add --no-cache gettext

WORKDIR /etc/nginx

COPY nginx.conf.template ./nginx.conf.template
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
