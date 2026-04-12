variable "droplet_name" {
  description = "Name of the DigitalOcean droplet"
  type        = string
  default     = "do-app-1"
}

variable "region" {
  description = "DigitalOcean region slug"
  type        = string
  default     = "sgp1"
}

variable "size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Droplet image slug"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "ssh_key_ids" {
  description = "Existing DigitalOcean SSH key IDs or fingerprints"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to attach to the droplet"
  type        = list(string)
  default     = ["homelab", "digitalocean"]
}
