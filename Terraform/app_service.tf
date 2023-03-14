# Create an App Service plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = "app-plan"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  sku {
    tier = "Basic"
    size = "B1"
  }
  
  capacity {
    default = 1
    maximum = 10
    minimum = 1
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
    "DB_USER"      = azurerm_key_vault_secret.db_user.value
    "DB_PASSWORD"  = azurerm_key_vault_secret.db_password.value
  }
  
  # Configure HTTPS
  site_config {
    https_only = true

    # Replace this with your custom domain and SSL certificate
    host_name_ssl_states = [
      {
        name            = "test.api.com"
        ssl_state       = "SniEnabled"
        thumbprint      = "your-ssl-thumbprint"
        to_update       = true
      }
    ]
  }
}

# Scale-out configuration
resource "azurerm_monitor_autoscale_setting" "app_service_scale_out" {
  name                = "app-service-scale-out"
  resource_group_name = azurerm_resource_group.app_rg.name

  target_resource_id = azurerm_app_service.app_service.id

  profile {
    name = "default"

    rules {
      metric_trigger {
        metric_name        = "HttpQueueLength"
        metric_resource_id = azurerm_app_service.app_service.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 100
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }
  }
}
