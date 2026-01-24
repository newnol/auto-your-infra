# Terraform Proxmox Provider Reference

## Overview
The Terraform Proxmox provider allows you to manage Proxmox Virtual Environment resources through Terraform.

## Provider Configuration

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66.2"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox.example.com:8006/"
  username = "root@pam"
  password = var.proxmox_password
  insecure = true  # Only for self-signed certificates
}
```

## Key Resources

### Virtual Machines
```hcl
resource "proxmox_virtual_environment_vm" "example" {
  name        = "terraform-vm"
  description = "Managed by Terraform"
  node_name   = "pve"

  cpu {
    cores = 2
    sockets = 1
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.100/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = "ubuntu"
      password = "ubuntu"
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
```

### Containers (LXC)
```hcl
resource "proxmox_virtual_environment_container" "ubuntu_container" {
  node_name = "pve"
  vm_id     = 100

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.ubuntu_container_template.id
    type             = "ubuntu"
  }

  network_interface {
    name = "eth0"
    bridge = "vmbr0"
  }
}
```

### Cloud Images
```hcl
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id  = "local"
  node_name     = "pve"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
```

## Data Sources

### VM Information
```hcl
data "proxmox_virtual_environment_vm" "example" {
  node_name = "pve"
  vm_id     = 100
}
```

### Node Information
```hcl
data "proxmox_virtual_environment_nodes" "available_nodes" {}
```

## Best Practices

### State Management
- Use remote state for team collaboration
- Implement state locking
- Regular state backups

### Resource Organization
- Use modules for reusable components
- Implement proper naming conventions
- Group related resources

### Security
- Store sensitive data in variables or secrets management
- Use least privilege API tokens
- Enable TLS verification in production

### Performance
- Use parallel resource creation when possible
- Implement proper dependencies
- Monitor API rate limits

## Common Issues

### API Connection
- Verify endpoint URL and port
- Check API credentials
- Ensure proper TLS configuration

### Resource Conflicts
- Use unique VM IDs
- Implement proper locking
- Check for existing resources

### Template Issues
- Verify template availability
- Check storage permissions
- Ensure network configuration