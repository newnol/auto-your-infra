variable "node_name" {
  description = "Name of the Proxmox Node to deploy to (e.g., host, asus, thinkpad)"
  type        = string
}

variable "vm_id" {
  description = "Container ID (must be unique)"
  type        = number
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
}

variable "description" {
  description = "Description of the container"
  type        = string
  default     = "Managed by Terraform"
}

variable "template_file_id" {
  description = "LXC Template ID (e.g., local:vztmpl/ubuntu-24...)"
  type        = string
}

variable "os_type" {
  description = "Operating system type for container initialization (e.g., debian, ubuntu)"
  type        = string
  default     = "debian"
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Dedicated RAM (MB)"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Swap Space (MB)"
  type        = number
  default     = 512
}

variable "disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Proxmox Storage ID for the disk"
  type        = string
  default     = "local-lvm"
}

variable "ip_address" {
  description = "IPv4 Address in CIDR (e.g., 192.168.1.10/24) or dhcp"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "IPv4 Gateway (required if ip_address is not dhcp)"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "SSH Public Key content for root access"
  type        = string
}

variable "unprivileged" {
  description = "Run as unprivileged container (true/false)"
  type        = bool
  default     = true
}

variable "nesting" {
  description = "Enable nested virtualization (e.g., for Docker)"
  type        = bool
  default     = false
}

variable "clone_vm_id" {
  description = "Optional VM ID to clone from (e.g., a golden template). If set, OS template is ignored."
  type        = number
  default     = null
}

variable "default_password" {
  description = "Default root password for initialized containers"
  type        = string
  sensitive   = true
}
