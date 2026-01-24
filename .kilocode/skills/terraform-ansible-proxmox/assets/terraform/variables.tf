# Terraform Variables for Homelab Infrastructure
# This file defines all variables used in the Terraform configuration

# Proxmox Provider Configuration
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://proxmox.selfhost.io.vn:8006/"
}

variable "proxmox_username" {
  description = "Proxmox API username"
  type        = string
  default     = "root@pam"
  sensitive   = true
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name to deploy VMs on"
  type        = string
  default     = "pve"
}

# Project Configuration
variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "homelab"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Storage Configuration
variable "image_datastore" {
  description = "Datastore for storing cloud images"
  type        = string
  default     = "local"
}

variable "vm_datastore" {
  description = "Datastore for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "container_datastore" {
  description = "Datastore for LXC containers"
  type        = string
  default     = "local-lvm"
}

# Network Configuration
variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "gateway_ip" {
  description = "Gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "web_vlan_id" {
  description = "VLAN ID for web servers"
  type        = number
  default     = null
}

variable "database_vlan_id" {
  description = "VLAN ID for database servers"
  type        = number
  default     = null
}

variable "monitoring_vlan_id" {
  description = "VLAN ID for monitoring servers"
  type        = number
  default     = null
}

variable "reverse_proxy_vlan_id" {
  description = "VLAN ID for reverse proxy containers"
  type        = number
  default     = null
}

# VM Authentication
variable "vm_username" {
  description = "Default username for VMs"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "Default password for VMs (will be changed by Ansible)"
  type        = string
  default     = "changeme123"
  sensitive   = true
}

variable "container_password" {
  description = "Default password for containers"
  type        = string
  default     = "changeme123"
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""
}

# Web Server Configuration
variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2
  validation {
    condition     = var.web_server_count >= 0 && var.web_server_count <= 10
    error_message = "Web server count must be between 0 and 10."
  }
}

variable "web_server_cores" {
  description = "Number of CPU cores for web servers"
  type        = number
  default     = 2
  validation {
    condition     = var.web_server_cores >= 1 && var.web_server_cores <= 8
    error_message = "Web server cores must be between 1 and 8."
  }
}

variable "web_server_memory" {
  description = "Memory in MB for web servers"
  type        = number
  default     = 2048
  validation {
    condition     = var.web_server_memory >= 512 && var.web_server_memory <= 16384
    error_message = "Web server memory must be between 512MB and 16384MB."
  }
}

variable "web_server_disk_size" {
  description = "Disk size for web servers (GB)"
  type        = number
  default     = 20
  validation {
    condition     = var.web_server_disk_size >= 10 && var.web_server_disk_size <= 100
    error_message = "Web server disk size must be between 10GB and 100GB."
  }
}

# Database Server Configuration
variable "database_server_count" {
  description = "Number of database servers to create"
  type        = number
  default     = 1
  validation {
    condition     = var.database_server_count >= 0 && var.database_server_count <= 5
    error_message = "Database server count must be between 0 and 5."
  }
}

variable "database_server_cores" {
  description = "Number of CPU cores for database servers"
  type        = number
  default     = 4
  validation {
    condition     = var.database_server_cores >= 2 && var.database_server_cores <= 16
    error_message = "Database server cores must be between 2 and 16."
  }
}

variable "database_server_memory" {
  description = "Memory in MB for database servers"
  type        = number
  default     = 4096
  validation {
    condition     = var.database_server_memory >= 1024 && var.database_server_memory <= 32768
    error_message = "Database server memory must be between 1024MB and 32768MB."
  }
}

variable "database_server_disk_size" {
  description = "OS disk size for database servers (GB)"
  type        = number
  default     = 25
  validation {
    condition     = var.database_server_disk_size >= 20 && var.database_server_disk_size <= 100
    error_message = "Database server disk size must be between 20GB and 100GB."
  }
}

variable "database_data_disk_size" {
  description = "Data disk size for database servers (GB)"
  type        = number
  default     = 50
  validation {
    condition     = var.database_data_disk_size >= 20 && var.database_data_disk_size <= 500
    error_message = "Database data disk size must be between 20GB and 500GB."
  }
}

# Monitoring Server Configuration
variable "monitoring_server_count" {
  description = "Number of monitoring servers to create"
  type        = number
  default     = 1
  validation {
    condition     = var.monitoring_server_count >= 0 && var.monitoring_server_count <= 3
    error_message = "Monitoring server count must be between 0 and 3."
  }
}

variable "monitoring_server_cores" {
  description = "Number of CPU cores for monitoring servers"
  type        = number
  default     = 2
  validation {
    condition     = var.monitoring_server_cores >= 1 && var.monitoring_server_cores <= 8
    error_message = "Monitoring server cores must be between 1 and 8."
  }
}

variable "monitoring_server_memory" {
  description = "Memory in MB for monitoring servers"
  type        = number
  default     = 4096
  validation {
    condition     = var.monitoring_server_memory >= 1024 && var.monitoring_server_memory <= 16384
    error_message = "Monitoring server memory must be between 1024MB and 16384MB."
  }
}

variable "monitoring_server_disk_size" {
  description = "Disk size for monitoring servers (GB)"
  type        = number
  default     = 30
  validation {
    condition     = var.monitoring_server_disk_size >= 20 && var.monitoring_server_disk_size <= 100
    error_message = "Monitoring server disk size must be between 20GB and 100GB."
  }
}

# Reverse Proxy Container Configuration
variable "reverse_proxy_count" {
  description = "Number of reverse proxy containers to create"
  type        = number
  default     = 1
  validation {
    condition     = var.reverse_proxy_count >= 0 && var.reverse_proxy_count <= 3
    error_message = "Reverse proxy count must be between 0 and 3."
  }
}

variable "reverse_proxy_cores" {
  description = "Number of CPU cores for reverse proxy containers"
  type        = number
  default     = 1
  validation {
    condition     = var.reverse_proxy_cores >= 1 && var.reverse_proxy_cores <= 4
    error_message = "Reverse proxy cores must be between 1 and 4."
  }
}

variable "reverse_proxy_memory" {
  description = "Memory in MB for reverse proxy containers"
  type        = number
  default     = 512
  validation {
    condition     = var.reverse_proxy_memory >= 256 && var.reverse_proxy_memory <= 2048
    error_message = "Reverse proxy memory must be between 256MB and 2048MB."
  }
}

variable "reverse_proxy_swap" {
  description = "Swap memory in MB for reverse proxy containers"
  type        = number
  default     = 256
  validation {
    condition     = var.reverse_proxy_swap >= 0 && var.reverse_proxy_swap <= 1024
    error_message = "Reverse proxy swap must be between 0MB and 1024MB."
  }
}

variable "reverse_proxy_disk_size" {
  description = "Disk size for reverse proxy containers (GB)"
  type        = number
  default     = 8
  validation {
    condition     = var.reverse_proxy_disk_size >= 5 && var.reverse_proxy_disk_size <= 20
    error_message = "Reverse proxy disk size must be between 5GB and 20GB."
  }
}

variable "ubuntu_container_template" {
  description = "Proxmox container template file ID"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}