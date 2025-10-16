#!/bin/bash
set -e
# env defaults
: "${VNC_DISPLAY:=:1}"
: "${VNC_RESOLUTION:=1280x720}"
: "${VNC_NOVNC_PORT:=8080}"
: "${NO_VNC_DIR:=/opt/noVNC}"
: "${VNC_PASS:=password}"

export DISPLAY=${VNC_DISPLAY}

# Start a lightweight X session using TigerVNC (creates the X session and VNC server)
# If vncserver is not present, you can use Xvfb + xfce4-session + x11vnc instead.
vncserver ${VNC_DISPLAY} -geometry ${VNC_RESOLUTION} -depth 24

# Wait for vncserver to create its socket/port
sleep 1

# Start x11vnc and explicitly bind to 0.0.0.0 (all interfaces).
# -rfbport 5901 ensures VNC is on that port (VNC display :1 => 5901)
# -forever keeps it alive, -shared allows multiple clients, -usepw uses the stored passwd file
x11vnc -display ${VNC_DISPLAY} -rfbport 5901 -localhost no -forever -shared -usepw &
sleep 1

# Start noVNC/websockify and bind to 0.0.0.0:${VNC_NOVNC_PORT}
# If you have novnc_proxy available:
if [ -x "${NO_VNC_DIR}/utils/novnc_proxy" ]; then
  ${NO_VNC_DIR}/utils/novnc_proxy --vnc 127.0.0.1:5901 --listen 0.0.0.0:${VNC_NOVNC_PORT} &
else
  # fallback to websockify directly (path may vary)
  python3 ${NO_VNC_DIR}/utils/websockify/run --web ${NO_VNC_DIR} 0.0.0.0:${VNC_NOVNC_PORT} 127.0.0.1:5901 &
fi

# tail logs so container doesn't exit
tail -f /home/vncuser/.vnc/*.log || sleep infinity
