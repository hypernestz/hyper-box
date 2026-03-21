#!/bin/bash

# --- 1. Define ANSI Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- 2. Display ASCII Art ---
echo -e "${CYAN}"
cat << "EOF"
hyper-box is starting...
EOF
echo -e "${NC}"

echo -e "${GREEN}[+] Initializing Systemd-nspawn environment...${NC}"

cd /home/container

# Ensure the rootfs directory exists
if [ ! -d "/home/container/rootfs" ]; then
    echo -e "${RED}[!] Error: /home/container/rootfs not found!${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Container Configuration:${NC}"
echo -e " ↳ RootFS: ${YELLOW}/home/container/rootfs${NC}"
echo -e " ↳ Mode  : ${YELLOW}Privileged Nspawn${NC}"
echo -e "${CYAN}=======================================${NC}"

# --- 3. Parse Pterodactyl Startup ---
# This converts {{VARIABLE}} to ${VARIABLE} so the shell can evaluate them
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo -e "${GREEN}[+] Booting Guest OS...${NC}"
echo -e "${CYAN}=======================================${NC}\n"

# --- 4. Start Nspawn (Foreground) ---
# -q: quiet mode (prevents nspawn from printing its own banner)
# -D: specify the root directory
eval exec /usr/bin/systemd-nspawn -q -D /home/container/rootfs ${MODIFIED_STARTUP}
