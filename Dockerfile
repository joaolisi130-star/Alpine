FROM alpine:latest

# Instala tudo
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    iptables \
    ip6tables \
    ttyd \
    tailscale

# Porta web terminal
EXPOSE 7681

# Token do tailscale
ENV TS_AUTHKEY=""

# Inicialização
CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
ttyd -W -p 7681 bash \
'
