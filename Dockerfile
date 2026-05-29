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
    novnc \
    websockify \
    dbus \
    font-noto

# Usuário
RUN useradd -m -s /bin/bash benjamim \
    && echo "benjamim:1234" | chpasswd \
    && adduser benjamim wheel \
    && echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# XFCE
RUN echo "startxfce4" > /home/benjamim/.xsession \
    && chown benjamim:benjamim /home/benjamim/.xsession

# Script VNC
RUN mkdir -p /home/benjamim/.vnc \
    && echo '#!/bin/sh\nstartxfce4 &' > /home/benjamim/.vnc/xstartup \
    && chmod +x /home/benjamim/.vnc/xstartup \
    && chown -R benjamim:benjamim /home/benjamim/.vnc

# Portas
EXPOSE 7681
EXPOSE 6080

# Tailscale
ENV TS_AUTHKEY=""

# Inicialização
CMD sh -c '\
mkdir -p /var/run/dbus && \
dbus-daemon --system & \
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
su - benjamim -c "vncserver :1 -geometry 1280x720 -depth 24" && \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 & \
ttyd -W -p 7681 bash \
'
