variable "node_name" {
  description = "Name of the Proxmox node"
  type        = string
}

variable "vm_id" {
  description = "The VM ID to assign"
  type        = number
}

variable "hostname" {
  description = "Hostname for the VM"
  type        = string
}

variable "template_vm_id" {
  description = "ID of the Proxmox VM template to clone (e.g., 9000)"
  type        = number
  default     = 9000
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of RAM in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Size of the root disk in GB (e.g., 20)"
  type        = number
  default     = 20
}

variable "ip_address" {
  description = "IP address with CIDR (e.g., 192.168.1.59/24)"
  type        = string
}

variable "gateway" {
  description = "Default gateway (e.g., 192.168.1.1)"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key to inject via Cloud-Init"
  type        = string
}

variable "cloudinit_user" {
  description = "The default user to create via Cloud-Init"
  type        = string
  default     = "ubuntu"
}
