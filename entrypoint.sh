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


MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Use 'exec' to replace the current shell with QEMU, attaching stdin/stdout directly
eval exec ${MODIFIED_STARTUP}
