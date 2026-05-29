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

# Websockify via pip
RUN pip3 install websockify

# noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

# Usuário
RUN useradd -m -s /bin/bash benjamim && \
    echo "benjamim:1234" | chpasswd && \
    adduser benjamim wheel && \
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# xstartup
RUN mkdir -p /home/benjamim/.vnc && \
    echo '#!/bin/sh' > /home/benjamim/.vnc/xstartup && \
    echo 'startxfce4 &' >> /home/benjamim/.vnc/xstartup && \
    chmod +x /home/benjamim/.vnc/xstartup && \
    chown -R benjamim:benjamim /home/benjamim/.vnc

# Senha VNC automática
RUN mkdir -p /home/benjamim/.vnc && \
    echo "1234" | vncpasswd -f > /home/benjamim/.vnc/passwd && \
    chmod 600 /home/benjamim/.vnc/passwd && \
    chown -R benjamim:benjamim /home/benjamim/.vnc

EXPOSE 6080
EXPOSE 7681

ENV TS_AUTHKEY=""

CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY || true & \
su - benjamim -c "vncserver :1 -geometry 1280x720 -depth 24" && \
websockify --web=/opt/novnc 6080 localhost:5901 & \
ttyd -W -p 7681 bash \
'
