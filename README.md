# instacloud-vless

VLESS + XHTTP proxy server (Xray-core) packaged for InstaCloud compute,
optionally fronted by a Cloudflare Tunnel.

The container renders its Xray config from environment variables at boot:

| Env | Required | Default | Meaning |
| --- | --- | --- | --- |
| `UUID` | yes | - | VLESS client id |
| `XHTTP_PATH` | no | `/xhttp` | XHTTP path (clients use it with a trailing `/`) |
| `PORT` | no | `8080` | listen port |
| `TUNNEL_TOKEN` | no | - | Cloudflare Tunnel token; when set, cloudflared runs next to Xray |

Two entries can serve the same Xray instance:

1. **Direct (default).** On InstaCloud the service is exposed as HTTPS at its
   service domain (endpoint `http`); the platform terminates TLS and Xray
   serves plain HTTP/XHTTP inside the container.
2. **Cloudflare Tunnel.** Set `TUNNEL_TOKEN` as a project secret, and in the
   Cloudflare dashboard point the tunnel's public hostname at service
   `http://127.0.0.1:8080`. Client: same VLESS/XHTTP settings, but address =
   the tunnel hostname, port 443, TLS on, host/sni = tunnel hostname.

Client (v2rayN): VLESS, port 443, TLS on, transport `xhttp`,
path = `XHTTP_PATH` + `/`, mode `auto`.
