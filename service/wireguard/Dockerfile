FROM alpine:3.12
RUN apk update && apk add bash wireguard-tools
RUN echo "net.ipv4.ip_forward=1">>/etc/sysctl.conf
RUN echo "net.ipv6.conf.all.forwarding=1" >>/etc/sysctl.conf
COPY config /etc/wireguard/wg0.conf
COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "run" ]
