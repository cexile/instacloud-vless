# instacloud-vless

VLESS + XHTTP proxy server (Xray-core) packaged for InstaCloud compute.

The container renders its Xray config from environment variables at boot:

| Env | Required | Default | Meaning |
| --- | --- | --- | --- |
| `UUID` | yes | - | VLESS client id |
| `XHTTP_PATH` | no | `/xhttp` | XHTTP path |
| `PORT` | no | `8080` | listen port |

On InstaCloud the service is exposed as HTTPS at its service domain
(endpoint `http`); the platform terminates TLS and Xray serves plain
HTTP/XHTTP inside the container.

Client (v2rayN): VLESS, address = service domain, port 443, TLS on,
transport `xhttp`, path = `XHTTP_PATH`, host = service domain.
