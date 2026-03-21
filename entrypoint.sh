#!/bin/bash
# entrypoint.sh

# Wait for internal networking to settle
sleep 1

# Display the environment for debugging (optional)
echo "----------------------------------------"
echo "Starting Systemd-nspawn on Alpine Host"
echo "User: $(whoami)"
echo "Working Dir: $(pwd)"
echo "----------------------------------------"

# Replace {{VARIABLES}} in your guest configs if needed
# Example: sed -i "s/{{PORT}}/${SERVER_PORT}/g" /etc/some-config

# Ensure the guest rootfs exists (e.g., in /home/container/rootfs)
if [ ! -d "${GUEST_ROOTFS}" ]; then
    echo "Error: Guest rootfs not found at ${GUEST_ROOTFS}"
    exit 1
fi

# Execute the nspawn command. 
# We use 'exec' so nspawn becomes PID 1 and receives shutdown signals from Pterodactyl.
exec /usr/bin/systemd-nspawn \
    --directory="${GUEST_ROOTFS}" \
    --machine=ptero-guest \
    --notify-ready=yes \
    ${EXTRA_NSPAWN_ARGS}
