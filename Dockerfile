FROM --platform=$BUILDPLATFORM alpine:latest as builder

# prepare builder
RUN apk add --update alpine-sdk bash dpkg openssl-dev linux-headers openssl-libs-static
RUN git clone https://github.com/pymumu/smartdns build/smartdns

WORKDIR /build/smartdns
RUN ash ./package/build-pkg.sh --platform linux --arch `dpkg --print-architecture` --static
RUN cd package && tar -xvf *.tar.gz && chmod a+x smartdns/etc/init.d/smartdns

FROM --platform=$BUILDPLATFORM alpine:latest
RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai
COPY --from=builder /build/smartdns/package/smartdns/etc /etc
COPY --from=builder /build/smartdns/package/smartdns/usr /usr
COPY release/*.conf /etc/smartdns
COPY *.conf /etc/smartdns
ADD https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-smartdns.conf /etc/smartdns/anti-ad-smartdns.conf
ADD https://raw.githubusercontent.com/wangkezun/surge/master/misc/microsoft%40cn.list /etc/smartdns/microsoft.list
ADD https://raw.githubusercontent.com/wangkezun/surge/master/misc/blizzard-cdn.list /etc/smartdns/blizzard-cdn.list
VOLUME ["/var/run/smartdns"]
EXPOSE 53/udp
EXPOSE 53/tcp
EXPOSE 853/tcp
CMD ["/usr/sbin/smartdns", "-f", "-x"]
