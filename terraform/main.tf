# Tạo LXC Container đầu tiên (bpg/proxmox schema)
resource "proxmox_virtual_environment_container" "web_server" {
  node_name = var.proxmox_node_name
  vm_id     = 112

  description = "Web server LXC container managed by Terraform"

  # OS Template (LXC)
  operating_system {
    template_file_id = var.lxc_template
    type             = "ubuntu"
  }

  # CPU
  cpu {
    cores = 2
    units = 1024
  }

  # Memory
  memory {
    dedicated = 2048
    swap      = 512
  }

  # Root filesystem
  disk {
    datastore_id = "local-lvm"
    size         = 20
  }

  # Network (DHCP via ip_config)
  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
  }

  initialization {
    hostname = "web-server-01"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [trimspace(file(var.ssh_public_key))]
    }
  }

  features {
    nesting = true
  }

  started = true
}

# Output Container IP address (from initialization)
output "web_server_ip" {
  description = "IP address of the web server container"
  value       = proxmox_virtual_environment_container.web_server.initialization[0].ip_config[0].ipv4[0].address
}
