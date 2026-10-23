FROM alpine:3.21

ARG XRAY_VERSION=v26.10.21

RUN apk add --no-cache ca-certificates curl unzip \
 && curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
 && mkdir -p /tmp/xray \
 && unzip -o /tmp/xray.zip -d /tmp/xray \
 && cp /tmp/xray/xray /usr/local/bin/xray \
 && chmod 0755 /usr/local/bin/xray \
 && cp /tmp/xray/geoip.dat /tmp/xray/geosite.dat /usr/local/bin/ \
 && rm -rf /tmp/xray /tmp/xray.zip

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
