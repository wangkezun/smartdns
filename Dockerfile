FROM --platform=$BUILDPLATFORM alpine:latest as builder
LABEL previous-stage=builder
ADD smartdns.x86_64.tar.gz /
RUN mkdir /release && cp /smartdns/etc /release/ -a && cp /smartdns/usr /release/ -a

FROM --platform=$BUILDPLATFORM alpine:latest
COPY --from=builder /release/ /
COPY *.conf /etc/smartdns
EXPOSE 53/udp
CMD ["/usr/sbin/smartdns", "-f", "-x"]
