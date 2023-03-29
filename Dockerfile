FROM --platform=$BUILDPLATFORM alpine:latest as builder
LABEL previous-stage=smartdns-builder

# prepare builder
RUN apk add --update alpine-sdk bash dpkg openssl-dev linux-headers openssl-libs-static
RUN git clone https://github.com/pymumu/smartdns build/smartdns

# do make
COPY . /build/smartdns/
RUN cd /build/smartdns && \
    ash ./package/build-pkg.sh --platform linux --arch `dpkg --print-architecture` --static && \
    \
    ( cd package && tar -xvf *.tar.gz && chmod a+x smartdns/etc/init.d/smartdns ) && \
    \
    mkdir -p /release/var/log /release/var/run && \
    cp package/smartdns/etc /release/ -a && \
    cp package/smartdns/usr /release/ -a && \
    cd / && rm -rf /build

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
