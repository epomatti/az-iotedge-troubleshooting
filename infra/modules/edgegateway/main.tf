resource "azurerm_public_ip" "edgegateway" {
  name                = "pip-${var.workload}-edgegateway"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "edgegateway" {
  name                = "nic-${var.workload}-edgegateway"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "dns"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.edgegateway.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "edgegateway" {
  name                  = "vm-${var.workload}-edgegateway"
  resource_group_name   = var.group
  location              = var.location
  size                  = var.vm_size
  admin_username        = "edgegateway"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.edgegateway.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "edgegateway"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.workload}-edgegateway"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

resource "azurerm_private_dns_a_record" "edgegateway" {
  name                = "edgegateway.bluefactory.local"
  zone_name           = var.zone_name
  resource_group_name = var.group
  ttl                 = 3600
  records             = [azurerm_network_interface.edgegateway.private_ip_address]
}
