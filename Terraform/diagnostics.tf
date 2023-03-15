resource "azurerm_log_analytics_workspace" "app-law" {
  name                = "app-workspace"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "app-insights" {
  name                = "app-service-insights"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  application_type    = "web"
}

resource "azurerm_monitor_diagnostic_setting" "app-diagnostic" {
  name               = "app-diagnostic-settings"
  target_resource_id = "${azurerm_app_service.app_service.id}"

  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.app-law.id}"

  application_insights {
    instrumentation_key = "${azurerm_application_insights.app-insights.instrumentation_key}"
    sampling_percentage = 100
  }

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }
}
