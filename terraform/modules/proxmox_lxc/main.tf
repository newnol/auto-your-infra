terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.46.1"
    }
  }
}

resource "proxmox_virtual_environment_container" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id

  description = var.description

  dynamic "clone" {
    for_each = var.clone_vm_id != null ? [1] : []
    content {
      vm_id = var.clone_vm_id
    }
  }

  dynamic "operating_system" {
    for_each = var.clone_vm_id == null ? [1] : []
    content {
      template_file_id = var.template_file_id
      type             = "unmanaged"
    }
  }

  cpu {
    cores = var.cores
    units = 1024
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = false
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }

    user_account {
      keys     = [var.ssh_public_key]
      password = var.default_password
    }
  }

  unprivileged = var.unprivileged

  features {
    nesting = var.nesting
  }

  started = true
}

output "ip_address_out" {
  description = "IP address of the created container"
  value       = var.ip_address == "dhcp" ? proxmox_virtual_environment_container.this.initialization[0].ip_config[0].ipv4[0].address : var.ip_address
}
