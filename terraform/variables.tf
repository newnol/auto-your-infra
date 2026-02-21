variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "proxmox_api_user" {
  description = "Proxmox API username"
  type        = string
  sensitive   = true
}

variable "proxmox_api_pass" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for container access"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "lxc_template" {
  description = "LXC template name in Proxmox"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

variable "proxmox_node_name" {
  description = "Proxmox node name to deploy containers on"
  type        = string
  default     = "asus"

  validation {
    condition     = contains(["asus", "host", "thinkpad"], var.proxmox_node_name)
    error_message = "Node must be 'asus', 'host', or 'thinkpad'."
  }
}
