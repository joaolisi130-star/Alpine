FROM alpine:latest

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    iptables \
    ip6tables \
    ttyd

# adiciona repo do tailscale
RUN echo "https://pkgs.tailscale.com/stable/alpine" >> /etc/apk/repositories \
    && wget -O /etc/apk/keys/tailscale.rsa.pub https://pkgs.tailscale.com/stable/alpine/tailscale.rsa.pub \
    && apk update \
    && apk add tailscale

EXPOSE 7681

ENV TS_AUTHKEY=""

CMD sh -c '\
tailscaled --tun=userspace-networking --state=mem: & \
sleep 5 && \
tailscale up --authkey=$TS_AUTHKEY && \
ttyd -W -p 7681 bash \
'
