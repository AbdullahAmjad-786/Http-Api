# Create an App Service plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = "app-plan"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Create an Azure App Service
resource "azurerm_app_service" "app_service" {
  name                = "app-service"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  app_service_plan_id  = azurerm_app_service_plan.app_plan.id

  site_config {
    always_on = true
    linux_fx_version = "COMPOSE|${filebase64("docker-compose.yml")}"
  }

  app_settings = {
    "PORT"         = "8080"
    "DATABASE_URL" = azurerm_mysql_server.mysql_server.fqdn
    "DB_USER"      = var.db_username
    "DB_PASSWORD"  = var.db_password
  }
}
