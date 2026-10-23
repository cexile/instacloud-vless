#!/bin/sh
# VLESS + XHTTP server on Xray, optionally fronted by a Cloudflare Tunnel.
# Config is rendered from env at boot:
#   UUID          (required) vless client id
#   XHTTP_PATH    (default /xhttp) xhttp path
#   PORT          (default 8080) listen port
#   TUNNEL_TOKEN  (optional) cloudflared tunnel token. When set, cloudflared
#                 runs next to xray and serves 127.0.0.1:PORT through the
#                 tunnel's public hostname (configure that hostname's service
#                 as http://127.0.0.1:8080 in the Cloudflare dashboard).
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

if [ -n "${TUNNEL_TOKEN:-}" ]; then
  echo "[entrypoint] TUNNEL_TOKEN set, starting cloudflared"
  ( while true; do
      cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}" || true
      echo "[entrypoint] cloudflared exited, restarting in 5s"
      sleep 5
    done ) &
else
  echo "[entrypoint] TUNNEL_TOKEN not set, direct edge entry only"
fi

exec /usr/local/bin/xray run -config /usr/local/etc/xray/config.json
