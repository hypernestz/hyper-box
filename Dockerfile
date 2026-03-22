FROM ubuntu:24.04

# Cài đặt các công cụ cần thiết: debootstrap và proot
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    debootstrap \
    proot \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Tạo người dùng 'container' theo chuẩn Pterodactyl
RUN useradd -d /home/container -m container
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

# Tạo rootfs cho Ubuntu 24.04 tại thư mục con
# Lưu ý: Vì Docker build chạy quyền root, ta build xong rồi chown lại
USER root
RUN mkdir -p /home/container/ubuntu24_root && \
    debootstrap --variant=minbase noble /home/container/ubuntu24_root http://archive.ubuntu.com/ubuntu/ && \
    chown -R container:container /home/container/ubuntu24_root

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown container:container /entrypoint.sh

USER container
CMD ["/bin/bash", "/entrypoint.sh"]
