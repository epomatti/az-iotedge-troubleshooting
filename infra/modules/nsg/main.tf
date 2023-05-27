# https://learn.microsoft.com/en-us/azure/iot-edge/production-checklist?view=iotedge-1.4#allow-connections-from-iot-edge-devices

resource "azurerm_network_security_group" "edgegateway_allow_ssh" {
  name                = "nsg-${var.workload}-edgegateway"
  location            = var.location
  resource_group_name = var.group

  # Inbound

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH for development purposes only"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound

  security_rule {
    name                       = "AllowHTTP"
    description                = "This is not required by IoT Edge. Allowing for development purposes only."
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowIoTEdge"
    description                = "Allows IoT Edge connectivity ports."
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "8883", "5671"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowNetworkCommon"
    description                = "Allows NTP"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["123", "53"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "edgegateway" {
  subnet_id                 = var.subnet
  network_security_group_id = azurerm_network_security_group.edgegateway_allow_ssh.id
}
