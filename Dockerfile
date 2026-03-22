FROM alpine:3.23

ENV LANG=en_US.UTF-8
ENV USER=container
ENV HOME=/home/container

# Install dependencies
RUN apk update && \
    apk add --no-cache \
        bash \
        jq \
        curl \
        ca-certificates \
        iproute2 \
        xz \
        shadow \
        proot

# Setup Pterodactyl User
RUN adduser -D -h /home/container -s /bin/bash container

# Set working directory
WORKDIR /home/container

# Copy entrypoint and set permissions
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container

CMD ["/bin/bash", "/entrypoint.sh"]
