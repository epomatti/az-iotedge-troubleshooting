resource "azurerm_container_registry" "acr" {
  name                = "acriotedgebluefactory"
  resource_group_name = var.group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}
