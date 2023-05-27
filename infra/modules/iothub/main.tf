resource "azurerm_iothub" "default" {
  name                = "iot-${var.workload}"
  resource_group_name = var.group
  location            = var.location

  sku {
    name     = var.sku_name
    capacity = var.sku_capacity
  }
}

resource "azurerm_iothub_certificate" "default" {
  name                = "TerraformRootCA"
  resource_group_name = var.group
  iothub_name         = azurerm_iothub.default.name
  is_verified         = true
  certificate_content = filebase64("${path.module}/../../secrets/azure-iot-test-only.root.ca.cert.pem")
}
