#!/bin/bash
set -e

# Env defaults (can be overridden in Render env vars)
: "${VNC_PASS:=password}"
: "${VNC_DISPLAY:=:1}"
: "${VNC_RESOLUTION:=1280x720}"
: "${VNC_NOVNC_PORT:=8080}"
: "${NO_VNC_DIR:=/opt/noVNC}"

# Start a lightweight X session (Xvfb is another option; here we use real X)
# Start xfce4 in background on DISPLAY :1 using vncserver
export DISPLAY=${VNC_DISPLAY}
vncserver ${VNC_DISPLAY} -geometry ${VNC_RESOLUTION} -depth 24

# Wait briefly for vncserver to be ready
sleep 1

# Launch noVNC web server using websockify (bridge from WebSockets -> VNC)
# websockify will forward /websockify to VNC display :1 (5901)
${NO_VNC_DIR}/utils/novnc_proxy --vnc localhost:5901 --listen ${VNC_NOVNC_PORT} &

# Keep container alive (tail the vnc log)
tail -f /home/vncuser/.vnc/*.log
