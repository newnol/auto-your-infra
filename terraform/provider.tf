terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.46.3"
    }
  }
  required_version = ">= 1.0"
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_api_user
  password = var.proxmox_api_pass

  # Skip TLS verification (chỉ cho môi trường dev/lab)
  insecure = true

  # Debug mode (bật khi gặp lỗi)
  # debug = true
}
