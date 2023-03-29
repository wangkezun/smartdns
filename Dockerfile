FROM --platform=$BUILDPLATFORM alpine:latest as builder
LABEL previous-stage=builder
ADD smartdns.x86_64.tar.gz /
RUN mkdir /release && cp /smartdns/etc /release/ -a && cp /smartdns/usr /release/ -a

FROM --platform=$BUILDPLATFORM alpine:latest
RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai
COPY --from=builder /release/ /
COPY release/*.conf /etc/smartdns
COPY *.conf /etc/smartdns
ADD https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-smartdns.conf /etc/smartdns/anti-ad-smartdns.conf
ADD https://raw.githubusercontent.com/wangkezun/surge/master/misc/microsoft%40cn.list /etc/smartdns/microsoft.list
VOLUME ["/var/run/smartdns"]
EXPOSE 53/udp
CMD ["/usr/sbin/smartdns", "-f", "-x"]
