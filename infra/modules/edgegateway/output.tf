output "public_ip" {
  value = azurerm_public_ip.edgegateway.ip_address
}
