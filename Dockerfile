FROM alpine:latest

# Instala pacotes
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    ttyd \
    iptables \
    ip6tables \
    ca-certificates

# Instala Tailscale
RUN wget https://pkgs.tailscale.com/stable/alpine/tailscale.apk \
    && apk add --allow-untrusted tailscale.apk \
    && rm tailscale.apk

# Porta do ttyd
EXPOSE 7681

# Variável do token
ENV TS_AUTHKEY=""

# Inicialização
CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
ttyd -W -p 7681 bash \
'
