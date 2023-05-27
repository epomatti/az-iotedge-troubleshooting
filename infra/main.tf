terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.58.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  private_zone_domain = "bluefactory.local"
  group               = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = var.workload
  location = var.location
}

### ACR ###
module "acr" {
  source   = "./modules/acr"
  group    = local.group
  location = local.location
}

### IoT Hub ###
module "iothub" {
  source   = "./modules/iothub"
  group    = local.group
  location = local.location
}

### Network ###

# resource "azurerm_virtual_network" "default" {
#   name                = "vnet-${var.app}"
#   address_space       = ["10.0.0.0/16"]
#   location            = var.location
#   resource_group_name = var.workload
# }

# resource "azurerm_subnet" "default" {
#   name                 = "subnet-default"
#   resource_group_name  = var.workload
#   virtual_network_name = azurerm_virtual_network.default.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "downstream" {
#   name                 = "subnet-downstream"
#   resource_group_name  = var.workload
#   virtual_network_name = azurerm_virtual_network.default.name
#   address_prefixes     = ["10.0.90.0/24"]
# }

# resource "azurerm_private_dns_zone" "default" {
#   name                = local.private_zone_domain
#   resource_group_name = var.workload
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "default" {
#   name                  = "edge-network-link"
#   resource_group_name   = var.workload
#   private_dns_zone_name = azurerm_private_dns_zone.default.name
#   virtual_network_id    = azurerm_virtual_network.default.id
#   registration_enabled  = true
# }

# ### Network Security Group ###

# module "nsg" {
#   source   = "./modules/nsg"
#   group    = var.workload
#   location = var.location
#   app      = var.app
#   subnet   = azurerm_subnet.default.id
# }

# ### Iot Edge ###

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

# ### Output JSON ###

# resource "local_file" "config" {
#   content = jsonencode(
#     {
#       "id_scope" : "${azurerm_iothub_dps.default.id_scope}",
#       "edgegateway_ip" : "${azurerm_public_ip.edgegateway.ip_address}",
#       "iothub_name" : "${azurerm_iothub.default.name}",
#       "dps_name" : "${azurerm_iothub_dps.default.name}",
#       "resource_group_name" : "${azurerm_resource_group.default.name}",
#       "root_ca_name" : "${azurerm_iothub_dps_certificate.default.name}",
#       "iothub_hostname" : "${azurerm_iothub.default.hostname}",
#       "downstream_device_01_ip" : "${module.downstream.public_ip}",
#     }
#   )
#   filename = "output.json"
# }
