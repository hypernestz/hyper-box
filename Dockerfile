FROM alpine:latest

# Install nspawn using the edge repositories
RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    systemd-nspawn \
    bash \
    coreutils \
    dbus

# Setup Pterodactyl User
RUN adduser -D -h /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

# Switch to root to handle permissions
USER root
RUN chmod +x /entrypoint.sh
USER container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
