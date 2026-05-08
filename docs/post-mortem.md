# Homelab Architectural Post-Mortem & Technical Debt

This document serves as a transparent and honest breakdown of the challenges encountered during the initial infrastructure provisioning, the workarounds implemented, and the remaining technical debt that needs to be addressed in the future.

---

## 🏗 Architectural Workarounds (Hacks)

### 1. Proxmox LXC vs Docker Networking (AppArmor Conflict)
- **The Problem:** Running Docker inside unprivileged Proxmox LXC containers causes severe networking conflicts. Docker attempts to manipulate `iptables` and execute actions requiring `CAP_NET_ADMIN` privileges, which LXC's AppArmor profile actively blocks. This results in Docker containers failing to bind to ports correctly via bridge modes.
- **The Workaround:** We deployed all core containers (Traefik, AdGuard, Grafana, etc.) using `network_mode: "host"`.
- **Technical Debt ⚠️:** `network_mode: "host"` strips away Docker's internal networking isolation. All containers on the LXC node share the same network interface. This restricts us from running multiple instances of services that require the same port (e.g., two web servers fighting for port 80). 
- **Future Solution:** Migrate Proxmox LXC containers to true Virtual Machines (KVMs) for complete isolation, allowing Docker to manage its bridges natively.

### 2. Traefik Docker Provider vs Host Network
- **The Problem:** Because we used `network_mode: "host"`, Traefik's `docker` auto-discovery provider completely broke. Traefik could not resolve the virtual internal IPs of the containers (because there were none), leading to `HTTP 404` errors when attempting to route traffic via Docker Labels.
- **The Workaround:** We completely bypassed Traefik's Docker auto-discovery and implemented a **Static File Provider** (`traefik-dynamic.yml`). All routing rules and load balancer IPs were hardcoded into this YAML configuration file.
- **Technical Debt ⚠️:** This breaks the "magic" of Traefik auto-discovering new containers via labels. Every time a new service is added to the homelab, an administrator must manually edit the `traefik-dynamic.yml` file and restart Traefik.

### 3. Traefik Docker API Version Conflict
- **The Problem:** The Ubuntu 24.04 base image installed a modern Docker Daemon (v27+), but the Traefik `latest` container (v3.0) threw endless errors: `client version 1.24 is too old. Minimum supported API version is 1.44`. This paralyzed Traefik's ability to watch the Docker socket.
- **The Workaround:** We explicitly injected the environment variable `DOCKER_API_VERSION=1.44` into the Traefik container via `docker-compose.yml.j2` to force compatibility, and disabled `swarmMode`. 
- **Technical Debt:** Traefik's internal docker client is falling behind the modernized host daemon.

### 4. Port 53 Collision (`systemd-resolved`)
- **The Problem:** AdGuard Home could not deploy on the `infra-node` because Ubuntu's native DNS stub listener (`systemd-resolved`) was aggressively hogging Port 53.
- **The Workaround:** We ruthlessly disabled `systemd-resolved`, deleted `/etc/resolv.conf`, and hardcoded `nameserver 1.1.1.1` to force the host OS to step aside and give AdGuard Home exclusive control over Port 53.
- **Technical Debt:** This makes the `infra-node` reliant purely on external DNS or its own AdGuard container.

---

## 🚫 Cancelled Initiatives & Roadblocks

### 1. NixOS Golden Image Template
- **The Outcome:** **ABANDONED**. 
- **The Reason:** Proxmox's native `pct` container building system struggled significantly to boot NixOS LXC containers properly due to severe init system and networking incompatibilities. Creating a pure functional NixOS environment inside an unprivileged LXC proved too unstable compared to Ubuntu. We defaulted back to Ubuntu 24.04 for the base template.

### 2. Hardware Power Consumption Metrics (Proxmox Exporter)
- **The Outcome:** **PAUSED**.
- **The Reason:** We quickly discovered that reading hardware power sensors (like Intel RAPL `energy_uj` or `hwmon`) is impossible from inside an LXC container due to kernel isolation. We drafted a plan to use the `prometheus-pve-exporter` to query the physical Proxmox hypervisor API instead, but the user opted to postpone this feature.

---

## 🔐 Security Posture Limitations

### 1. Plain HTTP Internal Traffic (No End-to-End Encryption)
- **Current State:** Traefik terminates Let's Encrypt SSL at the edge node (`192.168.1.59`). However, from Traefik to the downstream applications (e.g., Grafana on `192.168.1.61`), the data travels across the Proxmox virtual switch in **Plain HTTP**.
- **Risk Assessment:** Extremely low risk since the traffic traverses internal virtual boundaries not exposed to the WAN. 
- **Future Solution:** Introduce **Tailscale network namespaces** or Self-Signed certificates on downstream nodes to encrypt the internal `192.168.1.59` $\rightarrow$ `192.168.1.61` routing leg if maximum Zero-Trust is mandated.

### 2. Root Access in Containers
- **Current State:** Ansible is currently scaling into nodes and executing Docker commands directly as the `root` user (`ansible_user=root`).
- **Future Solution:** Implement an unprivileged Ansible user with passwordless `sudo` restrictions to minimize blast radius.
