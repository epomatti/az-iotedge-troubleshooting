output "name" {
  value = azurerm_iothub.default.name
}

output "hostname" {
  value = azurerm_iothub.default.hostname
}

output "certificate_name" {
  value = azurerm_iothub_certificate.default.name
}
