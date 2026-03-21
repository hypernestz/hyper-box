FROM alpine:latest

# Install systemd-nspawn and bash
RUN apk add --no-cache systemd-container bash coreutils

# Setup Pterodactyl User
RUN adduser -D -h /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

# Switch to root to handle permissions for the entrypoint
USER root
RUN chmod +x /entrypoint.sh
USER container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
