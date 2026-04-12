# Homelab Infrastructure as Code (IaC)

Welcome to the Homelab Infrastructure project. This repository uses **Terraform** to provision **VMs and LXC containers** on Proxmox, and **Ansible** to configure those nodes and deploy Docker-based services.

## 🏗 Architecture

The project is divided into two main components:
1. **Terraform (`/terraform`)**: Provisions Proxmox VMs (`modules/proxmox_vm`) and LXC containers (`modules/proxmox_lxc`). Current setup: **infra-node** is a VM, **monitor-node** is an LXC.
2. **Ansible (`/ansible`)**: Connects to the provisioned nodes to install base software (like Docker) and deploy containerized applications (Core Services, Web Apps, Databases).

## Repository Layout

- `terraform/`: Main Proxmox stack for homelab nodes and modules.
- `terraform/digitalocean/`: Separate Terraform root for DigitalOcean resources with independent state.
- `ansible/`: Inventory, playbooks, and roles for post-provisioning and service deployment.
- `docs/`: Service catalog, network notes, and operational documentation.

---

## 🚀 Quick Start Guide: How to deploy a new Node

If you want to spin up a new server (node) in your Homelab, follow these simple steps:

### Step 1: Provision the Server (Terraform)
1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Open `main.tf` and add a new module block for your node. Use `proxmox_vm` for a VM (like infra-node) or `proxmox_lxc` for an LXC (like monitor-node). Example for LXC:
   ```hcl
   module "app_node_01" {
     source           = "./modules/proxmox_lxc"
     node_name        = "host"             # Proxmox target node
     vm_id            = 114                # Unique ID
     hostname         = "app-node-01"
     template_file_id = var.lxc_template
     cores            = 4
     memory           = 4096
     disk_size        = 20
     ip_address       = "192.168.1.60/24"  # Use "dhcp" or static IP
     gateway          = "192.168.1.1"      # Omit if using DHCP
     ssh_public_key   = trimspace(file(var.ssh_public_key))
     unprivileged     = true               # Use false only if absolutely necessary
     nesting          = true               # Required for Docker
   }
   ```
3. Apply the changes to create the container on Proxmox:
   ```bash
   terraform apply
   ```

### Step 2: Add Node to Inventory (Ansible)
1. Navigate to the `ansible` directory:
   ```bash
   cd ../ansible
   ```
2. Open `inventories/homelab.ini` and add your new node's IP to the `[base]` group, and any other relevant group (like `[apps]`):
   ```ini
   [base]
   infra-node ansible_host=192.168.1.59 ansible_user=root
   app-node-01 ansible_host=192.168.1.60 ansible_user=root # <-- New Node

   [apps]
   app-node-01 # <-- Group it here
   ```

### Step 3: Setup Base Infrastructure
Run the `base_setup.yml` playbook. This standard playbook connects to all nodes in the `[base]` group, updates the system, installs Docker, Docker Compose, and prepares the environment.
```bash
ansible-playbook -i inventories/homelab.ini playbooks/base_setup.yml
```

### Step 4: Deploy Applications
Once the base is set up, run the specific playbook for your node's role.
- For core infrastructure (Adguard, Traefik, Tailscale):
  ```bash
  ansible-playbook -i inventories/homelab.ini playbooks/deploy_infra.yml
  ```
- For custom apps (using `deploy_apps.yml` template):
  ```bash
  ansible-playbook -i inventories/homelab.ini playbooks/deploy_apps.yml
  ```

---

## 🔑 Managing Secrets

This repository uses `ansible-vault` to encrypt sensitive information. 
- The vault password is kept locally in `ansible/vault_pass.txt` (This file is `.gitignore`d).
- Secret variables are stored in `ansible/group_vars/all/secrets.yml`.

**To edit secrets:**
```bash
cd ansible
ansible-vault edit group_vars/all/secrets.yml --vault-password-file vault_pass.txt
```

**Variables used by Traefik and core services (store in `secrets.yml`):**
- `cloudflare_api_token` — Cloudflare DNS API token (for ACME DNS challenge and Let's Encrypt).
- `root_domain` — Your public domain (e.g. `selfhost.io.vn`). Used for `*.{{ root_domain }}` and router rules.

**Terraform secret handling (do not hardcode in `terraform.tfvars`):**
- Set `TF_VAR_proxmox_api_pass` in shell environment before running Terraform.
- `TF_VAR_default_password` is read at runtime by `terraform/apply.sh` from Ansible Vault (`terraform_default_password`).
- `DIGITALOCEAN_TOKEN` should be loaded from `terraform/digitalocean/.do.env` for the DigitalOcean stack.
- Example:
  ```bash
  export TF_VAR_proxmox_api_pass='***'
  cd terraform && ./apply.sh
  ```

---

## 🛠 Architecture & Active Services

The Homelab architecture is spread across specialized Proxmox nodes (infra-node as VM, monitor-node as LXC). All incoming web traffic is securely routed through a central Traefik ingress point handling Let's Encrypt Wildcard SSL certificates (domain and Cloudflare API token are configured via Ansible Vault; see [Managing Secrets](#-managing-secrets)).

👉 **[View the complete Homelab Services Catalog & Network Map](docs/services.md)**

*(Note: Because of Proxmox LXC AppArmor restrictions, core services bypass Docker's bridge networking using `network_mode: host` to easily control the required privileged ports without sysctl conflicts).*
