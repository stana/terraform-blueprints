output "vm_ids" {
  description = "List of VM IDs"
  value       = azurerm_linux_virtual_machine.this[*].id
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = azurerm_network_interface.this[*].private_ip_address
}

output "ssh_private_key" {
  description = "SSH private key (sensitive)"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}
