resource "digitalocean_droplet" "app" {
  name   = var.droplet_name
  region = var.region
  size   = var.size
  image  = var.image

  ssh_keys = var.ssh_key_ids
  tags     = var.tags
}

output "droplet_ipv4" {
  description = "Public IPv4 address of the droplet"
  value       = digitalocean_droplet.app.ipv4_address
}

output "droplet_urn" {
  description = "DigitalOcean URN for the droplet"
  value       = digitalocean_droplet.app.urn
}
