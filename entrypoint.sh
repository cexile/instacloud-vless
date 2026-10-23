#!/bin/sh
# VLESS + XHTTP server on Xray. Config is rendered from env at boot:
#   UUID        (required) vless client id
#   XHTTP_PATH  (default /xhttp) xhttp path
#   PORT        (default 8080) listen port
set -eu

: "${UUID:?UUID env is required}"
XHTTP_PATH="${XHTTP_PATH:-/xhttp}"
PORT="${PORT:-8080}"

mkdir -p /usr/local/etc/xray
cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": { "path": "${XHTTP_PATH}", "mode": "auto" }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"] }
    }
  ],
  "outbounds": [ { "protocol": "freedom", "tag": "direct" } ]
}
EOF

exec /usr/local/bin/xray run -config /usr/local/etc/xray/config.json
