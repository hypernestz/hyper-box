FROM debian:bookworm-slim

# Install systemd-nspawn and essential tools
RUN apt-get update && apt-get install -y \
    systemd-container \
    dbus \
    bash \
    coreutils \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup Pterodactyl User
RUN useradd -m -d /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Copy Entrypoint
COPY ./entrypoint.sh /entrypoint.sh

# Switch to root to handle permissions for the entrypoint
USER root
RUN chmod +x /entrypoint.sh
USER container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
