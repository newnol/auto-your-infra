output "ip_address_out" {
  description = "The IP address of the VM"
  value       = split("/", var.ip_address)[0]
}
