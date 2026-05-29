FROM alpine:latest

# Instala pacotes necessários
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
    git

# Instala noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

# Usuário
RUN useradd -m -s /bin/bash benjamim && \
    echo "benjamim:1234" | chpasswd

# Configuração VNC
RUN mkdir -p /home/benjamim/.vnc && \
    echo '#!/bin/sh' > /home/benjamim/.vnc/xstartup && \
    echo 'startxfce4 &' >> /home/benjamim/.vnc/xstartup && \
    chmod +x /home/benjamim/.vnc/xstartup && \
    echo "1234" | vncpasswd -f > /home/benjamim/.vnc/passwd && \
    chmod 600 /home/benjamim/.vnc/passwd && \
    chown -R benjamim:benjamim /home/benjamim/.vnc

# Portas
EXPOSE 6080
EXPOSE 7681

# Tailscale
ENV TS_AUTHKEY=""

# Inicialização
CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY || true && \
su - benjamim -c "vncserver :1 -geometry 1280x720 -depth 24" && \
python3 /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 & \
ttyd -W -p 7681 bash \
'
