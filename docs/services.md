# Homelab Services Overview

This document catalogs all the services currently running within the Proxmox Homelab infrastructure, their internal networking details, and their external access domains routed through Traefik. **infra-node** is provisioned as a **VM**; **monitor-node** as an **LXC**. Domain (`root_domain`) and Cloudflare API token for SSL are set in Ansible Vault (`group_vars/all/secrets.yml`).

## Core Infrastructure Node (`infra-node`) — VM
**Internal IP:** `192.168.1.59`
**Purpose:** Edge routing, DNS, reverse proxy, and system state monitoring.

| Service          | Internal Port            | External Domain                                                         | SSL Provider | Description                                                                      |
| :--------------- | :----------------------- | :---------------------------------------------------------------------- | :----------- | :------------------------------------------------------------------------------- |
| **Traefik**      | `80`, `443`, `8080`      | N/A                                                                     | Local        | The main reverse proxy handling SNI routing and ACME Let's Encrypt certificates. |
| **Uptime Kuma**  | `3001`                   | [https://status.selfhost.io.vn](https://status.status.selfhost.io.vn)   | Cloudflare   | Uptime monitoring and alerting dashboard.                                        |
| **AdGuard Home** | `53` (DNS), `3000` (Web) | [https://adguard.selfhost.io.vn](https://adguard.status.selfhost.io.vn) | Cloudflare   | Network-wide ad and tracker blocking DNS server.                                 |
| **Tailscale**    | Dynamic TUN              | N/A                                                                     | Wireguard    | Secure VPN mesh network for remote management.                                   |

---

## Observability Node (`monitor-node`) — LXC
**Internal IP:** `192.168.1.61`
**Purpose:** Centralized logging, metrics collection, and dashboard visualization.

| Service           | Internal Port | External Domain                                                         | SSL Provider | Description                                         |
| :---------------- | :------------ | :---------------------------------------------------------------------- | :----------- | :-------------------------------------------------- |
| **Grafana**       | `3000`        | [https://grafana.selfhost.io.vn](https://grafana.status.selfhost.io.vn) | Cloudflare   | Interactive visualization and analytics dashboards. |
| **Prometheus**    | `9090`        | Internal Only                                                           | N/A          | Time-series database scraping metrics from nodes.   |
| **Alertmanager**  | `9093`        | Internal Only                                                           | N/A          | Receives and groups alerts from Prometheus rules.   |
| **Node Exporter** | `9100`        | Internal Only                                                           | N/A          | Exposes hardware and OS metrics for Prometheus.     |

---

## Traffic Flow Architecture (Zero Trust)
All external domains `*.selfhost.io.vn` resolve statically to the local IP `192.168.1.59` at the Cloudflare DNS level. There are **no exposed ports** on the public router.

1. **Client Device (LAN/VPN)** $\rightarrow$ Requests `https://adguard.selfhost.io.vn`
2. **DNS Resolution** $\rightarrow$ Cloudflare returns Local IP `192.168.1.59`
3. **Traefik Ingress (`.59:443`)** $\rightarrow$ Terminates SSL with Let's Encrypt Wildcard Certificate
4. **Internal Routing** $\rightarrow$ Traefik proxies plain HTTP traffic to `127.0.0.1:3000` (AdGuard Panel) or `192.168.1.61:3000` (Grafana Panel).
