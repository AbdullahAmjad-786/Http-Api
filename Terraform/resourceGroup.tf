# Create a resource group
resource "azurerm_resource_group" "app_rg" {
  name     = "app-rg"
  location = var.location
}
