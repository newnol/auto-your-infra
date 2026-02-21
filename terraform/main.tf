module "web_server" {
  source           = "./modules/proxmox_lxc"
  node_name        = var.proxmox_node_name
  vm_id            = 112
  hostname         = "web-server-01"
  description      = "Web server LXC container managed by Terraform"
  template_file_id = var.lxc_template
  cores            = 2
  memory           = 2048
  swap             = 512
  disk_size        = 20
  ip_address       = "dhcp"
  ssh_public_key   = trimspace(file(var.ssh_public_key))
  unprivileged     = true
  nesting          = true
}

output "web_server_ip" {
  description = "IP address of the web server container"
  value       = module.web_server.ip_address_out
}


module "infra_node" {
  source           = "./modules/proxmox_lxc"
  node_name        = "host"
  vm_id            = 113
  hostname         = "infra-node"
  description      = "Infra Node (Control Plane / Core Services)"
  template_file_id = var.lxc_template
  cores            = 2
  memory           = 2048
  swap             = 512
  disk_size        = 20
  ip_address       = "192.168.1.59/24"
  gateway          = "192.168.1.1"
  dns_servers      = ["1.1.1.1", "8.8.8.8"]
  ssh_public_key   = trimspace(file(var.ssh_public_key))
  unprivileged     = false
  nesting          = true
}

output "infra_node_ip" {
  description = "IP address of the Infra Node container"
  value       = module.infra_node.ip_address_out
}
