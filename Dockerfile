FROM alpine:latest

RUN apk add --no-progress --no-cache \
    systemd-container \
    dbus \
    bash

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
