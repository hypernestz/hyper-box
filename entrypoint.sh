#!/bin/bash

# --- 1. Colors & Branding ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# --- 2. Environment Setup ---
cd /home/container

# Map /var/lib/machines/alpine to our local rootfs for Pterodactyl compatibility
# This ensures nspawn finds the OS tree where Pterodactyl stores files.
ROOTFS_PATH="/home/container/rootfs"

if [ ! -d "$ROOTFS_PATH" ]; then
    echo -e "${RED}[!] Error: RootFS not found at $ROOTFS_PATH${NC}"
    exit 1
fi

# --- 3. Parse Startup Command ---
# Converts {{VAR}} from the Panel into usable shell variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo -e "${GREEN}[+] Initializing Nspawn Session...${NC}"
echo -e " ↳ Target: ${YELLOW}$ROOTFS_PATH${NC}"
echo -e "${CYAN}=======================================${NC}\n"

# --- 4. Execution ---
# We use 'eval exec' so the nspawn process replaces the shell.
# We don't need 'sudo' inside the container if the Docker image runs as root.
eval exec systemd-nspawn -q -D "$ROOTFS_PATH" ${MODIFIED_STARTUP}
