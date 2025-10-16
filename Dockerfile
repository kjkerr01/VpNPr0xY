FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# variables (can be overridden by env vars)
ENV VNC_PASS=password
ENV VNC_NOVNC_PORT=8080
ENV VNC_DISPLAY=:1
ENV VNC_RESOLUTION=1280x720

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal xfconf \
    tigervnc-standalone-server tigervnc-common \
    wget python3 python3-websockify python3-numpy \
    git supervisor x11vnc \
    novnc websockify --no-install-recommends \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# note: on some distros novnc package name differs; fallback to get noVNC from github
RUN if [ ! -d /usr/share/novnc ]; then \
      git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
      git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify; \
    fi

# create vnc user
RUN useradd -m -s /bin/bash vncuser
USER vncuser
WORKDIR /home/vncuser

# set VNC password
RUN mkdir -p /home/vncuser/.vnc && \
    echo "${VNC_PASS}" | vncpasswd -f > /home/vncuser/.vnc/passwd && \
    chmod 600 /home/vncuser/.vnc/passwd

# copy start script
COPY --chown=vncuser:vncuser start.sh /home/vncuser/start.sh
RUN chmod +x /home/vncuser/start.sh

EXPOSE ${VNC_NOVNC_PORT}
CMD ["/home/vncuser/start.sh"]
