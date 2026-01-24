# Homelab Infrastructure - Terraform Configuration
# This file contains the main Terraform configuration for Proxmox homelab setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66.2"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "homelab-terraform-state"
  #   key    = "infrastructure.tfstate"
  #   region = "us-east-1"
  # }
}

# Proxmox provider configuration
provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
}

# Download Ubuntu cloud image
resource "proxmox_virtual_environment_download_file" "ubuntu_2204_cloudimg" {
  content_type = "iso"
  datastore_id  = var.image_datastore
  node_name     = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

# Web server VMs
resource "proxmox_virtual_environment_vm" "web_servers" {
  count       = var.web_server_count
  name        = "${var.project_name}-web-${count.index + 1}"
  description = "Web server ${count.index + 1} - Managed by Terraform"
  node_name   = var.proxmox_node
  vm_id       = 100 + count.index

  cpu {
    cores   = var.web_server_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.web_server_memory
  }

  disk {
    datastore_id = var.vm_datastore
    file_id      = proxmox_virtual_environment_download_file.ubuntu_2204_cloudimg.id
    interface    = "virtio0"
    size         = var.web_server_disk_size
    discard      = "on"
    ssd          = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.${100 + count.index}/24"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      password = var.vm_password
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge      = var.network_bridge
    vlan_id     = var.web_vlan_id
    firewall    = true
    mac_address = format("BC:24:11:00:00:%02X", 100 + count.index)
  }

  operating_system {
    type = "l26"
  }

  tags = ["web", "homelab", var.environment]

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].password,
    ]
  }
}

# Database server VM
resource "proxmox_virtual_environment_vm" "database_server" {
  count       = var.database_server_count
  name        = "${var.project_name}-db-${count.index + 1}"
  description = "Database server ${count.index + 1} - Managed by Terraform"
  node_name   = var.proxmox_node
  vm_id       = 200 + count.index

  cpu {
    cores   = var.database_server_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.database_server_memory
  }

  disk {
    datastore_id = var.vm_datastore
    file_id      = proxmox_virtual_environment_download_file.ubuntu_2204_cloudimg.id
    interface    = "virtio0"
    size         = var.database_server_disk_size
    discard      = "on"
    ssd          = true
  }

  # Additional data disk for database
  disk {
    datastore_id = var.vm_datastore
    interface    = "virtio1"
    size         = var.database_data_disk_size
    discard      = "on"
    ssd          = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.${200 + count.index}/24"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      password = var.vm_password
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge      = var.network_bridge
    vlan_id     = var.database_vlan_id
    firewall    = true
    mac_address = format("BC:24:11:00:01:%02X", 200 + count.index)
  }

  operating_system {
    type = "l26"
  }

  tags = ["database", "homelab", var.environment]

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].password,
    ]
  }
}

# Monitoring server VM
resource "proxmox_virtual_environment_vm" "monitoring_server" {
  count       = var.monitoring_server_count
  name        = "${var.project_name}-mon-${count.index + 1}"
  description = "Monitoring server ${count.index + 1} - Managed by Terraform"
  node_name   = var.proxmox_node
  vm_id       = 300 + count.index

  cpu {
    cores   = var.monitoring_server_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.monitoring_server_memory
  }

  disk {
    datastore_id = var.vm_datastore
    file_id      = proxmox_virtual_environment_download_file.ubuntu_2204_cloudimg.id
    interface    = "virtio0"
    size         = var.monitoring_server_disk_size
    discard      = "on"
    ssd          = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.${150 + count.index}/24"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      password = var.vm_password
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge      = var.network_bridge
    vlan_id     = var.monitoring_vlan_id
    firewall    = true
    mac_address = format("BC:24:11:00:02:%02X", 150 + count.index)
  }

  operating_system {
    type = "l26"
  }

  tags = ["monitoring", "homelab", var.environment]

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].password,
    ]
  }
}

# LXC Container for reverse proxy/load balancer
resource "proxmox_virtual_environment_container" "reverse_proxy" {
  count        = var.reverse_proxy_count
  node_name    = var.proxmox_node
  vm_id        = 400 + count.index
  description  = "Reverse proxy container ${count.index + 1} - Managed by Terraform"

  cpu {
    cores   = var.reverse_proxy_cores
    units   = 1024
  }

  memory {
    dedicated = var.reverse_proxy_memory
    swap      = var.reverse_proxy_swap
  }

  disk {
    datastore_id = var.container_datastore
    size         = var.reverse_proxy_disk_size
  }

  operating_system {
    template_file_id = var.ubuntu_container_template
    type             = "ubuntu"
  }

  network_interface {
    name        = "eth0"
    bridge      = var.network_bridge
    vlan_id     = var.reverse_proxy_vlan_id
    firewall    = true
    ipv4_address = "192.168.1.${50 + count.index}/24"
    gateway      = var.gateway_ip
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "${var.project_name}-proxy-${count.index + 1}"

    user_account {
      password = var.container_password
      keys     = [var.ssh_public_key]
    }
  }

  tags = ["proxy", "homelab", var.environment]
}

# Outputs for Ansible inventory generation
output "web_server_ips" {
  description = "IP addresses of web servers"
  value       = proxmox_virtual_environment_vm.web_servers[*].initialization[0].ip_config[0].ipv4[0].address
}

output "database_server_ips" {
  description = "IP addresses of database servers"
  value       = proxmox_virtual_environment_vm.database_server[*].initialization[0].ip_config[0].ipv4[0].address
}

output "monitoring_server_ips" {
  description = "IP addresses of monitoring servers"
  value       = proxmox_virtual_environment_vm.monitoring_server[*].initialization[0].ip_config[0].ipv4[0].address
}

output "reverse_proxy_ips" {
  description = "IP addresses of reverse proxy containers"
  value       = proxmox_virtual_environment_container.reverse_proxy[*].network_interface[0].ipv4_address
}

output "vm_ids" {
  description = "VM IDs for reference"
  value = {
    web_servers        = proxmox_virtual_environment_vm.web_servers[*].vm_id
    database_servers   = proxmox_virtual_environment_vm.database_server[*].vm_id
    monitoring_servers = proxmox_virtual_environment_vm.monitoring_server[*].vm_id
    reverse_proxies    = proxmox_virtual_environment_container.reverse_proxy[*].vm_id
  }
}