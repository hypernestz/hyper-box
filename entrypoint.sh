#!/bin/bash
# entrypoint.sh cho Pterodactyl

# Thư mục chứa rootfs của Ubuntu 24
CHROOT_DIR="/home/container/ubuntu24_root"

# Thay thế biến môi trường của Pterodactyl nếu cần
cd /home/container

echo "--- Khởi động môi trường Ubuntu 24.04 qua PRoot ---"

# Chạy lệnh thông qua proot
# -R: chỉ định rootfs
# -0: giả lập quyền root bên trong chroot
# -b: mount các thư mục hệ thống từ host vào chroot
proot -R $CHROOT_DIR -0 -b /proc -b /dev -b /sys /usr/bin/bash
