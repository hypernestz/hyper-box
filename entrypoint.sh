#!/bin/bash

# --- 1. Colors ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
  _   _                 __    ____  __ 
 | | | |               \ \  / /  \/  |
 | |_| |_   _ _ __  ___ _ _\ \  / /| \  / |
 |  __  | | | | '_ \ / _ \ '__\ \/ / | |\/| |
 | |  | | |_| | |_) |  __/ |   \  /  | |  | |
 |_|  |_|\__, | .__/ \___|_|    \/    |_|  |_|
          __/ | |                           
         |___/|_|                           
EOF
echo -e "${NC}"

# --- 2. Setup ---
cd /home/container

# Default path nếu panel không truyền
ROOTFS_PATH=${ROOTFS_PATH:-/home/container/rootfs}
ALPINE_VERSION="3.20.0"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz"

echo -e "${GREEN}[+] RootFS Path:${NC} ${YELLOW}$ROOTFS_PATH${NC}"

# --- 3. Auto download nếu chưa tồn tại ---
if [ ! -d "$ROOTFS_PATH" ] || [ -z "$(ls -A $ROOTFS_PATH 2>/dev/null)" ]; then
    echo -e "${YELLOW}[!] RootFS not found. Downloading Alpine...${NC}"

    mkdir -p "$ROOTFS_PATH"

    curl -L "$ALPINE_URL" -o alpine.tar.gz || {
        echo -e "${RED}[ERROR] Failed to download Alpine${NC}"
        exit 1
    }

    echo -e "${GREEN}[+] Extracting Alpine...${NC}"
    tar -xzf alpine.tar.gz -C "$ROOTFS_PATH" || {
        echo -e "${RED}[ERROR] Failed to extract Alpine${NC}"
        exit 1
    }

    rm alpine.tar.gz

    echo -e "${GREEN}[+] Alpine rootfs ready!${NC}"
else
    echo -e "${GREEN}[+] RootFS already exists, skipping download.${NC}"
fi

# --- 4. Parse Startup ---
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Fallback nếu panel không truyền
MACHINE_NAME=${P_SERVER_UUID:-ptero-container}

echo -e "${GREEN}[+] Initializing Nspawn Session...${NC}"
echo -e " ↳ Machine: ${YELLOW}$MACHINE_NAME${NC}"
echo -e " ↳ RootFS : ${YELLOW}$ROOTFS_PATH${NC}"
echo -e "${CYAN}=======================================${NC}\n"

# --- 5. Run ---
exec systemd-nspawn \
    --boot \
    --directory="$ROOTFS_PATH" \
    --machine="$MACHINE_NAME" \
    --resolv-conf=copy-host \
    --bind=/home/container \
    ${MODIFIED_STARTUP}
