# Homelab Services Overview

This document catalogs all the services currently running within the Proxmox Homelab infrastructure, their internal networking details, and their external access domains routed through Traefik. **infra-node** is provisioned as a **VM**; **monitor-node** as an **LXC**. Domain (`root_domain`) and Cloudflare API token for SSL are set in Ansible Vault (`group_vars/all/secrets.yml`).

## Core Infrastructure Node (`infra-node`) — VM
**Internal IP:** `192.168.1.59`
**Purpose:** Edge routing, DNS, reverse proxy, and system state monitoring.

| Service          | Internal Port            | External Domain                                                         | SSL Provider | Description                                                                      |
| :--------------- | :----------------------- | :---------------------------------------------------------------------- | :----------- | :------------------------------------------------------------------------------- |
| **Traefik**      | `80`, `443`, `8080`      | N/A                                                                     | Local        | The main reverse proxy handling SNI routing and ACME Let's Encrypt certificates. |
| **Uptime Kuma**  | `3001`                   | [https://status.selfhost.io.vn](https://status.selfhost.io.vn)          | Cloudflare   | Uptime monitoring and alerting dashboard.                                        |
| **AdGuard Home** | `53` (DNS), `3000` (Web) | [https://adguard.selfhost.io.vn](https://adguard.selfhost.io.vn)        | Cloudflare   | Network-wide ad and tracker blocking DNS server.                                 |
| **Tailscale**    | Dynamic TUN              | N/A                                                                     | Wireguard    | Secure VPN mesh network for remote management.                                   |

---

## Observability Node (`monitor-node`) — LXC
**Internal IP:** `192.168.1.61`
**Purpose:** Centralized logging, metrics collection, and dashboard visualization.

| Service           | Internal Port | External Domain                                                         | SSL Provider | Description                                         |
| :---------------- | :------------ | :---------------------------------------------------------------------- | :----------- | :-------------------------------------------------- |
| **Grafana**       | `3000`        | [https://grafana.selfhost.io.vn](https://grafana.selfhost.io.vn)        | Cloudflare   | Interactive visualization and analytics dashboards. |
| **Prometheus**    | `9090`        | Internal Only                                                           | N/A          | Time-series database scraping metrics from nodes.   |
| **Alertmanager**  | `9093`        | Internal Only                                                           | N/A          | Receives and groups alerts from Prometheus rules.   |
| **Node Exporter** | `9100`        | Internal Only                                                           | N/A          | Exposes hardware and OS metrics for Prometheus.     |

---

## AI Application Node (`app-node`) — VM
**Internal IP:** `192.168.1.62`
**Specs:** 4 cores, 8GB RAM, 50GB disk
**Purpose:** Self-hosted AI tooling stack -- web scraping, search, vector DB, LLM observability, AI app platform, and workflow automation.
**Ansible role:** `ai_services` | **Playbook:** `deploy_ai.yml` | **Inventory group:** `[ai]`

| Service                | Internal Port              | External Domain                                                           | SSL Provider | Description                                                     |
| :--------------------- | :------------------------- | :------------------------------------------------------------------------ | :----------- | :-------------------------------------------------------------- |
| **n8n**                | `5678`                     | [https://n8n.selfhost.io.vn](https://n8n.selfhost.io.vn)                 | Cloudflare   | Workflow automation engine for AI pipelines and integrations.    |
| **Firecrawl**          | `3002`                     | [https://firecrawl.selfhost.io.vn](https://firecrawl.selfhost.io.vn)     | Cloudflare   | Web scraping API that converts websites to LLM-ready data.      |
| **SearXNG**            | `8080`                     | [https://search.selfhost.io.vn](https://search.selfhost.io.vn)           | Cloudflare   | Privacy-respecting metasearch engine, usable as AI agent tool.  |
| **Qdrant**             | `6333` (REST), `6334` (gRPC) | Internal Only                                                          | N/A          | Vector database for RAG pipelines and embedding storage.        |
| **Langfuse**           | `3003`                     | [https://langfuse.selfhost.io.vn](https://langfuse.selfhost.io.vn)       | Cloudflare   | LLM observability platform for tracing and monitoring LLM calls.|
| **Dify**               | `3004`                     | [https://dify.selfhost.io.vn](https://dify.selfhost.io.vn)               | Cloudflare   | LLM app development platform with visual workflow builder.      |
| **PostgreSQL**         | `5432`                     | Internal Only                                                             | N/A          | Shared database backend for n8n, Langfuse, and Dify.            |
| **Redis**              | `6379`                     | Internal Only                                                             | N/A          | Shared cache/queue for Firecrawl, Dify, and SearXNG.            |
| **Node Exporter**      | `9100`                     | Internal Only                                                             | N/A          | Exposes hardware and OS metrics for Prometheus.                 |

> **Note:** `app-node` is a full VM, so Docker uses native bridge networking (`ai-net`) instead of `network_mode: host`. Dify uses an internal nginx proxy to route between its web frontend and API backend. Firecrawl includes a dedicated Playwright browser service for JavaScript-rendered page scraping.

---

## Reserved: General App Services (not deployed)
**Ansible role:** `app_services` | **Playbook:** `deploy_apps.yml` | **Inventory group:** `[apps]`

The `app_services` role contains Forgejo (Git), n8n, and Docmost (wiki) for future deployment on a separate node. Uncomment the host in `[apps]` inventory group and run `deploy_apps.yml` when ready.

---

## Traffic Flow Architecture (Zero Trust)
All external domains `*.selfhost.io.vn` resolve statically to the local IP `192.168.1.59` at the Cloudflare DNS level. There are **no exposed ports** on the public router.

1. **Client Device (LAN/VPN)** $\rightarrow$ Requests `https://dify.selfhost.io.vn`
2. **DNS Resolution** $\rightarrow$ Cloudflare returns Local IP `192.168.1.59`
3. **Traefik Ingress (`.59:443`)** $\rightarrow$ Terminates SSL with Let's Encrypt Wildcard Certificate
4. **Internal Routing** $\rightarrow$ Traefik proxies plain HTTP traffic to:
   - `127.0.0.1:3000` (AdGuard Panel) / `127.0.0.1:3001` (Uptime Kuma)
   - `192.168.1.61:3000` (Grafana Panel)
   - `192.168.1.62:5678` (n8n) / `192.168.1.62:3002` (Firecrawl) / `192.168.1.62:8080` (SearXNG)
   - `192.168.1.62:3003` (Langfuse) / `192.168.1.62:3004` (Dify)
