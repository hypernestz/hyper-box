FROM alpine:3.23
ENV LANG=en_US.UTF-8

RUN apk update && \
    apk add --no-cache \
        bash \
        jq \
        curl \
        ca-certificates \
        iproute2 \
        xz \
        shadow

RUN ARCH=$(uname -m) && \
    mkdir -p /usr/local/bin && \
    proot_url="https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$(ARCH)-static" && \
    curl -Ls "$proot_url" -o /usr/local/bin/proot && \
    chmod 755 /usr/local/bin/proot

RUN adduser -D -h /home/container -s /bin/sh container

USER container
ENV USER=container
ENV HOME=/home/container

WORKDIR /home/container

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh


RUN chmod +x /entrypoint.sh

CMD ["/bin/sh", "/entrypoint.sh"]
