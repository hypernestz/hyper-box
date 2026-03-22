  #!/bin/bash

  # Check if file exists
  if [ -f "$HOME/.do-not-start" ]; then
    rm -rf "$HOME/.do-not-start"
    cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
    $DOCKER_RUN /bin/sh
    exit
  fi

  # Function to start NoVNC and VNC server
  start_services() {
    # Starting NoVNC
    $install_path/proot --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp -w "/usr/lib/noVNC" /bin/sh -c \
      "./utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:$SERVER_PORT --cert self.crt --key self.key" &>/dev/null &

    # Set up VNCPasswd
    chmod 0600 "$install_path$HOME/.vnc/passwd" # prerequisite

    $DOCKER_RUN "export PATH=$install_path/bin:$install_path/usr/bin:$PATH HOME=$install_path$HOME LD_LIBRARY_PATH='$install_path/usr/lib:$install_path/lib:/usr/lib:/usr/lib64:/lib64:/lib'; \
      cd $install_path$HOME; \
      export MOZ_DISABLE_CONTENT_SANDBOX=1 \
      MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1 \
      MOZ_DISABLE_RDD_SANDBOX=1 \
      MOZ_DISABLE_GMP_SANDBOX=1 \
      HOME='$install_path$HOME' \
      HOSTNAME=Hyperbox; \
      $(if_x86_64 "vglrun -d egl") vncserver :0" &>/dev/null &
    $DOCKER_RUN /bin/sh
  }

  # Keep the service alive indefinitely
  while true; do
    start_services
    sleep 86400 # Sleep for 24 hours, adjust as needed
  done
