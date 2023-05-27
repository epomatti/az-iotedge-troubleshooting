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
  source       = "./modules/iothub"
  workload     = var.workload
  group        = local.group
  location     = local.location
  sku_name     = var.iothub_sku_name
  sku_capacity = var.iothub_sku_capacity
}

### Network ###
module "network" {
  source              = "./modules/network"
  workload            = var.workload
  group               = local.group
  location            = local.location
  private_zone_domain = local.private_zone_domain
}


### Network Security Group ###
module "nsg" {
  source   = "./modules/nsg"
  group    = local.group
  location = local.location
  workload = var.workload
  subnet   = module.network.subnet_id
}

# ### Iot Edge ###



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
