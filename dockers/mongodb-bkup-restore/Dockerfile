FROM alpine:3.10
LABEL maintainer "Illis Draklaw <illis.draklaw@gmail.com>"


RUN echo "http://alpine.42.fr/v3.6/community/" >> /etc/apk/repositories
RUN echo "http://alpine.42.fr/v3.6/main/" >> /etc/apk/repositories
RUN cat /etc/apk/repositories
RUN apk add --update bash mongodb mongodb-tools gzip openssl jq && rm -rf /var/cache/apk/*

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV CRON_TIME="0 3 * * sun" \
    MONGODB_STRING="mongodb://localhost:27017/"

COPY ["run.sh", "backup.sh", "restore.sh", "/"]
RUN mkdir /backup && chmod u+x /backup.sh /restore.sh
VOLUME ["/backup"]

CMD dockerize /run.sh
