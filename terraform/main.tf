module "infra_node" {
  source         = "./modules/proxmox_vm"
  node_name      = var.proxmox_node_name
  vm_id          = 213
  hostname       = "infra-node-vm"
  template_vm_id = 9001

  cores     = 1
  memory    = 1536
  disk_size = 16

  ip_address     = "192.168.1.59/24"
  gateway        = "192.168.1.1"
  ssh_public_key = trimspace(file(var.ssh_public_key))
}

output "infra_node_ip" {
  description = "IP address of the Infra Node VM"
  value       = module.infra_node.ip_address_out
}


module "monitor_node" {
  source = "./modules/proxmox_lxc"
  node_name = var.proxmox_node_name
  vm_id     = 217
  hostname  = "monitor-node"

  template_file_id = var.lxc_template
  os_type          = "debian"
  cores            = 1
  memory           = 1536
  disk_size        = 15

  ip_address     = "192.168.1.61/24"
  gateway        = "192.168.1.1"
  ssh_public_key = trimspace(file(var.ssh_public_key))

  unprivileged = true
  nesting      = true

  default_password = var.default_password
}

output "monitor_node_ip" {
  description = "IP address of the Monitor Node LXC"
  value       = split("/", module.monitor_node.ip_address_out)[0]
}


module "app_node" {
  source         = "./modules/proxmox_vm"
  node_name      = var.proxmox_node_name
  vm_id          = 215
  hostname       = "app-node"
  template_vm_id = 9001

  cores     = 4
  memory    = 8192
  disk_size = 50

  ip_address     = "192.168.1.62/24"
  gateway        = "192.168.1.1"
  ssh_public_key = trimspace(file(var.ssh_public_key))
}

output "app_node_ip" {
  description = "IP address of the App Node VM"
  value       = module.app_node.ip_address_out
}
