FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

RUN apk add bash
RUN apk add --no-cache certbot

COPY entrypoint.sh /entrypoint.sh
COPY domains.list /domains.list
RUN chmod +x /entrypoint.sh
RUN rm /etc/nginx/conf.d/*
ENTRYPOINT [ "../entrypoint.sh" ]