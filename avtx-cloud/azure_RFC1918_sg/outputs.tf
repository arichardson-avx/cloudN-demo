output "public_sg_id" {
  value = azurerm_network_security_group.public.id

}

output "private_sg_id" {
  value = azurerm_network_security_group.private.id

}
