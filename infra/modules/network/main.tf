resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.workload}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_private_dns_zone" "default" {
  name                = var.private_zone_domain
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "edge-network-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = true
}
