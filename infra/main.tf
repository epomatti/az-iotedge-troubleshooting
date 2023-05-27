terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.58.0"
    }
  }
  backend "local" {
    path = ".workspace/terraform.tfstate"
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
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

### ACR ###
module "acr" {
  source   = "./modules/acr"
  group    = azurerm_resource_group.default.name
  location = azurerm_resource_group.default.location
}

### IoT Hub ###
module "iothub" {
  source       = "./modules/iothub"
  workload     = var.workload
  group        = azurerm_resource_group.default.name
  location     = azurerm_resource_group.default.location
  sku_name     = var.iothub_sku_name
  sku_capacity = var.iothub_sku_capacity
}

### Network ###
module "network" {
  source              = "./modules/network"
  workload            = var.workload
  group               = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  private_zone_domain = local.private_zone_domain
}

# ### Network Security Group ###
module "nsg" {
  source   = "./modules/nsg"
  group    = azurerm_resource_group.default.name
  location = azurerm_resource_group.default.location
  workload = var.workload
  subnet   = module.network.subnet_id
}

### Edge Gateway ###
module "edgegateway" {
  source        = "./modules/edgegateway"
  group         = azurerm_resource_group.default.name
  location      = azurerm_resource_group.default.location
  workload      = var.workload
  subnet        = module.network.subnet_id
  zone_name     = module.network.zone_name
  vm_size       = var.edgegateway_vm_size
  image_offer   = var.edgegateway_image_offer
  image_sku     = var.edgegateway_image_sku
  image_version = var.edgegateway_image_version
}

### JSON Output ###
resource "local_file" "config" {
  content = jsonencode(
    {
      "edgegateway_ip" : "${module.edgegateway.public_ip}",
      "iothub_name" : "${module.iothub.name}",
      "resource_group_name" : "${azurerm_resource_group.default.name}",
      "root_ca_name" : "${module.iothub.certificate_name}",
      "iothub_hostname" : "${module.iothub.hostname}",
    }
  )
  filename = "output.json"
}
