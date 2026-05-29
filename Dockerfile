FROM alpine:latest

# Pacotes
RUN apk update && apk add --no-cache \
    bash \
    sudo \
    shadow \
    curl \
    wget \
    ca-certificates \
    ttyd \
    tailscale \
    xfce4 \
    xfce4-terminal \
    tigervnc \
    xterm \
    dbus \
    font-noto \
    python3 \
    py3-pip \
    git

# instala websockify
RUN pip install websockify

# baixa noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

# usuário
RUN useradd -m -s /bin/bash benjamim \
    && echo "benjamim:1234" | chpasswd \
    && adduser benjamim wheel \
    && echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# XFCE startup
RUN echo "startxfce4" > /home/benjamim/.xsession \
    && chown benjamim:benjamim /home/benjamim/.xsession

# VNC config
RUN mkdir -p /home/benjamim/.vnc \
    && echo '#!/bin/sh\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/benjamim/.vnc/xstartup \
    && chmod +x /home/benjamim/.vnc/xstartup \
    && chown -R benjamim:benjamim /home/benjamim/.vnc

# portas
EXPOSE 6080
EXPOSE 7681

# tailscale auth
ENV TS_AUTHKEY=""

# inicia tudo
CMD sh -c '\
mkdir -p /var/run/dbus && \
dbus-daemon --system & \
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
su - benjamim -c "vncserver :1 -geometry 1280x720 -depth 24" && \
websockify --web=/opt/novnc 6080 localhost:5901 & \
ttyd -W -p 7681 bash \
'
