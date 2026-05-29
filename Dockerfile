FROM alpine:latest

# Pacotes básicos
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    iptables \
    ip6tables \
    ttyd

# Repositório oficial do Tailscale (Alpine)
RUN echo "https://pkgs.tailscale.com/stable/alpine" >> /etc/apk/repositories \
    && wget -O /etc/apk/keys/tailscale.rsa.pub https://pkgs.tailscale.com/stable/alpine/tailscale.rsa.pub \
    && apk update \
    && apk add tailscale

# Porta do terminal web
EXPOSE 7681

# Auth key do Tailscale (Railway variable)
ENV TS_AUTHKEY=""

# Start script
CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
ttyd -W -p 7681 bash \
'
