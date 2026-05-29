FROM alpine:latest

# Pacotes
RUN apk update && apk add --no-cache \
    bash \
    sudo \
    shadow \
    curl \
    wget \
    ca-certificates \
    iptables \
    ip6tables \
    ttyd \
    tailscale \
    xfce4 \
    xfce4-terminal \
    xrdp \
    dbus \
    font-noto

# Cria usuário
RUN useradd -m -s /bin/bash benjamim \
    && echo "benjamim:1234" | chpasswd \
    && adduser benjamim wheel \
    && echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Config XFCE
RUN echo "startxfce4" > /home/benjamim/.xsession \
    && chown benjamim:benjamim /home/benjamim/.xsession

# Portas
EXPOSE 7681
EXPOSE 3389

# Tailscale auth
ENV TS_AUTHKEY=""

# Inicialização
CMD sh -c '\
mkdir -p /var/run/dbus && \
dbus-daemon --system & \
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
xrdp-sesman & \
xrdp & \
ttyd -W -p 7681 bash \
'
