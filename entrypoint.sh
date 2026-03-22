#!/bin/bash
set -e

# Internal variables - define your rootfs path here
# If you are using PRoot to run a guest OS, specify that folder:
export install_path="${HOME}/$(echo "$HOSTNAME" | md5sum | sed 's+ .*++g')" 
export DOCKER_RUN="proot -S ${install_path} -b /dev -b /proc -b /sys -w /root"

# Ensure directories exist
mkdir -p "$install_path"

# Check if file exists to skip startup logic
if [ -f "$HOME/.do-not-start" ]; then
    echo "Maintenance mode detected (.do-not-start found). Dropping to shell."
    rm -f "$HOME/.do-not-start"
    /bin/bash
    exit 0
fi

# Function to start NoVNC and VNC server
start_services() {
    echo "Starting NoVNC on port ${SERVER_PORT}..."
    
    # Starting NoVNC
    # Note: Ensure the path to novnc_proxy is correct inside your rootfs
    $install_path/proot -r $install_path -b /dev -b /proc -b /sys -b /tmp \
        -w "/usr/lib/noVNC" /bin/sh -c \
        "./utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:${SERVER_PORT} --cert self.crt --key self.key" > /dev/null 2>&1 &


    if [ -f "$install_path$HOME/.vnc/passwd" ]; then
        chmod 0600 "$install_path$HOME/.vnc/passwd"
    fi

    echo "Starting VNC Server..."
    $DOCKER_RUN /bin/bash -c "
        export PATH=/bin:/usr/bin:/usr/local/bin:\$PATH;
        export HOME=/root;
        export MOZ_DISABLE_CONTENT_SANDBOX=1;
        export MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1;
        vncserver :1 -geometry 1280x720 -depth 24
    " > /dev/null 2>&1 &
}

# Start services
start_services

# Keep the container alive and provide a shell/log output
echo "Container is running."
tail -f /dev/null
cd /home/container
echo -e "${CYAN}=======================================${NC}\n"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
eval exec ${MODIFIED_STARTUP}
