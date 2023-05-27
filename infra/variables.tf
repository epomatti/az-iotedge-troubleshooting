variable "workload" {
  type    = string
  default = "bluefactory"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "iothub_sku_name" {
  type    = string
  default = "S1"
}

variable "iothub_sku_capacity" {
  type    = number
  default = 1
}

# Edge Gateway

variable "edgegateway_vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "edgegateway_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-focal"
}

variable "edgegateway_image_sku" {
  type    = string
  default = "20_04-lts-gen2"
}

variable "edgegateway_image_version" {
  type    = string
  default = "latest"
}
