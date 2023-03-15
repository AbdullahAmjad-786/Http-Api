# Create an App Service plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = "test-app-plan"
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
  name                = "test-app-service"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  app_service_plan_id  = azurerm_app_service_plan.app_plan.id

  site_config {
    always_on = true
  }

  app_settings = {
    "PORT"         = "8080"
    "DATABASE_URL" = azurerm_key_vault_secret.database_url.value
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
  
  # Associate with an NSG
  network_profile {
    name = "app-service-nsg"

    # Replace this with the subnet ID that the App Service is deployed to
    subnet_id = "/subscriptions/16919139-1b98-46d6-b9a1-66d6fae4a934/resourceGroups/${azurerm_resource_group.app_rg.name}/providers/Microsoft.Network/virtualNetworks/app-vnet/subnets/app-vnet-subnet"
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
