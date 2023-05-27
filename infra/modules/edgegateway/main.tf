# resource "azurerm_public_ip" "edgegateway" {
#   name                = "pip-${var.app}-edgegateway"
#   resource_group_name = var.workload
#   location            = var.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "edgegateway" {
#   name                = "nic-${var.app}-edgegateway"
#   location            = var.location
#   resource_group_name = var.workload

#   ip_configuration {
#     name                          = "dns"
#     subnet_id                     = azurerm_subnet.default.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.edgegateway.id
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "azurerm_linux_virtual_machine" "edgegateway" {
#   name                  = "vm-${var.app}-edgegateway"
#   resource_group_name   = var.workload
#   location              = var.location
#   size                  = var.vm_edgegateway_size
#   admin_username        = "edgegateway"
#   admin_password        = "P@ssw0rd.123"
#   network_interface_ids = [azurerm_network_interface.edgegateway.id]

#   custom_data = filebase64("${path.module}/cloud-init.sh")

#   admin_ssh_key {
#     username   = "edgegateway"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     name                 = "osdisk-${var.app}-edgegateway"
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }

#   depends_on = [
#     module.nsg
#   ]

#   lifecycle {
#     ignore_changes = [
#       custom_data
#     ]
#   }
# }

# resource "azurerm_private_dns_cname_record" "edgegateway" {
#   name                = "edgegateway"
#   zone_name           = azurerm_private_dns_zone.default.name
#   resource_group_name = var.workload
#   ttl                 = 300
#   record              = "${azurerm_linux_virtual_machine.edgegateway.name}.${local.private_zone_domain}."
# }