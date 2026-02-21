# Homelab Infrastructure as Code (IaC)

Welcome to the Homelab Infrastructure project. This repository uses **Terraform** to provision LXC containers on Proxmox, and **Ansible** to configure those containers and deploy Docker-based services.

## 🏗 Architecture

The project is divided into two main components:
1. **Terraform (`/terraform`)**: Provisions the raw Proxmox LXC containers. It uses a reusable module (`modules/proxmox_lxc`) to make deploying new nodes effortless.
2. **Ansible (`/ansible`)**: Connects to the provisioned nodes to install base software (like Docker) and deploy containerized applications (Core Services, Web Apps, Databases).

---

## 🚀 Quick Start Guide: How to deploy a new Node

If you want to spin up a new server (node) in your Homelab, follow these simple steps:

### Step 1: Provision the Server (Terraform)
1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Open `main.tf` and add a new module block for your node. Example:
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

---

## 🛠 Core Services Included

The `infra_node` (CT 113) runs the following stack natively through Docker using `network_mode: host`:
- **Traefik**: Reverse Proxy handling routing and SSL.
- **Adguard Home**: Network-wide DNS server and ad-blocker (Port 53, UI on Port 3000).
- **Tailscale**: Zero Trust VPN connectivity.
- **Uptime Kuma**: Monitoring and alerting (Port 3001).

*(Because of Proxmox LXC AppArmor restrictions, the core services bypass Docker's bridge networking to easily control the required privileged ports without sysctl errors).*